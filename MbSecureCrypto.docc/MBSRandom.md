# ``MbSecureCrypto/MBSRandom``

A secure random number generation utility class.

## Overview

MBSRandom provides cryptographically secure random number generation capabilities using Apple's Security framework. All generated random numbers are suitable for use in cryptographic operations such as key generation, nonce creation, and other security-sensitive applications.

## Topics

### Essentials
- ``generateBytes:error:``
- ``generateBytesAsHex:error:``
- ``generateBytesAsBase64:error:``

### Security Considerations
- All methods are thread-safe and can be called concurrently
- Uses SecRandomCopyBytes internally for cryptographic security
- Implements secure memory handling for sensitive data
- Returns nil and populates the error parameter on failure
