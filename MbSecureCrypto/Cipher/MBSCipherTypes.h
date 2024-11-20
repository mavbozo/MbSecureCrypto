//
//  MBSCipherTypes.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 11/11/24.
//
#import <Foundation/Foundation.h>

#ifndef MBSCipherTypes_h
#define MBSCipherTypes_h

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MBSCipherAlgorithm) {
    MBSCipherAlgorithmAESGCM = 0
} API_AVAILABLE(macos(12.4), ios(15.6));

/// Supported ciphertext format versions
typedef NS_ENUM(uint8_t, MBSCipherFormat) {
    /// Format V0: [12B nonce][ciphertext][16B tag]
    MBSCipherFormatV0 = 0,
    /// Reserved for future use
    MBSCipherFormatV1 = 1
} API_AVAILABLE(macos(12.4), ios(15.6));

NS_ASSUME_NONNULL_END

#endif
