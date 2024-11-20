
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A utility class that provides cryptographically secure random number generation.
///
/// MBSRandom leverages Apple's Security framework to generate high-quality random numbers
/// suitable for cryptographic operations. All methods are thread-safe and implement
/// secure memory handling practices.
///
/// Example usage:
/// ```objc
/// // Generate a 32-byte cryptographic key
/// NSError *error = nil;
/// NSData *keyData = [MBSRandom generateBytes:32 error:&error];
///
/// // Create a random identifier
/// NSString *randomId = [MBSRandom generateBytesAsHex:16 error:&error];
///
/// // Generate a nonce for encryption
/// NSString *nonce = [MBSRandom generateBytesAsBase64:12 error:&error];
/// ```
///
/// @note This class uses SecRandomCopyBytes internally and is suitable for:
///       - Cryptographic key generation
///       - Initialization vectors/nonces
///       - Salt values
///       - Security-sensitive random data needs
///
NS_SWIFT_NAME(Random)
API_AVAILABLE(macos(12.4), ios(15.6))
@interface MBSRandom : NSObject


/// Generates cryptographically secure random bytes.
///
/// Uses SecRandomCopyBytes to generate high-quality random numbers suitable for
/// cryptographic operations. The implementation ensures secure memory handling
/// and proper cleanup of sensitive data.
///
/// @param byteCount Number of random bytes to generate (1 to 1,048,576 bytes)
/// @param error Error object populated on failure with codes:
///              - MBSRandomErrorInvalidByteCount (100): Invalid size requested
///              - MBSRandomErrorGenerationFailed (101): Generation failed
///              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
///
/// @return NSData containing the requested random bytes, or nil on failure
///
/// @note Sensitive data is securely cleared from memory after use
///
+ (nullable NSData *)generateBytes:(NSUInteger)byteCount error:(NSError **)error;

/// Generates random bytes and returns them as a hexadecimal string.
///
/// Creates cryptographically secure random bytes and converts them to a lowercase
/// hexadecimal string representation. Each byte becomes two hex digits (00-ff).
///
/// @param byteCount Number of random bytes (1 to 1,048,576). Output length will be 2 * byteCount.
/// @param error Error object populated on failure with codes:
///              - MBSRandomErrorInvalidByteCount (100): Invalid size requested
///              - MBSRandomErrorGenerationFailed (101): Generation failed
///              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
///
/// @return A lowercase hexadecimal string (using 0-9, a-f), or nil on failure
///
/// @note Output string length will be exactly 2 * byteCount if successful
///
+ (nullable NSString *)generateBytesAsHex:(NSUInteger)byteCount
                                    error:(NSError **)error;


/// Generates random bytes and returns them as a Base64 string.
///
/// Creates cryptographically secure random bytes and encodes them using standard
/// Base64 encoding (RFC 4648). Ideal for generating URL-safe tokens and identifiers.
///
/// @param byteCount Number of random bytes (1 to 1,048,576). Base64 output length ≈ 4/3 * byteCount.
/// @param error Error object populated on failure with codes:
///              - MBSRandomErrorInvalidByteCount (100): Invalid size requested
///              - MBSRandomErrorGenerationFailed (101): Generation failed
///              - MBSRandomErrorBufferAllocation (102): Memory allocation failed
///
/// @return A Base64 string (using A-Z, a-z, 0-9, +, / and possibly = padding), or nil on failure
///
/// @note Uses Apple's standard Base64 implementation
///
+ (nullable NSString *)generateBytesAsBase64:(NSUInteger)byteCount
                                       error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
