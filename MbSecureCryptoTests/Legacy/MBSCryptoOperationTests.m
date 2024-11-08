//
//  MBSCryptoOperationTests.m
//  MbSecureCryptoTests
//
//  Created by Maverick Bozo on 29/10/24.
//

#import <XCTest/XCTest.h>
#import "MbSecureCrypto.h"

// Silence deprecation warnings for testing legacy code
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface MBSCryptoOperationTests : XCTestCase
@end

@implementation MBSCryptoOperationTests


- (void)testRandomStringGeneration {
    NSError *error = nil;
    NSInteger length = 32;
    NSString *randomString = [MBSCryptoOperation randomStringWithLength:length error:&error];
    
    // Verify no error occurred
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(randomString, "Should generate a random string");
    
    // Verify length is correct (base64 encoded)
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:randomString options:0];
    XCTAssertEqual(decodedData.length, length, "Decoded data should match requested length");
    
    // Verify we get different strings
    NSString *anotherRandom = [MBSCryptoOperation randomStringWithLength:length error:&error];
    XCTAssertNotEqualObjects(randomString, anotherRandom, "Should generate different strings");
}

- (void)testInvalidLength {
    NSError *error = nil;
    NSString *randomString = [MBSCryptoOperation randomStringWithLength:0 error:&error];
    
    XCTAssertNil(randomString, "Should not generate a string for length 0");
    XCTAssertNotNil(error, "Should generate an error for length 0");
    XCTAssertEqual(error.code, 100, "Should return correct error code");
}

- (void)testRandomBytesLength {
    NSError *error = nil;
    NSInteger numBytes = 32;
    NSData *randomData = [MBSCryptoOperation randomBytes:numBytes error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(randomData, "Should generate random data");
    XCTAssertEqual(randomData.length, numBytes, "Should match requested number of bytes");
}

- (void)testRandomBytesUniqueness {
    NSError *error = nil;
    NSInteger numBytes = 32;
    NSData *first = [MBSCryptoOperation randomBytes:numBytes error:&error];
    NSData *second = [MBSCryptoOperation randomBytes:numBytes error:&error];
    
    XCTAssertNotEqualObjects(first, second, "Sequential calls should generate different random bytes");
}

- (void)testRandomBytesAsHexLength {
    NSError *error = nil;
    NSInteger numBytes = 16;
    NSString *hexString = [MBSCryptoOperation randomBytesAsHex:numBytes error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(hexString, "Should generate hex string");
    XCTAssertEqual(hexString.length, numBytes * 2, "Hex string should be twice the number of bytes");
}

- (void)testRandomBytesAsHexFormat {
    NSError *error = nil;
    NSString *hexString = [MBSCryptoOperation randomBytesAsHex:16 error:&error];
    
    NSCharacterSet *hexCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
    NSCharacterSet *stringCharacters = [NSCharacterSet characterSetWithCharactersInString:hexString];
    
    XCTAssertTrue([hexCharacters isSupersetOfSet:stringCharacters], "Should only contain valid hex characters");
}

- (void)testRandomBytesAsBase64Decodable {
    NSError *error = nil;
    NSInteger numBytes = 15; // Non-multiple of 3 to test padding
    NSString *base64String = [MBSCryptoOperation randomBytesAsBase64:numBytes error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(base64String, "Should generate base64 string");
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    XCTAssertNotNil(decodedData, "Should be valid base64");
    XCTAssertEqual(decodedData.length, numBytes, "Decoded data should match original number of bytes");
}

- (void)testInvalidInputs {
    NSError *error = nil;
    
    XCTAssertNil([MBSCryptoOperation randomBytes:0 error:&error], "Should fail for zero bytes");
    XCTAssertNotNil(error, "Should generate error for zero bytes");
    XCTAssertEqual(error.code, 100, "Should return correct error code");
    
    error = nil;
    XCTAssertNil([MBSCryptoOperation randomBytes:-1 error:&error], "Should fail for negative bytes");
    XCTAssertNotNil(error, "Should generate error for negative bytes");
}

@end
