//
//  MBSCipherTests.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 11/11/24.
//

#import <XCTest/XCTest.h>
#import "MbSecureCrypto.h"

@interface MBSCipherTests : XCTestCase
@end

@implementation MBSCipherTests

// MBSCipherTests.m - Updated testEncryptString method

- (void)testEncryptString {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test string
    NSString *original = @"Hello, Encryption!";
    
    // Encrypt
    NSString *encrypted = [MBSCipher encryptString:original
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:key
                                             error:&error];
    
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    XCTAssertNotEqualObjects(original, encrypted);
    XCTAssertTrue([encrypted length] > 0);

    
    // Test empty key
    XCTAssertNil([MBSCipher encryptString:original
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:[NSData data]
                                    error:&error]);
    XCTAssertNotNil(error);
}

// Add a new test specifically for empty string
- (void)testEncryptEmptyString {
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Encrypt empty string
    NSString *encrypted = [MBSCipher encryptString:@""
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:key
                                             error:&error];
    
    // Should succeed
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    XCTAssertTrue([encrypted length] >= 28);  // At least nonce + tag size in base64
    
    // Decrypt and verify
    NSString *decrypted = [MBSCipher decryptString:encrypted
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:key
                                             error:&error];
    
    XCTAssertNotNil(decrypted);
    XCTAssertNil(error);
    XCTAssertEqualObjects(decrypted, @"");
}
- (void)testEncryptDecryptRoundTrip {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test strings
    NSString *longString = [@"" stringByPaddingToLength:10000
                                             withString:@"A"
                                        startingAtIndex:0];
    
    NSArray *testStrings = @[
        @"Hello, Encryption!",
        @"",  // Empty string
        @"🔐🌍💻",  // Unicode/Emoji
        longString  // Long string
    ];
    
    for (NSString *original in testStrings) {
        // Encrypt
        error = nil;  // Reset error state
        NSString *encrypted = [MBSCipher encryptString:original
                                         withAlgorithm:MBSCipherAlgorithmAESGCM
                                               withKey:key
                                                 error:&error];
        
        XCTAssertNotNil(encrypted);
        XCTAssertNil(error);
        
        // Decrypt
        error = nil;  // Reset error state
        NSString *decrypted = [MBSCipher decryptString:encrypted
                                         withAlgorithm:MBSCipherAlgorithmAESGCM
                                               withKey:key
                                                 error:&error];
        
        XCTAssertNotNil(decrypted);
        XCTAssertNil(error);
        XCTAssertEqualObjects(original, decrypted);
    }
}

- (void)testEncryptData {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test data
    NSData *original = [@"Hello, Data Encryption!" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Encrypt
    NSData *encrypted = [MBSCipher encryptData:original
                                 withAlgorithm:MBSCipherAlgorithmAESGCM
                                       withKey:key
                                         error:&error];
    
    XCTAssertNotNil(encrypted);
    XCTAssertNil(error);
    XCTAssertNotEqualObjects(original, encrypted);
    XCTAssertTrue(encrypted.length > 28); // At least nonce + tag size
    
}

- (void)testEncryptDataRoundTrip {
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Test different data sizes
    NSArray *testData = @[
        [@"Small data" dataUsingEncoding:NSUTF8StringEncoding],
        [NSData data], // Empty data
        [[[@"" stringByPaddingToLength:10000 withString:@"A" startingAtIndex:0]
          dataUsingEncoding:NSUTF8StringEncoding] mutableCopy], // Large data
        [MBSRandom generateBytes:1024 error:&error] // Random data
    ];
    
    for (NSData *original in testData) {
        // Encrypt
        error = nil;
        NSData *encrypted = [MBSCipher encryptData:original
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:key
                                             error:&error];
        
        XCTAssertNotNil(encrypted);
        XCTAssertNil(error);
        
        // Decrypt
        error = nil;
        NSData *decrypted = [MBSCipher decryptData:encrypted
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:key
                                             error:&error];
        
        XCTAssertNotNil(decrypted);
        XCTAssertNil(error);
        XCTAssertEqualObjects(original, decrypted);
    }
}


- (void)testEncryptDecryptFile {
    // Create a temporary directory for test files
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *sourceURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_source.txt"];
    NSURL *encryptedURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_encrypted.bin"];
    NSURL *decryptedURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_decrypted.txt"];
    
    // Generate a test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Create test content
    NSString *testContent = @"Test file content for encryption!";
    NSData *testData = [testContent dataUsingEncoding:NSUTF8StringEncoding];
    
    // Write test file
    XCTAssertTrue([testData writeToURL:sourceURL atomically:YES]);
    
    // Test encryption
    error = nil;
    BOOL encryptSuccess = [MBSCipher encryptFile:sourceURL
                                        toOutput:encryptedURL
                                   withAlgorithm:MBSCipherAlgorithmAESGCM
                                         withKey:key
                                           error:&error];
    
    XCTAssertTrue(encryptSuccess);
    XCTAssertNil(error);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:encryptedURL.path]);
    
    // Test decryption
    error = nil;
    BOOL decryptSuccess = [MBSCipher decryptFile:encryptedURL
                                        toOutput:decryptedURL
                                   withAlgorithm:MBSCipherAlgorithmAESGCM
                                         withKey:key
                                           error:&error];
    
    XCTAssertTrue(decryptSuccess);
    XCTAssertNil(error);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:decryptedURL.path]);
    
    // Verify content
    NSString *decryptedContent = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:decryptedURL]
                                                       encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(testContent, decryptedContent);
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtURL:sourceURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:encryptedURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:decryptedURL error:nil];
}

