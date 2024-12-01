//
//  MBSKeyDerivation.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 01/12/24.
//


#import "MBSKeyDerivation.h"
#import "MBSError.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation MBSKeyDerivation

// MARK: - HKDF Internal Functions
// Suppress deprecated warnings for internal usage
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/**
 * Returns the digest length for a given algorithm.
 */
+ (NSInteger)digestLengthForAlgorithm:(MBSHkdfAlgorithm)algorithm {
    switch (algorithm) {
        case MBSHkdfAlgorithmSHA256:
            return CC_SHA256_DIGEST_LENGTH;
        case MBSHkdfAlgorithmSHA512:
            return CC_SHA512_DIGEST_LENGTH;
        case MBSHkdfAlgorithmSHA1:
            return CC_SHA1_DIGEST_LENGTH;
    }
}

/**
 * Returns the corresponding CCHmacAlgorithm for our HKDF algorithm.
 */
+ (CCHmacAlgorithm)ccHmacAlgorithmFor:(MBSHkdfAlgorithm)algorithm {
    switch (algorithm) {
        case MBSHkdfAlgorithmSHA256:
            return kCCHmacAlgSHA256;
        case MBSHkdfAlgorithmSHA512:
            return kCCHmacAlgSHA512;
        case MBSHkdfAlgorithmSHA1:
            return kCCHmacAlgSHA1;
    }
}

/**
 * HKDF-Extract function.
 * PRK = HMAC-Hash(salt, IKM)
 */
+ (nullable NSData *)extractWithSalt:(NSData *)salt
                                 ikm:(NSData *)ikm
                           algorithm:(MBSHkdfAlgorithm)algorithm {
    NSInteger hashLen = [self digestLengthForAlgorithm:algorithm];
    CCHmacAlgorithm ccAlgorithm = [self ccHmacAlgorithmFor:algorithm];
    
    uint8_t prk[hashLen];
    CCHmac(ccAlgorithm,
           salt.bytes, salt.length,
           ikm.bytes, ikm.length,
           prk);
    
    return [NSData dataWithBytes:prk length:hashLen];
}

/**
 * HKDF-Expand function.
 * OKM = T(1) | T(2) | T(3) | ... | T(N)
 * where T(i) = HMAC-Hash(PRK, T(i-1) | info | i)
 */
+ (nullable NSData *)expandWithPrk:(NSData *)prk
                              info:(NSData *)info
                            length:(NSInteger)length
                         algorithm:(MBSHkdfAlgorithm)algorithm {
    NSInteger hashLen = [self digestLengthForAlgorithm:algorithm];
    CCHmacAlgorithm ccAlgorithm = [self ccHmacAlgorithmFor:algorithm];
    
    // Number of iterations needed
    NSInteger n = (length + hashLen - 1) / hashLen;
    if (n > 255) {
        return nil; // RFC 5869 limitation
    }
    
    NSMutableData *okm = [NSMutableData dataWithLength:n * hashLen];
    uint8_t *output = (uint8_t *)okm.mutableBytes;
    
    // T(0) is empty
    NSMutableData *previousT = [NSMutableData dataWithLength:0];
    
    for (uint8_t i = 1; i <= n; i++) {
        CCHmacContext ctx;
        CCHmacInit(&ctx, ccAlgorithm, prk.bytes, prk.length);
        
        // T(i) = HMAC-Hash(PRK, T(i-1) | info | i)
        if (previousT.length > 0) {
            CCHmacUpdate(&ctx, previousT.bytes, previousT.length);
        }
        CCHmacUpdate(&ctx, info.bytes, info.length);
        CCHmacUpdate(&ctx, &i, 1);
        
        uint8_t t[hashLen];
        CCHmacFinal(&ctx, t);
        
        // Store T(i) for next iteration
        previousT = [NSMutableData dataWithBytes:t length:hashLen];
        
        // Append to output
        memcpy(output + ((i-1) * hashLen), t, hashLen);
    }
    
    // Trim to requested length
    okm.length = length;
    return okm;
}

// MARK: - Public Methods

+ (nullable NSData *)deriveKey:(NSData *)masterKey
                        domain:(NSString *)domain
                       context:(NSString *)context
                       keySize:(NSInteger)keySize
                     algorithm:(MBSHkdfAlgorithm)algorithm
                         error:(NSError **)error {
    // Input validation
    if (masterKey.length < 16) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Master key must be at least 16 bytes"}];
        }
        return nil;
    }
    
    if (domain.length == 0 || context.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Domain and context must not be empty"}];
        }
        return nil;
    }
    
    if (keySize <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key size must be positive"}];
        }
        return nil;
    }
    
    // Create info string with domain separation
    NSString *info = [NSString stringWithFormat:@"com.mavbozo.mbsecurecrypto.%@.v1:%@",
                      domain, context];
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    
    // Use zero-filled salt as per RFC 5869 recommendation for non-secret salt
    NSInteger hashLen = [self digestLengthForAlgorithm:algorithm];
    NSMutableData *salt = [NSMutableData dataWithLength:hashLen];
    
    @try {
        // Extract
        NSData *prk = [self extractWithSalt:salt ikm:masterKey algorithm:algorithm];
        if (!prk) {
            if (error) {
                *error = [NSError errorWithDomain:MBSErrorDomain
                                             code:MBSCipherErrorKeyDerivationFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"HKDF extract operation failed"}];
            }
            return nil;
        }
        
        // Expand
        NSData *okm = [self expandWithPrk:prk info:infoData length:keySize algorithm:algorithm];
        if (!okm) {
            if (error) {
                *error = [NSError errorWithDomain:MBSErrorDomain
                                             code:MBSCipherErrorKeyDerivationFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"HKDF expand operation failed"}];
            }
            return nil;
        }
        
        return okm;
    }
    @finally {
        // Clear sensitive data
        [salt resetBytesInRange:NSMakeRange(0, salt.length)];
    }
}

+ (nullable NSData *)deriveKey:(NSData *)masterKey
                        domain:(NSString *)domain
                       context:(NSString *)context
                         error:(NSError **)error {
    // Use default parameters: SHA-256 and 32-byte output
    return [self deriveKey:masterKey
                    domain:domain
                   context:context
                   keySize:32
                 algorithm:MBSHkdfAlgorithmSHA256
                     error:error];
}

@end
