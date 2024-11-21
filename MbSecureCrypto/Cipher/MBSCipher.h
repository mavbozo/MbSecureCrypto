//
//  MBSCipher.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 11/11/24.
//


#import <Foundation/Foundation.h>
#import "MBSCipherTypes.h"
#import "MBSError.h"

NS_ASSUME_NONNULL_BEGIN


/// A secure encryption and decryption utility that implements authenticated encryption.
///
/// MBSCipher provides authenticated encryption using AES-GCM, ensuring both confidentiality
/// and integrity of the encrypted data. The implementation handles nonce generation and
/// authentication tag management automatically.
///
///
/// ```objc
///
/// // Generate a random 32-byte key with explicit format
/// NSError *error = nil;
/// NSData *key = [MBSRandom generateBytes:32 error:&error];
///
/// // Encrypt a string with explicit format
/// NSString *encrypted = [MBSCipher encryptString:@"Secret message"
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                    withFormat:MBSCipherFormatV0
///                                       withKey:key
///                                         error:&error];
///
/// // Decrypt the string with format verification
/// NSString *decrypted = [MBSCipher decryptString:encrypted
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                    withFormat:MBSCipherFormatV0
///                                       withKey:key
///                                         error:&error];
///
/// // backward compatible call without withFormat defaults to MBSCipherFormatV0
///
/// // Encrypt a string without explicit format
/// NSString *encrypted = [MBSCipher encryptString:@"Secret message"
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                       withKey:key
///                                         error:&error];
///
/// // Decrypt the string without format verification
/// NSString *decrypted = [MBSCipher decryptString:encrypted
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                       withKey:key
///                                         error:&error];
///
/// ```
///
/// Example usage with recommended V1 format:
/// ```objc
/// // Generate a random 32-byte key
/// NSError *error = nil;
/// NSData *key = [MBSRandom generateBytes:32 error:&error];
///
/// // Encrypt string using V1 format (recommended)
/// NSString *encrypted = [MBSCipher encryptString:@"Secret message"
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                    withFormat:@(MBSCipherFormatV1)
///                                       withKey:key
///                                         error:&error];
///
/// // Decrypt string with V1 format
/// NSString *decrypted = [MBSCipher decryptString:encrypted
///                                  withAlgorithm:MBSCipherAlgorithmAESGCM
///                                    withFormat:@(MBSCipherFormatV1)
///                                       withKey:key
///                                         error:&error];
///
/// // File encryption with V1 format
/// NSURL *sourceURL = [NSURL fileURLWithPath:@"document.pdf"];
/// NSURL *encryptedURL = [NSURL fileURLWithPath:@"document.encrypted"];
///
/// BOOL success = [MBSCipher encryptFile:sourceURL
///                             toOutput:encryptedURL
///                        withAlgorithm:MBSCipherAlgorithmAESGCM
///                           withFormat:@(MBSCipherFormatV1)
///                              withKey:key
///                                error:&error];
/// ```
///
/// Format Specifications:
/// - V0 (Default): [12-byte nonce][ciphertext][16-byte tag]
///
/// - V1: Structure: [MAGIC(4)][VER(1)][ALG(1)][PARAMS_LEN(2)][PARAMS(var)][DATA][TAG]
API_AVAILABLE(macos(12.4), ios(15.6))
@interface MBSCipher : NSObject

