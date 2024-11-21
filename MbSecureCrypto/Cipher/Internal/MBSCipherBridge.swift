//
//  MBSCipherBridge.swift
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 11/11/24.
//
import Foundation
import CryptoKit

@objcMembers
public class MBSCipherBridge: NSObject {
    
    private static func encryptFormatV0(data: Data, key: SymmetricKey) throws -> Data {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        
        var combined = Data()
        combined.append(nonce.withUnsafeBytes { Data($0) })
        combined.append(sealedBox.ciphertext)
        combined.append(sealedBox.tag)
        return combined
    }
    
    private static func decryptFormatV0(data: Data, key: SymmetricKey) throws -> Data {
        guard data.count >= 28 else {
            throw NSError(domain: MBSErrorDomain,
                          code: 202, // MBSCipherErrorInvalidInput
                          userInfo: [NSLocalizedDescriptionKey: "Encrypted data too short"])
        }
        
        // Check if this might be V1 format
        if data.prefix(4) == FormatV1.magicBytes {
            throw NSError(domain: MBSErrorDomain,
                          code: 206, // MBSCipherErrorFormatMismatch
                          userInfo: [NSLocalizedDescriptionKey: "Data appears to be V1 format but V0 was requested"])
        }
        
        // V0 Format parsing: [nonce(12)][ciphertext(variable)][tag(16)]
        let nonceData = data.prefix(12)
        let tagData = data.suffix(16)
        let ciphertext = data.dropFirst(12).dropLast(16)
        
        do {
            let nonce = try AES.GCM.Nonce(data: nonceData)
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                                  ciphertext: ciphertext,
                                                  tag: tagData)
            
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            // Map CryptoKit errors to our error domain
            throw NSError(domain: MBSErrorDomain,
                          code: 211, // MBSCipherErrorDecryptionFailed
                          userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(error.localizedDescription)"])
        }
    }
    
    // V1 Format handling
    private struct FormatV1 {
        static let magicBytes = "SECB".data(using: .ascii)!
        static let version: UInt8 = 0x01
        static let headerSize = 8 // MAGIC(4) + VERSION(1) + ALG(1) + PARAMS_LEN(2)
        
        // V1 Format Algorithm IDs (different from internal enum values)
        struct AlgorithmID {
            static let aesGCM: UInt8 = 0x01
            static let aesCBC: UInt8 = 0x02
            static let aesCTR: UInt8 = 0x03
            static let chaCha20Poly1305: UInt8 = 0x11
        }
        
        // Map internal algorithm enum to V1 format algorithm ID
        static func formatAlgorithmID(_ algorithm: MBSCipherAlgorithm) -> UInt8 {
            // MBSCipherAlgorithmAESGCM = 0
            return AlgorithmID.aesGCM  // Always map internal 0 to format 0x01
        }
        
        // Map V1 format algorithm ID back to internal enum
        static func internalAlgorithm(_ formatID: UInt8) throws -> MBSCipherAlgorithm {
            switch formatID {
            case AlgorithmID.aesGCM:
                return MBSCipherAlgorithm(rawValue: 0)! // MBSCipherAlgorithmAESGCM
            default:
                throw NSError(domain: MBSErrorDomain,
                              code: 203, // MBSCipherErrorUnsupportedAlgorithm
                              userInfo: [NSLocalizedDescriptionKey: "Unsupported algorithm in V1 format"])
                
            }
        }
        
        static let aesGCMParamsSize = 16 // IV(12) + TAG_LENGTH(4)
        
        static func encodeHeader(algorithm: MBSCipherAlgorithm, paramsLength: UInt16) -> Data {
            var header = Data()
            header.append(magicBytes)
            header.append(version)
            header.append(formatAlgorithmID(algorithm))  // Convert to V1 format ID
            // Encode params length as big-endian
            header.append(UInt8(paramsLength >> 8))
            header.append(UInt8(paramsLength & 0xFF))
            return header
        }
        
