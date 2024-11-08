// MBSRandom.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSRandom : NSObject

/**
 * Generates cryptographically secure random bytes using the system's secure random number generator.
 *
 * This method uses SecRandomCopyBytes from the Security framework to generate
 * cryptographically secure random numbers. The generated data is suitable for
 * cryptographic operations, including key generation and nonce creation.
 *
 * @param byteCount The number of random bytes to generate. Must be between 1 and 1MB (1,048,576 bytes).
 * @param error On failure, contains an NSError object that describes the problem:
 *        - MBSRandomErrorInvalidByteCount (100): Requested size is 0, negative, or exceeds 1MB
 *        - MBSRandomErrorGenerationFailed (101): System failed to generate random bytes
 *        - MBSRandomErrorBufferAllocation (102): Failed to allocate memory
 *
 * @return An immutable NSData object containing the random bytes, or nil if generation failed.
 *         The returned data is guaranteed to contain exactly byteCount random bytes if successful.
 *
 * @note This method is thread-safe and can be called concurrently from multiple threads.
 *       Memory containing sensitive data is securely cleared after use.
 */
+ (nullable NSData *)generateBytes:(NSUInteger)byteCount error:(NSError **)error;

/**
 * Generates random bytes and returns them encoded as a lowercase hexadecimal string.
 *
 * This method generates cryptographically secure random bytes and converts them to
 * a hexadecimal string representation. Each byte is represented by two hexadecimal
 * digits (00-ff).
 *
 * @param byteCount The number of random bytes to generate. Must be between 1 and 1MB.
 *                  The resulting string will be twice this length (2 hex digits per byte).
 * @param error On failure, contains an NSError object that describes the problem:
 *        - MBSRandomErrorInvalidByteCount (100): Requested size is 0, negative, or exceeds 1MB
 *        - MBSRandomErrorGenerationFailed (101): System failed to generate random bytes
 *        - MBSRandomErrorBufferAllocation (102): Failed to allocate memory
 *
 * @return A string containing the hexadecimal representation of the random bytes,
 *         or nil if generation failed. The string contains only lowercase letters a-f
 *         and numbers 0-9.
 *
 * @note This method is thread-safe. The resulting string length will be exactly
 *       2 * byteCount characters if successful.
 */
+ (nullable NSString *)generateBytesAsHex:(NSUInteger)byteCount
                                    error:(NSError **)error;
/**
 * Generates random bytes and returns them encoded as a Base64 string.
 *
 * This method generates cryptographically secure random bytes and encodes them using
 * standard Base64 encoding (RFC 4648). The resulting string may include padding
 * characters ('=') as required by the Base64 specification.
 *
 * @param byteCount The number of random bytes to generate. Must be between 1 and 1MB.
 *                  The resulting Base64 string length will be approximately 4/3 times
 *                  this value due to Base64 encoding overhead.
 * @param error On failure, contains an NSError object that describes the problem:
 *        - MBSRandomErrorInvalidByteCount (100): Requested size is 0, negative, or exceeds 1MB
 *        - MBSRandomErrorGenerationFailed (101): System failed to generate random bytes
 *        - MBSRandomErrorBufferAllocation (102): Failed to allocate memory
 *
 * @return A Base64-encoded string representation of the random bytes, or nil if
 *         generation failed. The string contains only characters A-Z, a-z, 0-9, +, /,
 *         and possibly trailing = padding.
 *
 * @note This method is thread-safe. The Base64 encoding is performed using Apple's
 *       standard Base64 implementation.
 */
+ (nullable NSString *)generateBytesAsBase64:(NSUInteger)byteCount
                                       error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
