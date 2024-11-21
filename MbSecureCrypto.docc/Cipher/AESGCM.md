# AES-GCM

## AES-GCM Implementation Details

### Nonce and Tag Handling

The `MBSCipher` class automatically handles nonces and authentication tags:

- **Nonce Generation**: Each encryption operation generates a fresh 12-byte nonce using `MBSRandom`
- **Data Format**: Encrypted output is structured as `[nonce][ciphertext][tag]`
- **Sizing**:
  - Nonce: 12 bytes
  - Tag: 16 bytes
  - Minimum total size: 28 bytes (even for empty input)
  
### Format Details
```objc
// Encryption result structure
typedef struct {
    uint8_t nonce[12];     // Random nonce
    uint8_t ciphertext[];  // Encrypted data (variable length)
    uint8_t tag[16];       // Authentication tag
} MBSEncryptedData;
```

The decryption functions automatically extract and validate these components, ensuring authenticated decryption.