- (void)testEncryptLargeFile {
    // Create a temporary directory for test files
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *sourceURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_large.txt"];
    NSURL *encryptedURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_large_encrypted.bin"];
    
    // Generate test key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    XCTAssertNil(error);
    
    // Create large test file (11MB)
    NSMutableData *largeData = [NSMutableData dataWithLength:11 * 1024 * 1024];
    XCTAssertTrue([largeData writeToURL:sourceURL atomically:YES]);
    
    // Test encryption should fail due to size
    error = nil;
    BOOL encryptSuccess = [MBSCipher encryptFile:sourceURL
                                        toOutput:encryptedURL
                                   withAlgorithm:MBSCipherAlgorithmAESGCM
                                         withKey:key
                                           error:&error];
    
    XCTAssertFalse(encryptSuccess);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorFileTooLarge);
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtURL:sourceURL error:nil];
}

- (void)testEncryptFileWithInvalidInputs {
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *validURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test.txt"];
    
    // Create a small test file
    [@"Test" writeToURL:validURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Generate valid key
    NSError *error = nil;
    NSData *key = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(key);
    
    // Test empty key
    error = nil;
    XCTAssertFalse([MBSCipher encryptFile:validURL
                                 toOutput:validURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:[NSData data]
                                    error:&error]);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidKey);
    
    // Test non-existent source file
    NSURL *nonExistentURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"nonexistent.txt"];
    error = nil;
    XCTAssertFalse([MBSCipher encryptFile:nonExistentURL
                                 toOutput:validURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:key
                                    error:&error]);
    XCTAssertEqual(error.code, MBSCipherErrorIOFailure);
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtURL:validURL error:nil];
}

- (void)testDecryptFileWithInvalidInputs {
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *validURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_encrypted.bin"];
    NSURL *decryptedURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"test_decrypted.txt"];
    
    // Create a valid encrypted file first
    NSError *error = nil;
    NSData *validKey = [MBSRandom generateBytes:32 error:&error];
    NSString *testString = @"Test";
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Encrypt with valid key first
    NSData *encryptedData = [MBSCipher encryptData:testData
                                     withAlgorithm:MBSCipherAlgorithmAESGCM
                                           withKey:validKey
                                             error:&error];
    XCTAssertNotNil(encryptedData);
    [encryptedData writeToURL:validURL atomically:YES];
    
    // Test invalid key size
    NSData *invalidKey = [MBSRandom generateBytes:16 error:&error]; // Wrong size for AES-256
    error = nil;
    XCTAssertFalse([MBSCipher decryptFile:validURL
                                 toOutput:decryptedURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:invalidKey
                                    error:&error]);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidKey);
    
    // Test corrupted encrypted file
    NSURL *corruptedURL = [[NSURL fileURLWithPath:tempDir] URLByAppendingPathComponent:@"corrupted.bin"];
    NSData *corruptedData = [NSData dataWithBytes:"InvalidCiphertext" length:28]; // Minimum size for nonce + tag
    [corruptedData writeToURL:corruptedURL atomically:YES];
    
    error = nil;
    XCTAssertFalse([MBSCipher decryptFile:corruptedURL
                                 toOutput:decryptedURL
                            withAlgorithm:MBSCipherAlgorithmAESGCM
                                  withKey:validKey
                                    error:&error]);
    XCTAssertEqual(error.code, MBSCipherErrorDecryptionFailed);
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtURL:validURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:corruptedURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:decryptedURL error:nil];
}
@end
