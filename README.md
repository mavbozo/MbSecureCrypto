# MbSecureCrypto

A secure cryptography library for iOS and macOS that provides cryptographically secure random number generation and encryption capabilities.

## Requirements

- iOS 15.6+ / macOS 12.4+
- Xcode 13+
- Objective-C or Swift projects

## Features

- 🔒 Cryptographically secure random number generation using Apple's Security framework
- 🔐 AES-GCM encryption for strings, data, and files
- 📦 Multiple output formats: raw bytes, hexadecimal, and base64
- ⚡️ High-performance implementation using Apple's CryptoKit
- 🛡️ Side-channel attack protection
- ✅ Extensive test coverage
- 📱 iOS and macOS support

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'MbSecureCrypto', '~> 0.3.0'
```

### Swift Package Manager

Add the following dependency to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/mavbozo/MbSecureCrypto.git", from: "0.3.0")
]
```

## Usage

### Random Number Generation

#### Objective-C
```objectivec
#import <MbSecureCrypto/MbSecureCrypto.h>

// Generate 32 random bytes
NSError *error = nil;
NSData *randomData = [MBSRandom generateBytes:32 error:&error];

// Get random bytes as hex string
NSString *hexString = [MBSRandom generateBytesAsHex:32 error:&error];

// Get random bytes as base64 string
NSString *base64String = [MBSRandom generateBytesAsBase64:32 error:&error];
```

#### Swift
```swift
import MbSecureCrypto

do {
    // Generate 32 random bytes
    let randomData = try MBSRandom.generateBytes(32)
    
    // Get random bytes as hex string
    let hexString = try MBSRandom.generateBytesAsHex(32)
    
    // Get random bytes as base64 string
    let base64String = try MBSRandom.generateBytesAsBase64(32)
} catch {
    print("Operation failed: \(error)")
}
```

### Encryption

#### String Encryption
```objectivec
// Generate a random 32-byte key
NSError *error = nil;
NSData *key = [MBSRandom generateBytes:32 error:&error];

// Encrypt a string
NSString *encrypted = [MBSCipher encryptString:@"Secret message" 
                                 withAlgorithm:MBSCipherAlgorithmAESGCM 
                                       withKey:key 
                                         error:&error];

// Decrypt the string
NSString *decrypted = [MBSCipher decryptString:encrypted
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                       withKey:key
                                         error:&error];
```

#### File Encryption
```objectivec
NSURL *sourceURL = [NSURL fileURLWithPath:@"source.txt"];
NSURL *encryptedURL = [NSURL fileURLWithPath:@"encrypted.bin"];

NSError *error = nil;
NSData *key = [MBSRandom generateBytes:32 error:&error];

[MBSCipher encryptFile:sourceURL
              toOutput:encryptedURL
         withAlgorithm:MBSCipherAlgorithmAESGCM
               withKey:key
                 error:&error];
```

## Changelog

### [0.3.0] - 2024-11-11
#### Added
- AES-GCM encryption support for strings, data, and files
- Maximum file size limit (10MB) for encryption operations
- Comprehensive error handling with specific error codes
- Swift implementation using CryptoKit for core operations

#### Changed
- Renamed MBSCryptoOperation methods to MBSRandom
- Improved memory handling for sensitive data
- Enhanced error messaging and type safety

#### Deprecated
- All MBSCryptoOperation methods (use MBSRandom instead)

### [0.2.0] - 2024-11-02
- Added random bytes generation methods
- Improved error handling

### [0.1.0] - 2024-10-29
- Initial release

## Migration Guide

### Upgrading to 0.3.0

The `MBSCryptoOperation` class is deprecated. Migrate to the new `MBSRandom` class:

```objectivec
// Old
NSData *randomData = [MBSCryptoOperation randomBytes:32 error:&error];

// New
NSData *randomData = [MBSRandom generateBytes:32 error:&error];
```

## Error Handling

The library uses structured error domains and codes:

### Random Operations (MBSRandomError)
- `MBSRandomErrorInvalidByteCount`: Invalid byte count requested
- `MBSRandomErrorGenerationFailed`: Random number generation failed
- `MBSRandomErrorBufferAllocation`: Memory allocation failed

### Cipher Operations (MBSCipherError)
- `MBSCipherErrorInvalidKey`: Invalid key size
- `MBSCipherErrorInvalidInput`: Invalid input data
- `MBSCipherErrorEncryptionFailed`: Encryption operation failed
- `MBSCipherErrorDecryptionFailed`: Decryption operation failed
- `MBSCipherErrorFileTooLarge`: File exceeds size limit (10MB)

## Security Considerations

- Uses CryptoKit for core cryptographic operations
- Implements proper validation and error handling
- Ensures secure memory handling for sensitive data
- Protected against timing attacks
- Zero-fills sensitive memory after use
- Enforces appropriate key sizes and IV handling

### AES-GCM Nonce Handling
- Nonces are automatically generated using secure random generation
- Each encryption operation uses a unique 12-byte nonce
- Nonces are prepended to the ciphertext along with the authentication tag
- Format: `[12-byte nonce][ciphertext][16-byte tag]`
- Never reuse a key-nonce pair as this compromises security
- Encrypted output includes everything needed for decryption

Example complete ciphertext structure:
```
Base64(
    12 bytes: Nonce
    N bytes:  Ciphertext
    16 bytes: Authentication Tag
)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Copyright (c) 2024 Maverick Bozo

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security Disclosure

If you discover any security-related issues, please email mavbozo@pm.me instead of using the issue tracker.

## Documentation

For detailed API documentation, please see our [API Reference](docs/API.md).
