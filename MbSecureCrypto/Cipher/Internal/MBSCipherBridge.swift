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
    
    @objc
    public static func encryptString(_ string: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     format: MBSCipherFormat,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        do {
            guard let data = string.data(using: .utf8) else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 202, // MBSCipherErrorInvalidInput
                                         userInfo: [NSLocalizedDescriptionKey: "Failed to encode string as UTF-8"])
                return nil
            }
            
            guard key.count == 32 else { // AES-256
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 200, // MBSCipherErrorInvalidKey
                                         userInfo: [NSLocalizedDescriptionKey: "Key must be 32 bytes for AES-256"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            var encryptedData: Data
            
            // Use raw value 0 for V0 format
            if format.rawValue == 0 {
                encryptedData = try encryptFormatV0(data: data, key: symmetricKey)
            } else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 204, // Unknown or unsupported format version
                                         userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
                return nil
            }
            
            return encryptedData.base64EncodedString()
            
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 210, // MBSCipherErrorEncryptionFailed
                                         userInfo: [NSLocalizedDescriptionKey: "Encryption failed: \(aError.localizedDescription)"])
            }
            return nil
        }
    }
    
    private static func decryptFormatV0(data: Data, key: SymmetricKey) throws -> Data {
        guard data.count >= 28 else {
            throw NSError(domain: MBSErrorDomain,
                          code: 202, // MBSCipherErrorInvalidInput
                          userInfo: [NSLocalizedDescriptionKey: "Encrypted data too short"])
        }
        
        let nonceData = data.prefix(12)
        let tagData = data.suffix(16)
        let ciphertext = data.dropFirst(12).dropLast(16)
        
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                              ciphertext: ciphertext,
                                              tag: tagData)
        
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    @objc
    public static func decryptString(_ encryptedString: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
                                     format: MBSCipherFormat,
                                     error: UnsafeMutablePointer<NSError?>?) -> String? {
        do {
            guard let combined = Data(base64Encoded: encryptedString) else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 202, // MBSCipherErrorInvalidInput
                                         userInfo: [NSLocalizedDescriptionKey: "Invalid base64 input"])
                return nil
            }
            
            // Validate minimum size (12 byte nonce + 16 byte tag)
            // Note: removed the +1 for data since empty data is valid
            guard combined.count >= 28 else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 202, // MBSCipherErrorInvalidInput
                                         userInfo: [NSLocalizedDescriptionKey: "Encrypted data too short"])
                return nil
            }
            
            guard key.count == 32 else { // AES-256
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 200, // MBSCipherErrorInvalidKey
                                         userInfo: [NSLocalizedDescriptionKey: "Key must be 32 bytes for AES-256"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            let decryptedData: Data
            
            if format.rawValue == 0 {
                decryptedData = try decryptFormatV0(data: combined, key: symmetricKey)
            } else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 204,
                                         userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
                return nil
            }
            
            return String(data: decryptedData, encoding: .utf8) ?? ""
            
            
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 211, // MBSCipherErrorDecryptionFailed
                                         userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(aError.localizedDescription)"])
            }
            return nil
        }
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
            
            if format.rawValue == 0 {
                return try encryptFormatV0(data: data, key: symmetricKey)
            } else {
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
            
            // Validate minimum size (12 byte nonce + 16 byte tag)
            guard encryptedData.count >= 28 else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 202, // MBSCipherErrorInvalidInput
                                         userInfo: [NSLocalizedDescriptionKey: "Encrypted data too short"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            
            if format.rawValue == 0 {
                return try decryptFormatV0(data: encryptedData, key: symmetricKey)
            } else {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 204,
                                         userInfo: [NSLocalizedDescriptionKey: "Unsupported format version"])
                return nil
            }
            
            
            
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 211, // MBSCipherErrorDecryptionFailed
                                         userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(aError.localizedDescription)"])
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
