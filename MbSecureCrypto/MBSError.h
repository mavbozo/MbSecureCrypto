//
//  MBSError.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 08/11/24.
//

// MBSError.h
#import <Foundation/Foundation.h>

#ifndef MBSError_h
#define MBSError_h

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const MBSErrorDomain;

FOUNDATION_EXPORT const NSUInteger kMBSCipherMaxFileSize;

/// Error codes for Random operations.
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSRandomError) {
    MBSRandomErrorInvalidByteCount = 100,
    MBSRandomErrorGenerationFailed = 101,
    MBSRandomErrorBufferAllocation = 102
} API_AVAILABLE(macos(12.4), ios(15.6));

/// Error codes for cipher operations
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSCipherError) {
    // Input validation errors
    MBSCipherErrorInvalidKey = 200,           // Key size doesn't match algorithm requirements
    MBSCipherErrorInvalidIV = 201,            // IV/nonce is invalid or wrong size
    MBSCipherErrorInvalidInput = 202,         // Input data is invalid or corrupted
    MBSCipherErrorUnsupportedAlgorithm = 203, // Requested algorithm is not supported
    
    // Operation errors
    MBSCipherErrorEncryptionFailed = 210,     // Encryption operation failed
    MBSCipherErrorDecryptionFailed = 211,     // Decryption operation failed
    MBSCipherErrorAuthenticationFailed = 212, // Authentication tag verification failed
    
    // File operation errors
    MBSCipherErrorIOFailure = 220,           // File read/write operation failed
    MBSCipherErrorFileTooLarge = 221,        // File exceeds size limit
    MBSCipherErrorFilePermission = 222       // Insufficient permission to access file
} API_AVAILABLE(macos(12.4), ios(15.6));

NS_ASSUME_NONNULL_END

#endif
