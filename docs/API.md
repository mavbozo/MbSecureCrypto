# MbSecureCrypto API Reference

## Table of Contents
- [Overview](#overview)
- [MBSCryptoOperation Class](#mbscryptooperation-class)
  - [Random Bytes Generation](#random-bytes-generation)
  - [Random String Generation](#random-string-generation)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Version History](#version-history)

## Overview

MbSecureCrypto provides cryptographically secure random number generation capabilities for iOS and macOS applications. All methods are class methods on the `MBSCryptoOperation` class and are thread-safe.

## MBSCryptoOperation Class

### Random Bytes Generation

#### `+ (nullable NSData *)randomBytes:(NSInteger)numBytes error:(NSError **)error`

Generates a specified number of cryptographically secure random bytes.

**Parameters:**
- `numBytes`: The number of random bytes to generate. Must be greater than 0.
- `error`: On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.

**Returns:**
- An `NSData` object containing the requested number of random bytes, or nil if an error occurred.

**Example Usage:**
```objectivec
NSError *error = nil;
NSData *randomData = [MBSCryptoOperation randomBytes:32 error:&error];
if (randomData) {
    // Use the random data
} else {
    NSLog(@"Error generating random bytes: %@", error);
}
```

#### `+ (nullable NSString *)randomBytesAsHex:(NSInteger)numBytes error:(NSError **)error`

Generates random bytes and returns them as a hexadecimal string.

**Parameters:**
- `numBytes`: The number of random bytes to generate. Must be greater than 0.
- `error`: On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information.

**Returns:**
- A string of length 2*numBytes containing the hexadecimal representation of the random bytes, or nil if an error occurred.

**Example Usage:**
```objectivec
NSError *error = nil;
NSString *hexString = [MBSCryptoOperation randomBytesAsHex:16 error:&error];
if (hexString) {
    // hexString will be 32 characters long (16 bytes * 2)
    NSLog(@"Random hex string: %@", hexString);
}
```

#### `+ (nullable NSString *)randomBytesAsBase64:(NSInteger)numBytes error:(NSError **)error`

Generates random bytes and returns them encoded as a base64 string.

**Parameters:**
- `numBytes`: The number of random bytes to generate. Must be greater than 0.
- `error`: On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information.

**Returns:**
- A base64 encoded string representing the random bytes, or nil if an error occurred.

**Example Usage:**
```objectivec
NSError *error = nil;
NSString *base64String = [MBSCryptoOperation randomBytesAsBase64:24 error:&error];
if (base64String) {
    NSLog(@"Random base64 string: %@", base64String);
}
```

### Random String Generation

#### `+ (nullable NSString *)randomStringWithLength:(NSInteger)length error:(NSError **)error`

> ⚠️ Deprecated in version 0.2.0. Will be removed in version 1.0.0.
> Use `randomBytesAsHex:error:` or `randomBytesAsBase64:error:` instead.

Generates a random string of specified length.

**Parameters:**
- `length`: The desired length of the random string. Must be greater than 0.
- `error`: On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information.

**Returns:**
- A string of the specified length containing random characters, or nil if an error occurred.

**Example Usage:**
```objectivec
NSError *error = nil;
NSString *randomString = [MBSCryptoOperation randomStringWithLength:16 error:&error];
if (randomString) {
    NSLog(@"Random string: %@", randomString);
}
```

## Error Handling

All methods in MbSecureCrypto use the following error domain and codes:

**Error Domain:** `com.mbsecurecrypto`

**Error Codes:**
- `100`: Invalid input (number of bytes must be greater than 0)
- `101`: Random number generation failed
- `102`: Memory allocation failed

Example error handling:
```objectivec
NSError *error = nil;
NSData *randomData = [MBSCryptoOperation randomBytes:32 error:&error];
if (error) {
    switch (error.code) {
        case 100:
            NSLog(@"Invalid input provided");
            break;
        case 101:
            NSLog(@"Failed to generate random bytes");
            break;
        case 102:
            NSLog(@"Memory allocation failed");
            break;
        default:
            NSLog(@"Unknown error occurred");
            break;
    }
}
```

## Best Practices

1. **Error Handling**: Always check for errors when calling these methods. The error parameter provides detailed information about what went wrong.

2. **Memory Management**: When working with sensitive random data, zero out the memory after use:
```objectivec
NSMutableData *sensitiveData = [[MBSCryptoOperation randomBytes:32 error:&error] mutableCopy];
// Use sensitiveData
[sensitiveData resetBytesInRange:NSMakeRange(0, sensitiveData.length)];
```

3. **Thread Safety**: All methods are thread-safe and can be called from any thread.

## Version History

### Version 0.2.0
- Added `randomBytes:error:`
- Added `randomBytesAsHex:error:`
- Added `randomBytesAsBase64:error:`
- Deprecated `randomStringWithLength:error:`

### Version 0.1.0
- Initial release
- Added `randomStringWithLength:error:`