/// Encrypts a string using authenticated encryption with specified format.
///
/// Encrypts the UTF-8 representation of the string using AES-GCM with a random nonce.
/// The output includes format-specific components needed for decryption.
///
/// @param string The string to encrypt (must be valid UTF-8)
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid input data
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return Base64-encoded string containing format-specific encrypted data, or nil on failure
///
/// @note MBSCipherFormatV1 format provides enhanced algorithm flexibility and
///       standardized parameter handling
+ (nullable NSString *)encryptString:(NSString *)string
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                          withFormat:(nullable NSNumber *)format
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Encrypts a string using authenticated encryption with specified format.
///
/// Encrypts the UTF-8 representation of the string using AES-GCM with a random nonce.
/// The output includes format-specific components needed for decryption.
///
/// @param string The string to encrypt (must be valid UTF-8)
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid input data
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return Base64-encoded string containing format-specific encrypted data, or nil on failure
+ (nullable NSString *)encryptString:(NSString *)string
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Decrypts an encrypted string using authenticated encryption.
///
/// Decrypts a string previously encrypted by encryptString:withAlgorithm:withKey:.
/// Verifies the authentication tag before returning the decrypted data.
///
/// @param encryptedString Base64-encoded string containing [nonce][ciphertext][tag]
/// @param algorithm Must match the algorithm used for encryption
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return The original decrypted string, or nil on failure
///
/// @note Decryption will fail if the data has been modified or if an incorrect key is used
///
/// @note MBSCipherFormatV1 format provides enhanced algorithm flexibility and
///       standardized parameter handling
+ (nullable NSString *)decryptString:(NSString *)encryptedString
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                          withFormat:(nullable NSNumber *)format
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Decrypts an encrypted string using authenticated encryption.
///
/// Decrypts a string previously encrypted by encryptString:withAlgorithm:withKey:.
/// Verifies the authentication tag before returning the decrypted data.
///
/// @param encryptedString Base64-encoded string containing [nonce][ciphertext][tag]
/// @param algorithm Must match the algorithm used for encryption
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return The original decrypted string, or nil on failure
///
/// @note Decryption will fail if the data has been modified or if an incorrect key is used
/// @note default to using format MBSCipherFormatV0
+ (nullable NSString *)decryptString:(NSString *)encryptedString
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Encrypts arbitrary data using authenticated encryption.
///
/// Encrypts the provided data using AES-GCM with a random nonce. The output
/// includes everything needed for decryption: nonce, ciphertext, and tag.
///
/// @param data The data to encrypt
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid input data
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return NSData or nil on failure
///
/// @note MBSCipherFormatV1 format provides enhanced algorithm flexibility and
///       standardized parameter handling
+ (nullable NSData *)encryptData:(NSData *)data
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                      withFormat:(nullable NSNumber * )format
                         withKey:(NSData *)key
                           error:(NSError **)error;

/// Encrypts arbitrary data using authenticated encryption.
///
/// Encrypts the provided data using AES-GCM with a random nonce. The output
/// includes everything needed for decryption: nonce, ciphertext, and tag.
///
/// @param data The data to encrypt
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid input data
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return NSData containing [nonce][ciphertext][tag], or nil on failure
///
/// @note default to using format MBSCipherFormatV0
+ (nullable NSData *)encryptData:(NSData *)data
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                         withKey:(NSData *)key
                           error:(NSError **)error;

/// Decrypts encrypted data using authenticated encryption.
///
/// Decrypts data previously encrypted by encryptData:withAlgorithm:withKey:.
/// Verifies the authentication tag before returning the decrypted data.
///
/// @param encryptedData Data containing [nonce][ciphertext][tag]
/// @param algorithm Must match the algorithm used for encryption
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return The original decrypted data, or nil on failure
///
/// @note MBSCipherFormatV1 format provides enhanced algorithm flexibility and
///       standardized parameter handling
+ (nullable NSData *)decryptData:(NSData *)encryptedData
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                      withFormat:(nullable NSNumber *)format
                         withKey:(NSData *)key
                           error:(NSError **)error;


/// Decrypts encrypted data using authenticated encryption.
///
/// Decrypts data previously encrypted by encryptData:withAlgorithm:withKey:.
/// Verifies the authentication tag before returning the decrypted data.
///
/// @param encryptedData Data containing [nonce][ciphertext][tag]
/// @param algorithm Must match the algorithm used for encryption
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return The original decrypted data, or nil on failure
/// @note default to using format MBSCipherFormatV0
+ (nullable NSData *)decryptData:(NSData *)encryptedData
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                         withKey:(NSData *)key
                           error:(NSError **)error;


