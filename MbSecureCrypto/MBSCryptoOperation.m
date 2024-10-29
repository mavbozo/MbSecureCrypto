//
//  MBSCryptoOperation.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 29/10/24.
//

#import "MBSCryptoOperation.h"
#import <Security/Security.h>

@implementation MBSCryptoOperation

+ (nullable NSString *)randomStringWithLength:(NSInteger)length
                                      error:(NSError **)error {
    // Input validation
    if (length <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:100
                                   userInfo:@{NSLocalizedDescriptionKey: @"Length must be greater than 0"}];
        }
        return nil;
    }
    
    // Create buffer for random bytes
    NSMutableData *randomData = [NSMutableData dataWithLength:length];
    
    // Generate random bytes using SecRandomCopyBytes
    int status = SecRandomCopyBytes(kSecRandomDefault, length, randomData.mutableBytes);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.mbsecurecrypto"
                                       code:101
                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to generate random bytes"}];
        }
        return nil;
    }
    
    // Convert to base64 string
    return [randomData base64EncodedStringWithOptions:0];
}

@end
