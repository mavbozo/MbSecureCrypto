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

/// A class providing secure encryption and decryption capabilities using modern cryptographic algorithms.
/// @discussion This class implements AES-GCM encryption with proper nonce handling and
/// authenticated encryption features.
@interface MBSCipher : NSObject

/// Encrypts a string using the specified algorithm and key
/// @param string The string to encrypt
/// @param algorithm The encryption algorithm to use
/// @param key The encryption key (must be appropriate size for algorithm)
/// @param error Error object populated on failure
/// @return Base64 encoded encrypted string, or nil on error
+ (nullable NSString *)encryptString:(NSString *)string
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Decrypts a base64 encoded encrypted string using the specified key
/// @param encryptedString Base64 encoded encrypted string (must include nonce and tag)
/// @param algorithm The encryption algorithm used
/// @param key The decryption key (must match encryption key)
/// @param error Error object populated on failure
/// @return The decrypted string, or nil on error
+ (nullable NSString *)decryptString:(NSString *)encryptedString
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error;

/// Encrypts data using the specified algorithm and key
/// @param data The data to encrypt
/// @param algorithm The encryption algorithm to use
/// @param key The encryption key (must be appropriate size for algorithm)
/// @param error Error object populated on failure
/// @return NSData containing encrypted data with nonce and tag, or nil on error
+ (nullable NSData *)encryptData:(NSData *)data
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                         withKey:(NSData *)key
                           error:(NSError **)error;

/// Decrypts data using the specified algorithm and key
/// @param encryptedData Data containing nonce, ciphertext and tag
/// @param algorithm The encryption algorithm used
/// @param key The decryption key (must match encryption key)
/// @param error Error object populated on failure
/// @return The decrypted data, or nil on error
+ (nullable NSData *)decryptData:(NSData *)encryptedData
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                         withKey:(NSData *)key
                           error:(NSError **)error;


/// Encrypts a file using the specified algorithm and key
/// @param sourceURL URL of the file to encrypt
/// @param destinationURL URL where the encrypted file will be written
/// @param algorithm The encryption algorithm to use
/// @param key The encryption key (must be appropriate size for algorithm)
/// @param error Error object populated on failure
/// @return YES if successful, NO otherwise
+ (BOOL)encryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
            withKey:(NSData *)key
              error:(NSError **)error;

/// Decrypts a file using the specified algorithm and key
/// @param sourceURL URL of the encrypted file
/// @param destinationURL URL where the decrypted file will be written
/// @param algorithm The encryption algorithm that was used
/// @param key The decryption key (must match encryption key)
/// @param error Error object populated on failure
/// @return YES if successful, NO otherwise
+ (BOOL)decryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
            withKey:(NSData *)key
              error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
