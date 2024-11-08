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
    
    @objc
    public static func encryptString(_ string: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
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
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)
            
            // Combine nonce + ciphertext + tag
            var combined = Data()
            combined.append(nonce.withUnsafeBytes { Data($0) })
            combined.append(sealedBox.ciphertext)
            combined.append(sealedBox.tag)
            
            return combined.base64EncodedString()
            
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
    public static func decryptString(_ encryptedString: String,
                                     key: Data,
                                     algorithm: MBSCipherAlgorithm,
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
            
            // Extract components
            let nonceData = combined.prefix(12)  // AES-GCM nonce is 12 bytes
            let tagData = combined.suffix(16)    // AES-GCM tag is 16 bytes
            let ciphertext = combined.dropFirst(12).dropLast(16)  // Can be empty
            
            let symmetricKey = SymmetricKey(data: key)
            let nonce = try AES.GCM.Nonce(data: nonceData)
            
            // Create sealed box
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                                  ciphertext: ciphertext,
                                                  tag: tagData)
            
            // Decrypt
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            // For empty string, decryptedData will be empty but valid
            return String(data: decryptedData, encoding: .utf8) ?? ""  // Return empty string for empty data
            
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
                                   error: UnsafeMutablePointer<NSError?>?) -> Data? {
        do {
            guard key.count == 32 else { // AES-256
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 200, // MBSCipherErrorInvalidKey
                                         userInfo: [NSLocalizedDescriptionKey: "Key must be 32 bytes for AES-256"])
                return nil
            }
            
            let symmetricKey = SymmetricKey(data: key)
            let nonce = AES.GCM.Nonce()
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)
            
            // Combine nonce + ciphertext + tag
            var combined = Data()
            combined.append(nonce.withUnsafeBytes { Data($0) })
            combined.append(sealedBox.ciphertext)
            combined.append(sealedBox.tag)
            
            return combined
            
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
            
            
            
            // Extract components
            let nonceData = encryptedData.prefix(12)  // AES-GCM nonce is 12 bytes
            let tagData = encryptedData.suffix(16)    // AES-GCM tag is 16 bytes
            let ciphertext = encryptedData.dropFirst(12).dropLast(16)
            
            let symmetricKey = SymmetricKey(data: key)
            let nonce = try AES.GCM.Nonce(data: nonceData)
            
            // Create sealed box
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce,
                                                  ciphertext: ciphertext,
                                                  tag: tagData)
            
            // Decrypt
            return try AES.GCM.open(sealedBox, using: symmetricKey)
            
        } catch let aError as NSError {
            if error != nil {
                error?.pointee = NSError(domain: MBSErrorDomain,
                                         code: 211, // MBSCipherErrorDecryptionFailed
                                         userInfo: [NSLocalizedDescriptionKey: "Decryption failed: \(aError.localizedDescription)"])
            }
            return nil
        }
    }
    
}
