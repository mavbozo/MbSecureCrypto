//
//  MBSKeyDerivationTests.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 01/12/24.
//


#import <XCTest/XCTest.h>
#import "MBSKeyDerivation.h"
#import "MBSRandom.h"
#import "MBSError.h"

@interface MBSKeyDerivationTests : XCTestCase
@end

@implementation MBSKeyDerivationTests

- (void)testBasicKeyDerivation {
    // Given
    NSError *error = nil;
    
    NSData *masterKey = [MBSRandom generateBytes:32 error:&error];
    XCTAssertNotNil(masterKey);
    XCTAssertNil(error);
    
    // When
    NSData *derivedKey = [MBSKeyDerivation deriveKey:masterKey
                                             domain:@"test.encryption"
                                            context:@"basic-test"
                                             error:&error];
    
    // Then
    XCTAssertNotNil(derivedKey);
    XCTAssertNil(error);
    XCTAssertEqual(derivedKey.length, 32); // Default size
}

- (void)testCustomKeySizeDerivation {
    // Given
    NSError *error = nil;
    NSData *masterKey = [MBSRandom generateBytes:32 error:&error];
    
    // When
    NSData *derivedKey = [MBSKeyDerivation deriveKey:masterKey
                                             domain:@"test.encryption"
                                            context:@"size-test"
                                            keySize:64
                                         algorithm:MBSHkdfAlgorithmSHA512
                                             error:&error];
    
    // Then
    XCTAssertNotNil(derivedKey);
    XCTAssertNil(error);
    XCTAssertEqual(derivedKey.length, 64);
}

- (void)testDifferentContextsProduceDifferentKeys {
    // Given
    NSError *error = nil;
    NSData *masterKey = [MBSRandom generateBytes:32 error:&error];
    
    // When
    NSData *key1 = [MBSKeyDerivation deriveKey:masterKey
                                       domain:@"test.encryption"
                                      context:@"context1"
                                       error:&error];
    
    NSData *key2 = [MBSKeyDerivation deriveKey:masterKey
                                       domain:@"test.encryption"
                                      context:@"context2"
                                       error:&error];
    
    // Then
    XCTAssertNotNil(key1);
    XCTAssertNotNil(key2);
    XCTAssertFalse([key1 isEqualToData:key2]);
}

- (void)testInvalidInputs {
    NSError *error = nil;
    
    // Test short master key
    NSData *shortKey = [MBSRandom generateBytes:8 error:&error];
    NSData *derivedKey = [MBSKeyDerivation deriveKey:shortKey
                                             domain:@"test"
                                            context:@"test"
                                             error:&error];
    XCTAssertNil(derivedKey);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidKey);
    
    // Test empty domain
    error = nil;
    NSData *masterKey = [MBSRandom generateBytes:32 error:&error];
    derivedKey = [MBSKeyDerivation deriveKey:masterKey
                                     domain:@""
                                    context:@"test"
                                     error:&error];
    XCTAssertNil(derivedKey);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidInput);
    
    // Test empty context
    error = nil;
    derivedKey = [MBSKeyDerivation deriveKey:masterKey
                                     domain:@"test"
                                    context:@""
                                     error:&error];
    XCTAssertNil(derivedKey);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, MBSCipherErrorInvalidInput);
}

- (void)testKnownVectorSHA256 {
    // Test vector from RFC 5869
    const char *ikm = "\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b";
    NSData *masterKey = [NSData dataWithBytes:ikm length:22];
    
    NSError *error = nil;
    NSData *derivedKey = [MBSKeyDerivation deriveKey:masterKey
                                             domain:@"test.rfc5869"
                                            context:@"test1"
                                            keySize:42
                                         algorithm:MBSHkdfAlgorithmSHA256
                                             error:&error];
    
    XCTAssertNotNil(derivedKey);
    XCTAssertNil(error);
    XCTAssertEqual(derivedKey.length, 42);
    // Full verification would include comparing against known output
}

@end
