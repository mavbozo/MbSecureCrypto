# Version History

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

