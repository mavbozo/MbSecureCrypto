# ``MbSecureCrypto``

A secure cryptography library for iOS and macOS.

## Table of Contents
- [Overview](#overview)
- [AES-GCM](#aes-gcm)
- [Format Specifications](#format-specifications)
- [Types & Algorithms](#types-and-algorithms)
- [Error Handling](#error-handling)
- [Usage Notes](#usage-notes)
- [Best Practices](#best-practices)
- [Version History](#version-history)

## Overview

MbSecureCrypto provides cryptographically secure random number generation and encryption capabilities.

## AES-GCM

### AES-GCM Implementation Details

#### Nonce and Tag Handling

The `MBSCipher` class automatically handles nonces and authentication tags:

- **Nonce Generation**: Each encryption operation generates a fresh 12-byte nonce using `MBSRandom`
- **Data Format**: Encrypted output is structured as `[nonce][ciphertext][tag]`
- **Sizing**:
  - Nonce: 12 bytes
  - Tag: 16 bytes
  - Minimum total size: 28 bytes (even for empty input)
  
#### Format Details
```objc
// Encryption result structure
typedef struct {
    uint8_t nonce[12];     // Random nonce
    uint8_t ciphertext[];  // Encrypted data (variable length)
    uint8_t tag[16];       // Authentication tag
} MBSEncryptedData;
```

The decryption functions automatically extract and validate these components, ensuring authenticated decryption.

## Format Specifications

Format V0 (Default)

Used in versions 0.3.0 and earlier

The V0 format is structured as follows:
```
[12-byte nonce][ciphertext][16-byte tag]
```

Key characteristics:
- Nonce: 12 bytes, randomly generated
- Tag: 16 bytes, GCM authentication tag
- Total overhead: 28 bytes per encrypted output
- Base64 encoded for string operations
- Raw bytes for data/file operations
- No explicit version or algorithm indicators


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

## Version History

### Version 0.4.0
#### Added
- Format versioning support via `MBSCipherFormat` enum
- New API methods with explicit format parameters
- Improved interoperability documentation
- Format versioning documentation

#### Changed
- Enhanced error messages for format-related issues
- Updated documentation with format specifications

#### Compatibility
- Fully backward compatible with 0.3.0
- Default format (V0) matches existing implementation

### Version 0.3.0
- Added encryption capabilities
- Added MBSRandom class
- Added comprehensive error handling
- Deprecated MBSCryptoOperation

### Version 0.2.0
- Added random bytes generation methods
- Added hex and base64 encoding options

### Version 0.1.0
- Initial release

## Topics

### Essentials

- ``MBSRandom``
- ``MBSCipher``

### Error Handling

- ``MBSRandomError-enum``
- ``MBSCipherError-enum``
