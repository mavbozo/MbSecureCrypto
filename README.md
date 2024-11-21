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

For detailed documentation, please see our [MBSecureCrypto Docs](https://mavbozo.github.io/MbSecureCrypto/documentation/mbsecurecrypto?language=objc).

Select **Objective-C** on the top right of the page to view the ObjectiveC code docs.

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

### Encryption & Decryption

MbSecureCrypto provides secure encryption using AES-GCM with two format options. We recommend using Format V1 which provides enhanced algorithm flexibility and standardized parameter handling.

#### String Encryption (Recommended Approach)

use `MBSCipherFormatV1` as the format.

```objectivec
#import <MbSecureCrypto/MbSecureCrypto.h>

// Generate a random 32-byte key
NSError *error = nil;
NSData *key = [MBSRandom generateBytes:32 error:&error];

// Encrypt using Format V1 (Recommended)
NSString *encrypted = [MBSCipher encryptString:@"Secret message" 
                                 withAlgorithm:MBSCipherAlgorithmAESGCM 
                                   withFormat:@(MBSCipherFormatV1)
                                      withKey:key 
                                        error:&error];

if (error) {
    NSLog(@"Encryption failed: %@", error.localizedDescription);
    return;
}

// Decrypt with Format V1
NSString *decrypted = [MBSCipher decryptString:encrypted
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                   withFormat:@(MBSCipherFormatV1)
                                      withKey:key
                                        error:&error];
```

#### File Encryption (recommended approach)

use `MBSCipherFormatV1` as the format.

```objectivec
// File paths
NSURL *sourceURL = [NSURL fileURLWithPath:@"document.pdf"];
NSURL *encryptedURL = [NSURL fileURLWithPath:@"document.encrypted"];
NSURL *decryptedURL = [NSURL fileURLWithPath:@"document.decrypted.pdf"];

// Encrypt file using Format V1
BOOL success = [MBSCipher encryptFile:sourceURL
                            toOutput:encryptedURL
                       withAlgorithm:MBSCipherAlgorithmAESGCM
                          withFormat:@(MBSCipherFormatV1)
                             withKey:key
                               error:&error];

if (!success) {
    NSLog(@"File encryption failed: %@", error.localizedDescription);
    return;
}

// Decrypt file
success = [MBSCipher decryptFile:encryptedURL
                       toOutput:decryptedURL
                  withAlgorithm:MBSCipherAlgorithmAESGCM
                     withFormat:@(MBSCipherFormatV1)
                        withKey:key
                          error:&error];
```

#### Binary Data Encryption (recommended approach)

use `MBSCipherFormatV1` as the format.

```objectivec
// Encrypt raw data
NSData *sensitiveData = [@"Sensitive information" dataUsingEncoding:NSUTF8StringEncoding];
NSData *encryptedData = [MBSCipher encryptData:sensitiveData
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV1)
                                       withKey:key
                                         error:&error];

// Decrypt data
NSData *decryptedData = [MBSCipher decryptData:encryptedData
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV1)
                                       withKey:key
                                         error:&error];
```

#### String Encryption (old format)

if `withFormat` not provided then `MBSCipherFormatV0` is the format as default.

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

### Format V1 Benefits
The new Format V1 provides several advantages:
- Future-proof design supporting multiple algorithms
- Standardized parameter handling
- Magic bytes for format verification
- Explicit version checking
- Enhanced error detection
- Improved interoperability

We strongly recommend using Format V1 for all new implementations.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Version History

see [Version History](https://mavbozo.github.io/MbSecureCrypto/documentation/mbsecurecrypto/versionhistory?language=objc) on the documentation website.

## License

Copyright (c) 2024 Maverick Bozo

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security Disclosure

If you discover any security-related issues, please email mavbozo@pm.me instead of using the issue tracker.

