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
pod 'MbSecureCrypto', '~> 0.5.0'
```

### Swift Package Manager

Add the following dependency to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/mavbozo/MbSecureCrypto.git", from: "0.5.0")
]
```

## Documentation Website

For detailed documentation, please see our [MBSecureCrypto Docs](https://mavbozo.github.io/MbSecureCrypto).

Select **Objective-C** on the top right of the page to view the ObjectiveC code docs.

## Quick Start

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

// Encrypt a string (default format V0)
NSString *encrypted = [MBSCipher encryptString:@"Secret message" 
                                 withAlgorithm:MBSCipherAlgorithmAESGCM 
                                       withKey:key 
                                         error:&error];

// Encrypt with explicit format
NSString *encryptedV0 = [MBSCipher encryptString:@"Secret message"
                                   withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV0)
                                       withKey:key
                                        error:&error];

// Decrypt automatically handles the format
NSString *decrypted = [MBSCipher decryptString:encrypted
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                       withKey:key
                                         error:&error];
```

#### File Encryption
```objectivec
NSURL *sourceURL = [NSURL fileURLWithPath:@"source.txt"];
NSURL *encryptedURL = [NSURL fileURLWithPath:@"encrypted.bin"];
NSURL *decryptedURL = [NSURL fileURLWithPath:@"decrypted.txt"];

NSError *error = nil;
NSData *key = [MBSRandom generateBytes:32 error:&error];

// Encrypt file (format V0: [12-byte nonce][ciphertext][16-byte tag])
[MBSCipher encryptFile:sourceURL
              toOutput:encryptedURL
         withAlgorithm:MBSCipherAlgorithmAESGCM
               withKey:key
                 error:&error];

// Decrypt file
[MBSCipher decryptFile:encryptedURL
              toOutput:decryptedURL
         withAlgorithm:MBSCipherAlgorithmAESGCM
               withKey:key
                 error:&error];
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

