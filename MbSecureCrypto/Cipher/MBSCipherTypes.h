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
    /// 12 bytes nonce
    /// 16 bytes tag
    MBSCipherFormatV0 = 0,
    /// Format V1: Universal Secure Block Format
    /// Structure: [MAGIC(4)][VER(1)][ALG(1)][PARAMS_LEN(2)][PARAMS(var)][DATA][TAG]
    /// - MAGIC: "SECB" (0x53454342)
    /// - VER: Format version (0x01)
    /// - ALG: Algorithm identifier
    ///   - 0x01: AES-GCM
    ///   - 0x02: AES-CBC
    ///   - 0x03: AES-CTR
    ///   - 0x11: ChaCha20-Poly1305
    /// - PARAMS_LEN: 2-byte parameter length (big-endian)
    /// - PARAMS: Algorithm-specific parameters
    ///   - AES-GCM: [IV(12)][TAG_LEN(4)]
    ///   - AES-CBC: [IV(16)]
    ///   - ChaCha20-Poly1305: [NONCE(12)][COUNTER(4)]
    /// - DATA: Encrypted content
    /// - TAG: Authentication tag (if applicable)
    MBSCipherFormatV1 = 1
} API_AVAILABLE(macos(12.4), ios(15.6));

NS_ASSUME_NONNULL_END

#endif
