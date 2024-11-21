//
//  MBSCipherTests1.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 21/11/24.
//

#import <XCTest/XCTest.h>
#import "MbSecureCrypto.h"

@interface MBSCipherTests1 : XCTestCase
@end

@implementation MBSCipherTests1

#pragma mark - Parameter Validation Tests

- (void)testEncryptDataWithFormatV1 {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test data
    NSData *original = [@"Hello, Format V1 Encryption!" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Encrypt with explicit format V1
    NSData *encrypted = [MBSCipher encryptData:original
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV1)
                                       withKey:key
                                         error:&error];
    
    // Validate basic encryption success
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    XCTAssertNotEqualObjects(original, encrypted);
    
    // Validate format V1 structure
    XCTAssertTrue(encrypted.length >= 8); // Minimum header size
    
    // Validate magic bytes
    const char *bytes = encrypted.bytes;
    NSData *magicBytes = [encrypted subdataWithRange:NSMakeRange(0, 4)];
    XCTAssertEqualObjects([[NSString alloc] initWithData:magicBytes encoding:NSASCIIStringEncoding], @"SECB");
    
    // Validate version byte
    uint8_t version = bytes[4];
    XCTAssertEqual(version, MBSCipherFormatV1);
    
    // Validate algorithm byte - should be 0x01 in the format regardless of enum value
    uint8_t formatAlgorithm = bytes[5];
    XCTAssertEqual(formatAlgorithm, 0x01);  // Check for format spec value, not enum value
    
    // Validate params length (2 bytes, big-endian)
    uint16_t paramsLength = (bytes[6] << 8) | bytes[7];
    XCTAssertEqual(paramsLength, 16); // AES-GCM params size (12B IV + 4B tag length)
    
    // Full encrypted data should be at least header + params + tag size
    XCTAssertTrue(encrypted.length >= (8 + paramsLength + original.length + 16));
}


- (void)testFormatV1AlgorithmMapping {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    NSData *testData = [@"Test data" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Encrypt with Format V1 explicitly
    NSData *encrypted = [MBSCipher encryptData:testData
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV1)
                                       withKey:key
                                         error:&error];
    
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    
    // Verify the format structure
    const uint8_t *bytes = encrypted.bytes;
    XCTAssertEqual(bytes[0], 'S');  // Magic bytes
    XCTAssertEqual(bytes[1], 'E');
    XCTAssertEqual(bytes[2], 'C');
    XCTAssertEqual(bytes[3], 'B');
    XCTAssertEqual(bytes[4], MBSCipherFormatV1);  // Version
    XCTAssertEqual(bytes[5], 0x01);  // Algorithm ID in format
    
    // Test decryption with explicit format only
    NSData *decrypted = [MBSCipher decryptData:encrypted
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                    withFormat:@(MBSCipherFormatV1)
                                       withKey:key
                                         error:&error];
    
    XCTAssertNotNil(decrypted);
    XCTAssertNil(error);
    XCTAssertEqualObjects(testData, decrypted);
    
    // Test that omitting format parameter fails
    error = nil;
    NSData *shouldFail = [MBSCipher decryptData:encrypted
                                  withAlgorithm:MBSCipherAlgorithmAESGCM
                                        withKey:key
                                          error:&error];
    
    XCTAssertNil(shouldFail);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorFormatMismatch);
}


#pragma mark - String Encryption Tests

- (void)testEncryptStringWithFormatV1 {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test string
    NSString *original = @"Hello, Format V1 String Encryption! 🔐";
    
    // Encrypt with explicit format V1
    NSString *encrypted = [MBSCipher encryptString:original
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                        withFormat:@(MBSCipherFormatV1)
                                           withKey:key
                                             error:&error];
    
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    XCTAssertNotEqualObjects(original, encrypted);
    
    // Decrypt and verify
    NSString *decrypted = [MBSCipher decryptString:encrypted
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                        withFormat:@(MBSCipherFormatV1)
                                           withKey:key
                                             error:&error];
    
    XCTAssertNotNil(decrypted);
    XCTAssertNil(error);
    XCTAssertEqualObjects(original, decrypted);
    
    // Validate format structure by decoding base64
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encrypted options:0];
    XCTAssertNotNil(encryptedData);
    
    const uint8_t *bytes = encryptedData.bytes;
    
    // Check header structure
    NSData *magicBytes = [encryptedData subdataWithRange:NSMakeRange(0, 4)];
    XCTAssertEqualObjects([[NSString alloc] initWithData:magicBytes encoding:NSASCIIStringEncoding], @"SECB");
    XCTAssertEqual(bytes[4], MBSCipherFormatV1);
    XCTAssertEqual(bytes[5], 0x01);  // AES-GCM in format spec
}

