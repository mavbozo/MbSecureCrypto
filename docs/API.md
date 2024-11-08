# MbSecureCrypto API Reference

## Table of Contents
- [Overview](#overview)
- [Random Number Generation](#random-number-generation)
  - [MBSRandom Class](#mbsrandom-class)
- [Encryption](#encryption)
  - [MBSCipher Class](#mbscipher-class)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Version History](#version-history)

## Overview

MbSecureCrypto provides cryptographically secure random number generation and encryption capabilities for iOS and macOS applications. The library is designed to be easy to use while maintaining strong security guarantees.

## Random Number Generation

### MBSRandom Class

#### `+ (nullable NSData *)generateBytes:(NSInteger)byteCount error:(NSError **)error`

Generates cryptographically secure random bytes.

**Parameters:**
- `byteCount`: Number of random bytes to generate (1 to 1MB)
- `error`: Error object populated on failure

**Returns:**
- NSData containing random bytes, or nil on error

**Example:**
```objectivec
NSError *error = nil;
NSData *randomData = [MBSRandom generateBytes:32 error:&error];
if (randomData) {
    // Use the random data
}
```

#### `+ (nullable NSString *)generateBytesAsHex:(NSInteger)byteCount error:(NSError **)error`

Generates random bytes as a hexadecimal string.

**Parameters:**
- `byteCount`: Number of random bytes (1 to 1MB)
- `error`: Error object populated on failure

**Returns:**
- Hexadecimal string (length will be 2*byteCount)

#### `+ (nullable NSString *)generateBytesAsBase64:(NSInteger)byteCount error:(NSError **)error`

Generates random bytes as a base64 string.

**Parameters:**
- `byteCount`: Number of random bytes (1 to 1MB)
- `error`: Error object populated on failure

**Returns:**
- Base64 encoded string

## Encryption

### MBSCipher Class

#### String Encryption

##### `+ (nullable NSString *)encryptString:(NSString *)string withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Encrypts a string using the specified algorithm.

**Parameters:**
- `string`: String to encrypt
- `algorithm`: Encryption algorithm (currently only AES-GCM supported)
- `key`: 32-byte key for AES-256
- `error`: Error object populated on failure

**Returns:**
- Base64 encoded encrypted string, or nil on error

##### `+ (nullable NSString *)decryptString:(NSString *)encryptedString withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Decrypts an encrypted string.

**Parameters:**
- `encryptedString`: Base64 encoded encrypted string
- `algorithm`: Algorithm used for encryption
- `key`: Original encryption key
- `error`: Error object populated on failure

**Returns:**
- Decrypted string, or nil on error

#### Data Encryption

##### `+ (nullable NSData *)encryptData:(NSData *)data withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Encrypts data using the specified algorithm.

**Parameters:**
- `data`: Data to encrypt
- `algorithm`: Encryption algorithm
- `key`: 32-byte key
- `error`: Error object populated on failure

**Returns:**
- Encrypted data including nonce and tag, or nil on error

##### `+ (nullable NSData *)decryptData:(NSData *)encryptedData withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Decrypts encrypted data.

**Parameters:**
- `encryptedData`: Data to decrypt (must include nonce and tag)
- `algorithm`: Algorithm used for encryption
- `key`: Original encryption key
- `error`: Error object populated on failure

**Returns:**
- Decrypted data, or nil on error

#### File Encryption

##### `+ (BOOL)encryptFile:(NSURL *)sourceURL toOutput:(NSURL *)destinationURL withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Encrypts a file.

**Parameters:**
- `sourceURL`: Source file URL
- `destinationURL`: Destination file URL
- `algorithm`: Encryption algorithm
- `key`: 32-byte key
- `error`: Error object populated on failure

**Returns:**
- YES if successful, NO on error

**Notes:**
- Maximum file size: 10MB
- Files are processed in memory

##### `+ (BOOL)decryptFile:(NSURL *)sourceURL toOutput:(NSURL *)destinationURL withAlgorithm:(MBSCipherAlgorithm)algorithm withKey:(NSData *)key error:(NSError **)error`

Decrypts an encrypted file.

**Parameters:**
- `sourceURL`: Encrypted file URL
- `destinationURL`: Output file URL
- `algorithm`: Algorithm used for encryption
- `key`: Original encryption key
- `error`: Error object populated on failure

**Returns:**
- YES if successful, NO on error

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

## Error Handling

### Random Operation Errors (MBSRandomError)
```objectivec
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSRandomError) {
    MBSRandomErrorInvalidByteCount = 100,
    MBSRandomErrorGenerationFailed = 101,
    MBSRandomErrorBufferAllocation = 102
};
```

### Cipher Operation Errors (MBSCipherError)
```objectivec
typedef NS_ERROR_ENUM(MBSErrorDomain, MBSCipherError) {
    MBSCipherErrorInvalidKey = 200,
    MBSCipherErrorInvalidInput = 202,
    MBSCipherErrorEncryptionFailed = 210,
    MBSCipherErrorDecryptionFailed = 211,
    MBSCipherErrorFileTooLarge = 221
};
```

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
