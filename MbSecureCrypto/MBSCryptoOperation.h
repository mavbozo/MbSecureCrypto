//
//  MbSecureCryptoOperation.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 29/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSCryptoOperation : NSObject

// Random string generation
+ (nullable NSString *)randomStringWithLength:(NSInteger)length
                                      error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
