//
//  MBSCryptoOperation.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 29/10/24.
//

#import "MBSCryptoOperation.h"
#import <Security/Security.h>

@implementation MBSCryptoOperation

+ (nullable NSString *)randomStringWithLength:(NSInteger)length
                                      error:(NSError **)error {
    // Input validation
    if (length <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:100
                                   userInfo:@{NSLocalizedDescriptionKey: @"Length must be greater than 0"}];
        }
        return nil;
    }
    
    // Create buffer for random bytes
    NSMutableData *randomData = [NSMutableData dataWithLength:length];
    
    // Generate random bytes using SecRandomCopyBytes
    int status = SecRandomCopyBytes(kSecRandomDefault, length, randomData.mutableBytes);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:101
                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to generate random bytes"}];
        }
        return nil;
    }
    
    // Convert to base64 string
    return [randomData base64EncodedStringWithOptions:0];
}

+ (nullable NSData *)randomBytes:(NSInteger)numBytes
                          error:(NSError **)error {
    if (numBytes <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:100
                                   userInfo:@{NSLocalizedDescriptionKey: @"Number of bytes must be greater than 0"}];
        }
        return nil;
    }
    
    NSMutableData *randomData = [NSMutableData dataWithLength:numBytes];
    if (!randomData) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:102
                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to allocate buffer"}];
        }
        return nil;
    }
    
    int status = SecRandomCopyBytes(kSecRandomDefault, numBytes, randomData.mutableBytes);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:101
                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to generate random bytes"}];
        }
        return nil;
    }
    
    return randomData;
}

+ (nullable NSString *)randomBytesAsHex:(NSInteger)numBytes
                                 error:(NSError **)error {
    NSData *data = [self randomBytes:numBytes error:error];
    if (!data) {
        return nil;
    }
    
    const unsigned char *bytes = data.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:numBytes * 2];
    
    for (NSInteger i = 0; i < numBytes; i++) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    
    return hexString;
}

+ (nullable NSString *)randomBytesAsBase64:(NSInteger)numBytes
                                    error:(NSError **)error {
    NSData *data = [self randomBytes:numBytes error:error];
    if (!data) {
        return nil;
    }
    
    return [data base64EncodedStringWithOptions:0];
}

@end
