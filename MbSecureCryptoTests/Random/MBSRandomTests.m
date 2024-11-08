// MBSRandomTests.m
#import <XCTest/XCTest.h>
#import "MBSError.h"
#import "MBSRandom.h"

@interface MBSRandomTests : XCTestCase
@end

@implementation MBSRandomTests

- (void)testGenerateBytes {
    NSError *error = nil;
    NSInteger byteCount = 32;
    NSData *randomData = [MBSRandom generateBytes:byteCount error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(randomData, "Should generate random data");
    XCTAssertEqual(randomData.length, byteCount, "Should match requested byte count");
    
    // Test uniqueness
    NSData *secondData = [MBSRandom generateBytes:byteCount error:&error];
    XCTAssertNotEqualObjects(randomData, secondData, "Sequential calls should generate different bytes");
}

- (void)testGenerateBytesAsHex {
    NSError *error = nil;
    NSInteger byteCount = 16;
    NSString *hexString = [MBSRandom generateBytesAsHex:byteCount error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(hexString, "Should generate hex string");
    XCTAssertEqual(hexString.length, byteCount * 2, "Hex string should be twice the byte count");
    
    // Verify hex format
    NSCharacterSet *hexCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
    NSCharacterSet *stringCharacters = [NSCharacterSet characterSetWithCharactersInString:[hexString lowercaseString]];
    XCTAssertTrue([hexCharacters isSupersetOfSet:stringCharacters], "Should only contain valid hex characters");
}

- (void)testGenerateBytesAsBase64 {
    NSError *error = nil;
    NSInteger byteCount = 15; // Non-multiple of 3 to test padding
    NSString *base64String = [MBSRandom generateBytesAsBase64:byteCount error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(base64String, "Should generate base64 string");
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    XCTAssertNotNil(decodedData, "Should be valid base64");
    XCTAssertEqual(decodedData.length, byteCount, "Decoded data should match original byte count");
}

- (void)testErrorConditions {
    NSError *error = nil;
    
    // Test zero byteCount
    XCTAssertNil([MBSRandom generateBytes:0 error:&error], "Should fail for zero bytes");
    XCTAssertNotNil(error, "Should generate error for zero bytes");
    XCTAssertEqual(error.code, 100, "Should return correct error code");
    
    // Test negative byteCount
    error = nil;
    XCTAssertNil([MBSRandom generateBytes:-1 error:&error], "Should fail for negative bytes");
    XCTAssertNotNil(error, "Should generate error for negative bytes");
    XCTAssertEqual(error.code, 100, "Should return correct error code");
}

- (void)testBase64DecodableOutput {
    NSError *error = nil;
    NSInteger byteCount = 32;
    NSString *base64String = [MBSRandom generateBytesAsBase64:byteCount error:&error];
    
    XCTAssertNil(error, "Should not generate an error");
    XCTAssertNotNil(base64String, "Should generate a base64 string");
    
    // Verify base64 decodable
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    XCTAssertNotNil(decodedData, "Should be decodable as base64");
    XCTAssertEqual(decodedData.length, byteCount, "Decoded data should match requested byte count");
    
    // Verify uniqueness
    NSString *anotherBase64 = [MBSRandom generateBytesAsBase64:byteCount error:&error];
    XCTAssertNotEqualObjects(base64String, anotherBase64, "Should generate different strings");
}

// In MBSRandomTests.m
- (void)testByteCountLimits {
    NSError *error = nil;
    
    // Test maximum valid size
    NSData *maxData = [MBSRandom generateBytes:1024 * 1024 error:&error];
    XCTAssertNil(error, "Should not generate error at max size");
    XCTAssertNotNil(maxData, "Should generate data at max size");
    XCTAssertEqual(maxData.length, 1024 * 1024, "Should match requested size");
    
    // Test over maximum
    NSData *overData = [MBSRandom generateBytes:(1024 * 1024 + 1) error:&error];
    XCTAssertNotNil(error, "Should generate error over max size");
    XCTAssertEqual(error.code, MBSRandomErrorInvalidByteCount, "Should return correct error code");
    XCTAssertNil(overData, "Should not generate data over max size");
    
    // Test zero bytes
    error = nil;
    NSData *zeroData = [MBSRandom generateBytes:0 error:&error];
    XCTAssertNotNil(error, "Should generate error for zero bytes");
    XCTAssertEqual(error.code, MBSRandomErrorInvalidByteCount, "Should return correct error code");
    XCTAssertNil(zeroData, "Should not generate data for zero bytes");
    
    // Test negative bytes
    error = nil;
    NSData *negativeData = [MBSRandom generateBytes:-1 error:&error];
    XCTAssertNotNil(error, "Should generate error for negative bytes");
    XCTAssertEqual(error.code, MBSRandomErrorInvalidByteCount, "Should return correct error code");
    XCTAssertNil(negativeData, "Should not generate data for negative bytes");
}

@end