/// Encrypts a file using authenticated encryption.
///
/// Encrypts the contents of a file using AES-GCM with a random nonce. The encrypted
/// file will include the nonce and authentication tag needed for decryption.
///
/// @param sourceURL File to encrypt (must be readable and ≤ 10MB)
/// @param destinationURL Where to write the encrypted file
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorFileTooLarge (221): File exceeds 10MB limit
///              - MBSCipherErrorIOFailure (220): File read/write failed
///              - MBSCipherErrorFilePermission (222): Insufficient permissions
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return YES if successful, NO if an error occurred
///
/// @note MBSCipherFormatV1 format provides enhanced algorithm flexibility and
///       standardized parameter handling
+ (BOOL)encryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
         withFormat:(nullable NSNumber *)format
            withKey:(NSData *)key
              error:(NSError **)error;

/// Encrypts a file using authenticated encryption.
///
/// Encrypts the contents of a file using AES-GCM with a random nonce. The encrypted
/// file will include the nonce and authentication tag needed for decryption.
///
/// @param sourceURL File to encrypt (must be readable and ≤ 10MB)
/// @param destinationURL Where to write the encrypted file
/// @param algorithm Currently only supports MBSCipherAlgorithmAESGCM
/// @param key 32-byte key for AES-256-GCM
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorFileTooLarge (221): File exceeds 10MB limit
///              - MBSCipherErrorIOFailure (220): File read/write failed
///              - MBSCipherErrorFilePermission (222): Insufficient permissions
///              - MBSCipherErrorEncryptionFailed (210): Encryption operation failed
///
/// @return YES if successful, NO if an error occurred
///
/// @note default to using format MBSCipherFormatV0
+ (BOOL)encryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
            withKey:(NSData *)key
              error:(NSError **)error;

/// Decrypts an encrypted file using authenticated encryption.
///
/// Decrypts a file previously encrypted by encryptFile:toOutput:withAlgorithm:withKey:.
/// Verifies the authentication tag before writing the decrypted data.
///
/// @param sourceURL Encrypted file containing [nonce][ciphertext][tag]
/// @param destinationURL Where to write the decrypted file
/// @param algorithm Must match the algorithm used for encryption
/// @param format Encryption format version to use:
///              - MBSCipherFormatV0: Legacy format [nonce][ciphertext][tag]
///              - MBSCipherFormatV1: Universal format with algorithm parameters
///              - nil: Defaults to V0 for backward compatibility
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorUnsupportedFormat (204): Unknown or unsupported format version
///              - MBSCipherErrorFormatDetectionFailed (205): Failed to detect format version
///              - MBSCipherErrorFormatMismatch (206): Format version mismatch during decryption
///              - MBSCipherErrorIOFailure (220): File read/write failed
///              - MBSCipherErrorFilePermission (222): Insufficient permissions
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return YES if successful, NO if an error occurred
///
+ (BOOL)decryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
         withFormat:(nullable NSNumber *)format
            withKey:(NSData *)key
              error:(NSError **)error;

/// Decrypts an encrypted file using authenticated encryption.
///
/// Decrypts a file previously encrypted by encryptFile:toOutput:withAlgorithm:withKey:.
/// Verifies the authentication tag before writing the decrypted data.
///
/// @param sourceURL Encrypted file containing [nonce][ciphertext][tag]
/// @param destinationURL Where to write the decrypted file
/// @param algorithm Must match the algorithm used for encryption
/// @param key Must be the same 32-byte key used for encryption
/// @param error Error object populated on failure with codes:
///              - MBSCipherErrorInvalidKey (200): Invalid key size
///              - MBSCipherErrorInvalidInput (202): Invalid/corrupted input
///              - MBSCipherErrorIOFailure (220): File read/write failed
///              - MBSCipherErrorFilePermission (222): Insufficient permissions
///              - MBSCipherErrorDecryptionFailed (211): Decryption operation failed
///              - MBSCipherErrorAuthenticationFailed (212): Tag verification failed
///
/// @return YES if successful, NO if an error occurred
/// @note default to using format MBSCipherFormatV0
+ (BOOL)decryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
            withKey:(NSData *)key
              error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