        static func validateHeader(_ data: Data) throws -> (algorithm: MBSCipherAlgorithm, paramsLength: UInt16) {
            // Check minimum data size
            guard data.count >= headerSize else {
                throw NSError(domain: MBSErrorDomain,
                              code: 202, // MBSCipherErrorInvalidInput
                              userInfo: [NSLocalizedDescriptionKey: "Header data too short"])
            }
            
            // Validate magic bytes
            let magic = data.prefix(4)
            guard magic == magicBytes else {
                throw NSError(domain: MBSErrorDomain,
                              code: 206, // MBSCipherErrorFormatDetectionFailed
                              userInfo: [NSLocalizedDescriptionKey: "Invalid magic bytes"])
            }
            
            // Validate version
            let ver = data[4]
            guard ver == version else {
                throw NSError(domain: MBSErrorDomain,
                              code: 204, // MBSCipherErrorUnsupportedFormat
                              userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
            }
            
            // Get algorithm and convert to internal enum
            let formatAlg = data[5]
            let algorithm = try internalAlgorithm(formatAlg)
            
            // Get params length (big-endian)
            let paramsLength = (UInt16(data[6]) << 8) | UInt16(data[7])
            
            return (algorithm, paramsLength)
        }
    }
    
    
    
    
    private static func encryptFormatV1(data: Data, key: SymmetricKey) throws -> Data {
        // 1. Generate a random nonce for AES-GCM
        let nonce = AES.GCM.Nonce()
        let tagLength: UInt32 = 128 // GCM tag length in bits (16 bytes)
        
        // 2. Create algorithm parameters block
        // [IV(12)][TAG_LEN(4)]
        var params = Data()
        params.append(nonce.withUnsafeBytes { Data($0) })
        // Convert tag length to big endian bytes
        let tagLengthBE = tagLength.bigEndian
        params.append(withUnsafeBytes(of: tagLengthBE) { Data($0) })
        
        // 3. Create the V1 header:
        // [MAGIC(4)][VERSION(1)][ALGORITHM(1)][PARAMS_LENGTH(2)]
        let header = FormatV1.encodeHeader(
            algorithm: MBSCipherAlgorithm(rawValue: 0)!, // MBSCipherAlgorithmAESGCM
            paramsLength: UInt16(FormatV1.aesGCMParamsSize)
        )
        
        // 4. Perform encryption
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        
        // 5. Assemble final format:
        // [HEADER][PARAMS][CIPHERTEXT][TAG]
        var result = Data()
        result.append(header)          // 8 bytes
        result.append(params)          // 16 bytes
        result.append(sealedBox.ciphertext)
        result.append(sealedBox.tag)   // 16 bytes
        
        return result
    }
    
    private static func decryptFormatV1(data: Data, key: SymmetricKey) throws -> Data {
        // 1. Ensure minimum size:
        // Header(8) + Params(16) + Tag(16) = 40 bytes minimum
        guard data.count >= 40 else {
            throw NSError(domain: MBSErrorDomain,
                          code: 202, // MBSCipherErrorInvalidInput
                          userInfo: [NSLocalizedDescriptionKey: "V1 format data too short"])
        }
        
        // 2. Parse and validate header
        let (algorithm, paramsLength) = try FormatV1.validateHeader(data)
        
        // 3. Verify we have a supported algorithm
        guard algorithm.rawValue == 0 else { // MBSCipherAlgorithmAESGCM
            throw NSError(domain: MBSErrorDomain,
                          code: 204, // MBSCipherErrorUnsupportedFormat
                          userInfo: [NSLocalizedDescriptionKey: "Unsupported algorithm in V1 format"])
        }
        
        // 4. Parse parameters block
        let paramsStart = FormatV1.headerSize
        let paramsEnd = paramsStart + Int(paramsLength)
        let params = data[paramsStart..<paramsEnd]
        
        // 5. Extract nonce and validate tag length
        guard params.count == FormatV1.aesGCMParamsSize else {
            throw NSError(domain: MBSErrorDomain,
                          code: 208, // MBSCipherErrorInvalidParams
                          userInfo: [NSLocalizedDescriptionKey: "Invalid parameter length in V1 format"])
        }
        
        let nonceData = params.prefix(12)
        let tagLengthData = params.suffix(4)
        
        // Convert 4 bytes to UInt32 (big endian)
        let tagLength: UInt32 = tagLengthData.withUnsafeBytes { bytes in
            let value = bytes.load(fromByteOffset: 0, as: UInt32.self)
            return UInt32(bigEndian: value)
        }
        
        // Verify tag length is 128 bits
        guard tagLength == 128 else {
            throw NSError(domain: MBSErrorDomain,
                          code: 208, // MBSCipherErrorInvalidParams
                          userInfo: [NSLocalizedDescriptionKey: "Invalid tag length in V1 format"])
        }
        
        // 6. Extract ciphertext and tag
        let ciphertext = data[paramsEnd..<(data.count - 16)]
        let tag = data.suffix(16)
        
        // 7. Create sealed box and decrypt
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                              ciphertext: ciphertext,
                                              tag: tag)
        
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    
    @objc
    public static func encryptString(_ string: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     format: MBSCipherFormat,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        
        guard let data = string.data(using: .utf8) else {
            error?.pointee = NSError(domain: MBSErrorDomain,
                                     code: 202, // MBSCipherErrorInvalidInput
                                     userInfo: [NSLocalizedDescriptionKey: "Failed to encode string as UTF-8"])
            return nil
        }
        
        // Reuse encryptData implementation
        guard let encryptedData = encryptData(data,
                                              key: key,
                                              algorithm: algorithm,
                                              format: format,
                                              error: error) else {
            return nil
        }
        
        return encryptedData.base64EncodedString()
        
        
    }
    
