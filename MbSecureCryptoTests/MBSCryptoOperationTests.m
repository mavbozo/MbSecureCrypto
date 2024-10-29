//
//  MBSCryptoOperationTests.m
//  MbSecureCryptoTests
//
//  Created by Maverick Bozo on 29/10/24.
//

#import <XCTest/XCTest.h>
#import <MbSecureCrypto/MbSecureCrypto.h>

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

@end
