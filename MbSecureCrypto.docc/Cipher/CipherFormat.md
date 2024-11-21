# Cipher Format

## Format V0 Specification

Format V0 (Default)

Used in versions 0.3.0 and earlier

The V0 format is structured as follows:
```
[12-byte nonce][ciphertext][16-byte tag]
```

Key characteristics:
- Nonce: 12 bytes, randomly generated
- Tag: 16 bytes, GCM authentication tag
- Total overhead: 28 bytes per encrypted output
- Base64 encoded for string operations
- Raw bytes for data/file operations
- No explicit version or algorithm indicators

## Format V1 Specification

### Format Structure
The cipher format consists of the following components in order:

```
[MAGIC_BYTES (4)][VERSION (1)][ALGORITHM (1)][PARAMS_LENGTH (2)][ALGORITHM_PARAMS (variable)][CIPHERTEXT (variable)][AUTH_TAG (optional)]
```

#### Header Format (Fixed 8 bytes)
| Field          | Size (bytes) | Description                                    |
|----------------|--------------|------------------------------------------------|
| MAGIC_BYTES    | 4           | ASCII "SECB" (SECure Block)                    |
| VERSION        | 1           | Format version (current: 0x01)                 |
| ALGORITHM      | 1           | Algorithm identifier                           |
| PARAMS_LENGTH  | 2           | Length of algorithm parameters (big-endian)    |

#### Algorithm Identifiers
| Algorithm          | ID    | IV Required | Auth Tag | Description               |
|-------------------|-------|-------------|----------|---------------------------|
| AES-GCM           | 0x01  | Yes         | Yes      | AES in GCM mode          |
| AES-CBC           | 0x02  | Yes         | No       | AES in CBC mode          |
| AES-CTR           | 0x03  | Yes         | No       | AES in CTR mode          |
| ChaCha20-Poly1305 | 0x11  | Yes         | Yes      | ChaCha20 with Poly1305   |

#### Algorithm Parameters
##### AES-GCM (16 bytes)
| Field      | Size (bytes) | Description                    |
|------------|--------------|--------------------------------|
| IV         | 12          | Initialization Vector          |
| TAG_LENGTH | 4           | Auth tag length in bits        |

##### AES-CBC (16 bytes)
| Field      | Size (bytes) | Description                    |
|------------|--------------|--------------------------------|
| IV         | 16          | Initialization Vector          |

##### ChaCha20-Poly1305 (16 bytes)
| Field      | Size (bytes) | Description                    |
|------------|--------------|--------------------------------|
| NONCE      | 12          | Nonce value                    |
| COUNTER    | 4           | Initial counter value          |

### Version History
| Version | Description                           |
|---------|---------------------------------------|
| 0x01    | Initial version with AES-GCM support |

### Format Details

#### Magic Bytes
- Fixed value: "SECB" (0x53454342)
- Used to identify the format and detect corruption
- ASCII encoded for easy identification

#### Version Byte
- Current version: 0x01
- Future versions must maintain backward compatibility
- Readers must reject higher versions they don't understand

#### Algorithm ID
- Single byte identifier for the cipher algorithm
- Defines required parameters and authentication tag presence
- Reserved ranges:
    - 0x00: Reserved
    - 0x01-0x0F: AES variants
    - 0x10-0x1F: ChaCha20 variants
    - 0x20-0xFF: Reserved for future use

#### Parameters Length
- 2-byte unsigned integer (big-endian)
- Maximum parameter size: 65535 bytes
- Must match the expected size for the algorithm

#### Authentication Tag
- Only present for authenticated ciphers (GCM, Poly1305)
- Always appears at the end of the ciphertext
- Size determined by algorithm and parameters
