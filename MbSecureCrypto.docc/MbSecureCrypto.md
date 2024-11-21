# ``MbSecureCrypto``

A secure cryptography library for iOS and macOS that provides cryptographically secure random number generation and encryption capabilities.

## Table of Contents
- [Features](#features)
- [Requirements](#Requirements)
- [Types & Algorithms](#types-and-algorithms)
- <doc:CipherFormat>
- [Error Handling](#error-handling)
- [Usage Notes](#usage-notes)
- [Best Practices](#best-practices)
- <doc:AESGCM>
- <doc:VersionHistory>

## Features

- 🔒 Cryptographically secure random number generation using Apple's Security framework
- 🔐 AES-GCM encryption for strings, data, and files
- 📦 Multiple output formats: raw bytes, hexadecimal, and base64
- ⚡️ High-performance implementation using Apple's CryptoKit
- 🛡️ Side-channel attack protection
- ✅ Extensive test coverage
- 📱 iOS and macOS support

## Requirements

- iOS 15.6+ / macOS 12.4+
- Xcode 13+
- Objective-C or Swift projects

## Types and Algorithms

### MBSCipherAlgorithm
```objectivec
typedef NS_ENUM(NSInteger, MBSCipherAlgorithm) {
    MBSCipherAlgorithmAESGCM = 0
} API_AVAILABLE(macos(12.4), ios(15.6));
```

### MBSCipherFormat
```objectivec
typedef NS_ENUM(uint8_t, MBSCipherFormat) {
    /// Format V0: [12B nonce][ciphertext][16B tag]
    MBSCipherFormatV0 = 0
    /// Format V1: Universal Secure Block Format
    /// Structure: [MAGIC(4)][VER(1)][ALG(1)][PARAMS_LEN(2)][PARAMS(var)][DATA][TAG]
    MBSCipherFormatV1 = 1
} API_AVAILABLE(macos(12.4), ios(15.6));
```

## Error Handling

### Random Operation Errors (MBSRandomError)
```objectivec
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSRandomError) {
    MBSRandomErrorInvalidByteCount = 100,
    MBSRandomErrorGenerationFailed = 101,
    MBSRandomErrorBufferAllocation = 102
};
```

### Cipher Operation Errors
```objectivec
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSCipherError) {
    // Input validation errors
    MBSCipherErrorInvalidKey = 200,           // Key size doesn't match algorithm requirements
    MBSCipherErrorInvalidIV = 201,            // IV/nonce is invalid or wrong size
    MBSCipherErrorInvalidInput = 202,         // Input data is invalid or corrupted
    MBSCipherErrorUnsupportedAlgorithm = 203, // Requested algorithm is not supported
    MBSCipherErrorUnsupportedFormat = 204,    // Unknown or unsupported format version
    MBSCipherErrorFormatDetectionFailed = 205, // Failed to detect format version
    MBSCipherErrorFormatMismatch = 206,       // Format version mismatch during decryption
    
    // Operation errors
    MBSCipherErrorEncryptionFailed = 210,     // Encryption operation failed
    MBSCipherErrorDecryptionFailed = 211,     // Decryption operation failed
    MBSCipherErrorAuthenticationFailed = 212,  // Authentication tag verification failed
    
    // File operation errors
    MBSCipherErrorIOFailure = 220,            // File read/write operation failed
    MBSCipherErrorFileTooLarge = 221,         // File exceeds size limit
    MBSCipherErrorFilePermission = 222        // Insufficient permission to access file
};
```

## Usage Notes

1. Format parameter is optional, defaults to V0
2. When decrypting, format detection is automatic if not specified
3. Encrypted output includes format version, nonce, and authentication tag
4. All operations maintain backward compatibility
5. Maximum file size limit: 10MB

## Best Practices

1. **Key Management**
   - Generate keys using `MBSRandom generateBytes:error:`
   - Store keys securely in Keychain
   - Use unique keys for each encryption operation
   - Implement proper key rotation

2. **Memory Security**
   - Zero sensitive data after use
   - Use autoreleasepool for deterministic cleanup
   - Avoid logging sensitive information

3. **Error Handling**
   - Always check error return values
   - Handle all error cases appropriately
   - Avoid exposing sensitive information in errors

4. **File Operations**
   - Respect the 10MB file size limit
   - Use atomic file operations
   - Clean up temporary files


## Topics

### Essentials

- ``MBSRandom``
- ``MBSCipher``

### Error Handling

- ``MBSRandomError-enum``
- ``MBSCipherError-enum``