- (void)testEncryptStringWithFormatV1SpecialCases {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    
    // Test cases
    NSArray *testStrings = @[
        @"",  // Empty string
        @"🔐🌍💻📱",  // Only emojis
        @"表ポあA鷗龥Œ深",  // Unicode characters
        @"Mixed UTF8 テスト 🔑",  // Mixed character types
        [NSString stringWithFormat:@"%@", [@"" stringByPaddingToLength:10000
                                                            withString:@"Long文字列"
                                                       startingAtIndex:0]]  // Long mixed string
    ];
    
    for (NSString *original in testStrings) {
        // Encrypt with V1 format
        error = nil;
        NSString *encrypted = [MBSCipher encryptString:original
                                         withAlgorithm:MBSCipherAlgorithmAESGCM
                                            withFormat:@(MBSCipherFormatV1)
                                               withKey:key
                                                 error:&error];
        
        XCTAssertNotNil(encrypted, @"Failed to encrypt: %@", original);
        XCTAssertNil(error);
        
        // Explicit V1 format decrypt
        error = nil;
        NSString *explicitDecrypted = [MBSCipher decryptString:encrypted
                                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                                    withFormat:@(MBSCipherFormatV1)
                                                       withKey:key
                                                         error:&error];
        
        XCTAssertNotNil(explicitDecrypted);
        XCTAssertNil(error);
        XCTAssertEqualObjects(original, explicitDecrypted);
    }
}

#pragma mark - Cross Format Compatibility Tests

- (void)testFormatV1RequiresExplicitFormat {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    NSData *testData = [@"Test data" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Try encrypting without format specification
    NSData *encrypted = [MBSCipher encryptData:testData
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                       withKey:key
                                         error:&error];
    
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    
    // Verify it's not V1 format (should be V0)
    const uint8_t *bytes = encrypted.bytes;
    XCTAssertNotEqual(bytes[0], 'S');  // Should not have SECB magic bytes
    
    // Try decrypting V0 data with V1 format should fail
    error = nil;
    NSData *shouldFail = [MBSCipher decryptData:encrypted
                                  withAlgorithm:MBSCipherAlgorithmAESGCM
                                     withFormat:@(MBSCipherFormatV1)
                                        withKey:key
                                          error:&error];
    
    XCTAssertNil(shouldFail);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidInput);
}



- (void)testFormatV1StringCrossVersionCompatibility {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    NSString *testString = @"Cross Version Test 🔑";
    
    // Encrypt with V0 (default/legacy format)
    NSString *v0Encrypted = [MBSCipher encryptString:testString
                                       withAlgorithm:MBSCipherAlgorithmAESGCM
                                             withKey:key
                                               error:&error];
    
    // Encrypt with V1 format
    NSString *v1Encrypted = [MBSCipher encryptString:testString
                                       withAlgorithm:MBSCipherAlgorithmAESGCM
                                          withFormat:@(MBSCipherFormatV1)
                                             withKey:key
                                               error:&error];
    
    // Decrypt v0 without explicit format
    NSString *v0Decrypted = [MBSCipher decryptString:v0Encrypted
                                       withAlgorithm:MBSCipherAlgorithmAESGCM
                                             withKey:key
                                               error:&error];
    // Decrypt v1 with explicit format
    NSString *v1Decrypted = [MBSCipher decryptString:v1Encrypted
                                       withAlgorithm:MBSCipherAlgorithmAESGCM
                                          withFormat:@(MBSCipherFormatV1)
                                             withKey:key
                                               error:&error];
    
    XCTAssertEqualObjects(testString, v0Decrypted);
    XCTAssertEqualObjects(testString, v1Decrypted);
    
    // Verify formats are different
    XCTAssertNotEqualObjects(v0Encrypted, v1Encrypted);
    
    // V1 should be longer due to header
    XCTAssertGreaterThan(v1Encrypted.length, v0Encrypted.length);
}





#pragma mark - Error Cases Tests

