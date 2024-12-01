# Version History

## Version 0.6.0

### Added
- HMAC-based Key Derivation Function (HKDF) support via `MBSKeyDerivation`:
  - Multiple hash algorithm support (SHA-256, SHA-512, SHA-1)
  - Structured domain separation
  - Automatic nonce and salt management
  - Comprehensive input validation
- New key derivation algorithms:
  - SHA-256 (default): 128-bit security level
  - SHA-512: 256-bit security level
  - SHA-1 (legacy support)
- Domain separation format standardization:
  - Structured format: `com.mavbozo.mbsecurecrypto.<domain>.v1:<context>`
  - Version tagging for future extensibility
  - Application-specific domain isolation

### Changed
- Extended error handling framework:
  - Added `MBSCipherErrorKeyDerivationFailed` for HKDF operations
  - Enhanced error descriptions for key derivation
- Improved documentation:
  - Added DocC format documentation
  - Enhanced security considerations
  - Added key derivation examples

### Security
- Secure implementation of RFC 5869 HKDF
- Constant-time HMAC operations
- Automatic cleanup of sensitive key material
- Memory protection for cryptographic keys
- Enforced minimum key length requirements

### Compatibility
- Maintains backward compatibility with all 0.5.x releases
- No breaking changes to existing cipher and random APIs
- Requires iOS 15.6+ / macOS 12.4+



## Version 0.5.0

### Added
- Universal Secure Block Format (SECB) via `MBSCipherFormatV1` supporting:
  - Magic bytes "SECB" for format detection and validation
  - Explicit version and algorithm identification
  - Flexible algorithm parameters
  - Future algorithm extensibility
- Support for additional cipher algorithms (planned):
  - AES-CBC (0x02)
  - AES-CTR (0x03)
  - ChaCha20-Poly1305 (0x11)
- Enhanced format detection and validation

### Changed
- Improved format versioning with structured headers
- Enhanced parameter validation for V1 format
- Updated documentation with detailed format specifications
- Expanded error handling for format-specific cases

### Security
- Strengthened format validation with magic byte verification
- Added explicit algorithm identification
- Improved parameter length validation
- Enhanced error reporting for security-related failures


## Version 0.4.0

### Added
- Format versioning support via `MBSCipherFormat` enum
- New API methods with explicit format parameters
- Improved interoperability documentation
- Format versioning documentation

### Changed
- Enhanced error messages for format-related issues
- Updated documentation with format specifications

### Compatibility
- Fully backward compatible with 0.3.0
- Default format (V0) matches existing implementation

## Version 0.3.0
- Added encryption capabilities
- Added MBSRandom class
- Added comprehensive error handling
- Deprecated MBSCryptoOperation

## Version 0.2.0
- Added random bytes generation methods
- Added hex and base64 encoding options

## Version 0.1.0
- Initial release