    @objc
    public static func decryptString(_ encryptedString: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     format: MBSCipherFormat,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        
        guard let combined = Data(base64Encoded: encryptedString) else {
            error?.pointee = NSError(domain: MBSErrorDomain,
                                     code: 202, // MBSCipherErrorInvalidInput
                                     userInfo: [NSLocalizedDescriptionKey: "Invalid base64 input"])
            return nil
        }
        
        // Reuse decryptData implementation
        guard let decryptedData = decryptData(combined,
                                              key: key,
                                              algorithm: algorithm,
                                              format: format,
                                              error: error) else {
            return nil
        }
        
        // Convert decrypted data back to string
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            error?.pointee = NSError(domain: MBSErrorDomain,
                                     code: 202, // MBSCipherErrorInvalidInput
                                     userInfo: [NSLocalizedDescriptionKey: "Failed to decode result as UTF-8"])
            return nil
        }
        
        return result
        
        
    }
    
    @objc
    public static func encryptData(_ data: Data,
                                   key: Data,
                                   algorithm: MBSCipherAlgorithm,
                                   format: MBSCipherFormat,
                                   error: UnsafeMutablePointer<NSError?>?) -> Data? {
        do {
            guard key.count == 32 else { // AES-256
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 200, // MBSCipherErrorInvalidKey
                                         userInfo: [NSLocalizedDescriptionKey: "Key must be 32 bytes for AES-256"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            
            switch format.rawValue {
            case 0:  // MBSCipherFormatV0
                return try encryptFormatV0(data: data, key: symmetricKey)
            case 1:  // MBSCipherFormatV1
                return try encryptFormatV1(data: data, key: symmetricKey)
            default:
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 204,
                                         userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
                return nil
            }
            
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 210, // MBSCipherErrorEncryptionFailed
                                         userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(aError.localizedDescription)"])
            }
            return nil
        }
    }
    
    @objc
    public static func decryptData(_ encryptedData: Data,
                                   key: Data,
                                   algorithm: MBSCipherAlgorithm,
                                   format: MBSCipherFormat,
                                   error: UnsafeMutablePointer<NSError?>?) -> Data? {
        do {
            guard key.count == 32 else { // AES-256
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 200, // MBSCipherErrorInvalidKey
                                         userInfo: [NSLocalizedDescriptionKey: "Key must be 32 bytes for AES-256"])
                return nil
            }
            
            // Minimum size check depends on format
            let minSize = format.rawValue == 1 ? 40 : 28  // V1: 8(header) + 16(params) + 16(tag), V0: 12(nonce) + 16(tag)
            guard encryptedData.count >= minSize else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 202, // MBSCipherErrorInvalidInput
                                         userInfo: [NSLocalizedDescriptionKey: "Encrypted data too short"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            
            // Process according to specified format
            switch format.rawValue {
            case 0:  // MBSCipherFormatV0
                return try decryptFormatV0(data: encryptedData, key: symmetricKey)
            case 1:  // MBSCipherFormatV1
                return try decryptFormatV1(data: encryptedData, key: symmetricKey)
            default:
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 204,
                                         userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
                return nil
            }
            
        } catch let aError as NSError {
            if error != nil {
                // Preserve original error code if it's from our domain
                if aError.domain == MBSErrorDomain {
                    error?.pointee = aError
                } else {
                    // Only wrap unknown errors as DecryptionFailed
                    error?.pointee = NSError(domain: MBSErrorDomain,
                                             code: 211, // MBSCipherErrorDecryptionFailed
                                             userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(aError.localizedDescription)"])
                }
            }
            return nil
        }
    }
    
    // Need to implement the legacy methods without format parameter
    @objc
    public static func encryptString(_ string: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        // Call the format-aware method with V0 format
        return encryptString(string, key: key, algorithm: algorithm, format: .init(rawValue: 0)!, error: error)
    }
    
    @objc
    public static func decryptString(_ encryptedString: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        // Call the format-aware method with V0 format
        return decryptString(encryptedString, key: key, algorithm: algorithm, format: .init(rawValue: 0)!, error: error)
    }
    
    // Legacy methods for backward compatibility
    @objc
    public static func encryptData(_ data: Data,
                                   key: Data,
                                   algorithm: MBSCipherAlgorithm,
                                   error: UnsafeMutablePointer<NSError?>?) -> Data? {
        return encryptData(data, key: key, algorithm: algorithm, format: .init(rawValue: 0)!, error: error)
    }
    
    @objc
    public static func decryptData(_ encryptedData: Data,
                                   key: Data,
                                   algorithm: MBSCipherAlgorithm,
                                   error: UnsafeMutablePointer<NSError?>?) -> Data? {
        return decryptData(encryptedData, key: key, algorithm: algorithm, format: .init(rawValue: 0)!, error: error)
    }
    
}