- (void)testFormatV1StringErrorCases {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    
    NSString *testString = @"Test String";
    
    // 1. Test corrupted base64
    NSString *encrypted = [MBSCipher encryptString:testString
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                        withFormat:@(MBSCipherFormatV1)
                                           withKey:key
                                             error:&error];
    
    // Corrupt the base64 string
    NSString *corruptedBase64 = [encrypted stringByAppendingString:@"!@#"];
    
    error = nil;
    XCTAssertNil([MBSCipher decryptString:corruptedBase64
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                               withFormat:@(MBSCipherFormatV1)
                                  withKey:key
                                    error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidInput);
    
    // 2. Test wrong format version expectation
    error = nil;
    NSString *v1Encrypted = [MBSCipher encryptString:testString
                                       withAlgorithm:MBSCipherAlgorithmAESGCM
                                          withFormat:@(MBSCipherFormatV1)
                                             withKey:key
                                               error:&error];
    
    error = nil;
    XCTAssertNil([MBSCipher decryptString:v1Encrypted
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                               withFormat:@(MBSCipherFormatV0)
                                  withKey:key
                                    error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorFormatMismatch);
    
    // 3. Test non-UTF8 conformant result
    // Create intentionally corrupted data that would decrypt to invalid UTF8
    NSString *validEncrypted = [MBSCipher encryptString:@"Valid"
                                          withAlgorithm:MBSCipherAlgorithmAESGCM
                                             withFormat:@(MBSCipherFormatV1)
                                                withKey:key
                                                  error:&error];
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:validEncrypted options:0];
    NSMutableData *corruptedData = [encryptedData mutableCopy];
    
    // Corrupt the ciphertext portion (after header and params)
    uint8_t *bytes = corruptedData.mutableBytes;
    bytes[24] = 0xFF;  // Corrupt a byte in the ciphertext
    
    NSString *corruptedEncrypted = [corruptedData base64EncodedStringWithOptions:0];
    
    error = nil;
    XCTAssertNil([MBSCipher decryptString:corruptedEncrypted
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:key
                                    error:&error]);
    XCTAssertNotNil(error);
}

#pragma mark - File Operations

- (void)testFormatV1FileEncryptionDecryption {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Create test directories
    NSString *testDir = NSTemporaryDirectory();
    NSURL *sourceURL = [[NSURL fileURLWithPath:testDir] URLByAppendingPathComponent:@"test.txt"];
    NSURL *encryptedURL = [[NSURL fileURLWithPath:testDir] URLByAppendingPathComponent:@"test.encrypted"];
    NSURL *decryptedURL = [[NSURL fileURLWithPath:testDir] URLByAppendingPathComponent:@"test.decrypted"];
    
    // Create test content with Unicode
    NSString *content = @"Test File Content with Unicode: 🔐🌍 And some longer text to ensure proper handling";
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    // Write test file
    XCTAssertTrue([contentData writeToURL:sourceURL atomically:YES]);
    
    // Test encryption with format V1
    XCTAssertTrue([MBSCipher encryptFile:sourceURL
                                toOutput:encryptedURL
                           withAlgorithm:MBSCipherAlgorithmAESGCM
                              withFormat:@(MBSCipherFormatV1)
                                 withKey:key
                                   error:&error]);
    XCTAssertNil(error);
    
    // Verify encrypted file exists and is larger than source
    NSData *encryptedData = [NSData dataWithContentsOfURL:encryptedURL];
    XCTAssertNotNil(encryptedData);
    XCTAssertGreaterThan(encryptedData.length, contentData.length);
    
    // Verify format V1 header structure
    const uint8_t *bytes = encryptedData.bytes;
    XCTAssertEqual(bytes[0], 'S');
    XCTAssertEqual(bytes[1], 'E');
    XCTAssertEqual(bytes[2], 'C');
    XCTAssertEqual(bytes[3], 'B');
    XCTAssertEqual(bytes[4], MBSCipherFormatV1);
    XCTAssertEqual(bytes[5], 0x01); // AES-GCM
    uint16_t paramsLength = (bytes[6] << 8) | bytes[7];
    XCTAssertEqual(paramsLength, 16);
    
    // Test decryption with format V1
    XCTAssertTrue([MBSCipher decryptFile:encryptedURL
                                toOutput:decryptedURL
                           withAlgorithm:MBSCipherAlgorithmAESGCM
                              withFormat:@(MBSCipherFormatV1)
                                 withKey:key
                                   error:&error]);
    XCTAssertNil(error);
    
    // Verify decrypted content matches original
    NSString *decryptedContent = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:decryptedURL]
                                                      encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(content, decryptedContent);
    
    // Error cases
    // 1. Attempt decryption with wrong format version
    error = nil;
    XCTAssertFalse([MBSCipher decryptFile:encryptedURL
                                 toOutput:decryptedURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                               withFormat:@(MBSCipherFormatV0)
                                  withKey:key
                                    error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorFormatMismatch);
    
    // 2. Attempt decryption without explicit format
    error = nil;
    XCTAssertFalse([MBSCipher decryptFile:encryptedURL
                                 toOutput:decryptedURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:key
                                    error:&error]);
    XCTAssertNotNil(error);
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtURL:sourceURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:encryptedURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:decryptedURL error:nil];
}

@end
