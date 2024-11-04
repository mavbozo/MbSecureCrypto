# MbSecureCrypto

A secure cryptography library for iOS and macOS that provides cryptographically secure random number generation with multiple encoding options.

## Requirements

- iOS 15.6+ / macOS 12.4+
- Xcode 13+
- Objective-C or Swift projects

## Changelog

### [0.2.0] - 2024-11-02
#### Added
- `randomBytes:error:` - Generate random bytes as NSData
- `randomBytesAsHex:error:` - Generate random bytes as hexadecimal string
- `randomBytesAsBase64:error:` - Generate random bytes as base64 string

#### Changed
- Improved error handling with specific error codes
- Enhanced documentation

#### Deprecated
- `randomStringWithLength:error:` - Will be removed in v1.0.0. Use `randomBytesAsHex:error:` or `randomBytesAsBase64:error:` instead

### [0.1.0] - 2024-10-29
#### Added
- Initial release
- `randomStringWithLength:error:` for generating random strings

## Features

- 🔒 Cryptographically secure random number generation using Apple's Security framework
- 📦 Multiple output formats: raw bytes, hexadecimal, and base64
- ⚡️ High-performance implementation using Apple's native APIs
- 🛡️ Side-channel attack protection
- ✅ Extensive test coverage
- 📱 iOS and macOS support

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'MbSecureCrypto', '~> 0.2.0'
```

### Swift Package Manager

Add the following dependency to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/mavbozo/MbSecureCrypto.git", from: "0.2.0")
]
```

## Migration Guide

### Upgrading from 0.1.0 to 0.2.0

If you were using `randomStringWithLength:error:`, you should migrate to one of the new methods:

#### Before (0.1.0):
```objectivec
NSString *randomString = [MBSCryptoOperation randomStringWithLength:16 error:&error];
```

#### After (0.2.0):
```objectivec
// For hex-encoded string (will be twice the length of the byte count)
NSString *hexString = [MBSCryptoOperation randomBytesAsHex:8 error:&error];  // Returns 16 characters

// For base64-encoded string
NSString *base64String = [MBSCryptoOperation randomBytesAsBase64:12 error:&error];
```

## Usage

### Objective-C

```objectivec
#import <MbSecureCrypto/MbSecureCrypto.h>

// Generate 32 random bytes
NSError *error = nil;
NSData *randomData = [MBSCryptoOperation randomBytes:32 error:&error];

// Get random bytes as hex string
NSString *hexString = [MBSCryptoOperation randomBytesAsHex:32 error:&error];

// Get random bytes as base64 string
NSString *base64String = [MBSCryptoOperation randomBytesAsBase64:32 error:&error];
```

### Swift

```swift
import MbSecureCrypto

do {
    // Generate 32 random bytes
    let randomData = try MBSCryptoOperation.randomBytes(32)
    
    // Get random bytes as hex string
    let hexString = try MBSCryptoOperation.randomBytesAsHex(32)
    
    // Get random bytes as base64 string
    let base64String = try MBSCryptoOperation.randomBytesAsBase64(32)
} catch {
    print("Cryptographic operation failed: \(error)")
}
```

## Security Considerations

- Uses `SecRandomCopyBytes` from Apple's Security framework for cryptographically secure random number generation
- Implements proper error handling and validation
- Ensures secure memory handling for sensitive data
- Protected against timing attacks through constant-time operations
- Zero-fills sensitive memory after use

## Requirements

- iOS 15.6+ / macOS 12.4+
- Xcode 13+
- Objective-C or Swift projects

## Error Handling

The library uses structured error handling with specific error codes:

- 100: Invalid input (number of bytes must be greater than 0)
- 101: Random number generation failed
- 102: Memory allocation failed

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

1. Clone the repository
2. Open `MbSecureCrypto.xcodeproj` in Xcode
3. Run the test suite to ensure everything is working

## License

Copyright (c) 2024 Maverick Bozo

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security Disclosure

If you discover any security-related issues, please email mavbozo@pm.com instead of using the issue tracker.

## Documentation

For detailed API documentation, please see our [API Reference](docs/API.md).
