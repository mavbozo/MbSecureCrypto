// MBSCryptoOperation.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSCryptoOperation : NSObject

// Random string generation
+ (nullable NSString *)randomStringWithLength:(NSInteger)length
                                      error:(NSError **)error;

/// Generates N random bytes and returns them as NSData
/// @param numBytes Number of random bytes to generate
/// @param error Error object populated on failure
/// @return NSData containing numBytes random bytes, or nil on error
+ (nullable NSData *)randomBytes:(NSInteger)numBytes
                          error:(NSError **)error;

/// Generates N random bytes and returns them encoded as a hexadecimal string
/// @param numBytes Number of random bytes to generate
/// @param error Error object populated on failure
/// @return A string of length 2*numBytes containing the hex representation, or nil on error
+ (nullable NSString *)randomBytesAsHex:(NSInteger)numBytes
                                 error:(NSError **)error;

/// Generates N random bytes and returns them encoded as base64 string
/// @param numBytes Number of random bytes to generate
/// @param error Error object populated on failure
/// @return A base64 string representing numBytes random bytes, or nil on error
+ (nullable NSString *)randomBytesAsBase64:(NSInteger)numBytes
                                    error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
