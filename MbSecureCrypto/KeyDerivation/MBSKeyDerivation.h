//
//  MBSKeyDerivation.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 01/12/24.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Supported HKDF algorithms with their corresponding HMAC functions.
///
/// Use these algorithms to specify the hash function for HKDF operations:
/// ```objc
/// // Default SHA-256 usage
/// NSData *key = [MBSKeyDerivation deriveKey:masterKey
///                                    domain:@"encryption"
///                                   context:@"user-data"
///                                algorithm:MBSHkdfAlgorithmSHA256
///                                    error:&error];
/// ```
typedef NS_ENUM(NSInteger, MBSHkdfAlgorithm) {
    /// HKDF using HMAC-SHA256 (recommended default)
    /// - 256-bit output
    /// - 128-bit security level
    /// - Good balance of security and performance
    MBSHkdfAlgorithmSHA256 = 0,
    
    /// HKDF using HMAC-SHA512
    /// - 512-bit output
    /// - 256-bit security level
    /// - Higher security for sensitive applications
    MBSHkdfAlgorithmSHA512 = 1,
    
    /// HKDF using HMAC-SHA1 (legacy support only)
    /// - 160-bit output
    /// - Not recommended for new applications
    /// - Provided only for compatibility
    MBSHkdfAlgorithmSHA1 __deprecated_enum_msg("SHA1 is not recommended for new applications") = 2
};

/// A secure key derivation utility that implements HKDF (RFC 5869).
///
/// ``MBSKeyDerivation`` provides secure key derivation functionality using the HKDF
/// (HMAC-based Key Derivation Function) algorithm as specified in RFC 5869.
/// This implementation offers hardware-backed operation when available and
/// automatic cleanup of sensitive key material.
///
/// Key security features:
/// - Hardware security module integration when available
/// - Domain separation for derived keys
/// - Side-channel resistant implementation
/// - Multiple hash algorithm support
///
/// Example usage:
/// ```objc
/// // Generate a master key
/// NSData *masterKey = [MBSRandom generateBytes:32 error:&error];
///
/// // Derive an encryption key with domain separation
/// NSData *derivedKey = [MBSKeyDerivation deriveKey:masterKey
///                                           domain:@"myapp.encryption"
///                                          context:@"user-data-key"
///                                           error:&error];
/// ```
///
/// ## Security Considerations
///
/// - Master key requirements:
///   - Minimum length: 16 bytes (128 bits)
///   - Should be randomly generated using ``MBSRandom``
///   - Must be securely stored (e.g., in Keychain)
///
/// - Domain separation:
///   - Use unique domain strings for different key purposes
///   - Domain strings should include app package name or identifier
///   - Context strings should identify specific use cases
///
/// - Algorithm selection:
///   - SHA-256 (default) provides 128-bit security
///   - SHA-512 provides 256-bit security for high-security needs
///   - SHA-1 provided only for legacy compatibility
///
/// @see MBSRandom
/// @see MBSHkdfAlgorithm
@interface MBSKeyDerivation : NSObject

/// Derives a new key with specified parameters.
///
/// Derives a key using HKDF with the following structured info string format:
/// ```
/// com.mavbozo.mbsecurecrypto.<domain>.v1:<context>
/// ```
///
/// Example usage with custom parameters:
/// ```objc
/// NSData *key = [MBSKeyDerivation deriveKey:masterKey
///                                    domain:@"encryption"
///                                   context:@"user-data"
///                                   keySize:64
///                                algorithm:MBSHkdfAlgorithmSHA512
///                                    error:&error];
/// ```
///
/// - Parameters:
///   - masterKey: The master key for derivation (minimum 16 bytes)
///   - domain: Domain identifier for key separation (e.g., "myapp.encryption")
///   - context: Usage context for the key (e.g., "user-data")
///   - keySize: Size of the derived key in bytes
///   - algorithm: HKDF algorithm to use
///   - error: Error object populated on failure
/// - Returns: Derived key as NSData, or nil on error
///
/// - Note: The function enforces minimum key size requirements and validates all inputs
/// - Important: The master key should be securely generated and stored
+ (nullable NSData *)deriveKey:(NSData *)masterKey
                        domain:(NSString *)domain
                       context:(NSString *)context
                       keySize:(NSInteger)keySize
                     algorithm:(MBSHkdfAlgorithm)algorithm
                         error:(NSError **)error;

/// Derives a new key using default parameters (SHA-256, 32 bytes).
///
/// Convenience method that uses SHA-256 and generates a 32-byte key.
/// Equivalent to calling:
/// ```objc
/// [MBSKeyDerivation deriveKey:masterKey
///                      domain:domain
///                     context:context
///                     keySize:32
///                  algorithm:MBSHkdfAlgorithmSHA256
///                      error:error];
/// ```
///
/// - Parameters:
///   - masterKey: The master key for derivation (minimum 16 bytes)
///   - domain: Domain identifier for key separation
///   - context: Usage context for the key
///   - error: Error object populated on failure
/// - Returns: Derived key as NSData, or nil on error
+ (nullable NSData *)deriveKey:(NSData *)masterKey
                        domain:(NSString *)domain
                       context:(NSString *)context
                         error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
