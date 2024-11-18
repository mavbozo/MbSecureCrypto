
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// A secure random number generation utility class.
///
/// MBSRandom provides cryptographically secure random number generation capabilities
/// using Apple's Security framework. All generated random numbers are suitable for
/// use in cryptographic operations such as key generation, nonce creation, and
/// other security-sensitive applications.
///
/// ## Topics
///
/// ### Generating Random Data
/// - ``generateBytes:error:``
/// - ``generateBytesAsHex:error:``
/// - ``generateBytesAsBase64:error:``
///

API_AVAILABLE(macos(12.4), ios(15.6))
@interface MBSRandom : NSObject


/**
 Generates cryptographically secure random bytes.
 
 Uses SecRandomCopyBytes from the Security framework to generate high-quality
 random numbers suitable for cryptographic operations. The generated data
 is appropriate for:
 
 - Cryptographic key generation
 - Initialization vectors/nonces
 - Salt values
 - Other security-sensitive random data needs
 
 @param byteCount The number of random bytes to generate (1 to 1,048,576 bytes)
 @param error On failure, contains an NSError object with these possible codes:
              - MBSRandomErrorInvalidByteCount (100): Size is 0, negative, or exceeds 1MB
              - MBSRandomErrorGenerationFailed (101): Random generation failed
              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
 
 @return NSData containing exactly byteCount random bytes, or nil on failure
 
 @note Memory containing sensitive data is securely cleared after use
 */
+ (nullable NSData *)generateBytes:(NSUInteger)byteCount error:(NSError **)error;

/**
 Generates random bytes and returns them as a hexadecimal string.
 
 Generates cryptographically secure random bytes and converts them to a
 lowercase hexadecimal string representation (00-ff per byte).
 
 @param byteCount The number of random bytes to generate (1 to 1,048,576)
                 The output string length will be 2 * byteCount
 @param error On failure, contains an NSError object with these possible codes:
              - MBSRandomErrorInvalidByteCount (100): Size is 0, negative, or exceeds 1MB
              - MBSRandomErrorGenerationFailed (101): Random generation failed
              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
 
 @return A string of lowercase hexadecimal digits (0-9, a-f), or nil on failure
 
 @note The resulting string length will be exactly 2 * byteCount if successful
 */
+ (nullable NSString *)generateBytesAsHex:(NSUInteger)byteCount
                                    error:(NSError **)error;


/**
 Generates random bytes and returns them as a Base64 string.
 
 Generates cryptographically secure random bytes and encodes them using
 standard Base64 encoding (RFC 4648). The output may include padding
 characters ('=') as required by the Base64 specification.
 
 @param byteCount The number of random bytes to generate (1 to 1,048,576)
                 The Base64 output length will be approximately 4/3 * byteCount
 @param error On failure, contains an NSError object with these possible codes:
              - MBSRandomErrorInvalidByteCount (100): Size is 0, negative, or exceeds 1MB
              - MBSRandomErrorGenerationFailed (101): Random generation failed
              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
 
 @return A Base64 string using characters A-Z, a-z, 0-9, +, / and possibly =
         padding, or nil on failure
 
 @note The Base64 encoding uses Apple's standard implementation
 */
+ (nullable NSString *)generateBytesAsBase64:(NSUInteger)byteCount
                                       error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
