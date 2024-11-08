// MBSRandom.m
#import "MBSError.h"
#import "MBSRandom.h"
#import <Security/Security.h>

@implementation MBSRandom

// 1MB maximum to prevent resource exhaustion
static const NSInteger kMBSRandomMaxByteCount = 1024 * 1024;


+ (nullable NSData *)generateBytes:(NSUInteger)byteCount error:(NSError **)error {
    if (byteCount <= 0 || byteCount > kMBSRandomMaxByteCount) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSRandomErrorInvalidByteCount
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Byte count must be between 1 and %ld bytes",
                                                                            (long)kMBSRandomMaxByteCount]}];
        }
        return nil;
    }
    
    // Use @autoreleasepool to ensure temporary objects are released promptly
    @autoreleasepool {
        void *bytes = calloc(1, byteCount);
        if (!bytes) {
            if (error) {
                *error = [NSError errorWithDomain:MBSErrorDomain
                                             code:MBSRandomErrorBufferAllocation
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to allocate buffer"}];
            }
            return nil;
        }
        
        int status = SecRandomCopyBytes(kSecRandomDefault, byteCount, bytes);
        
        if (status != errSecSuccess) {
            [self secureClearAndFree:bytes length:byteCount];
            if (error) {
                *error = [NSError errorWithDomain:MBSErrorDomain
                                             code:MBSRandomErrorGenerationFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to generate random bytes"}];
            }
            return nil;
        }
        
        // Create immutable NSData with copy
        NSData *immutableData = [[NSData alloc] initWithBytes:bytes length:byteCount];
        
        // Securely clear the temporary buffer
        [self secureClearAndFree:bytes length:byteCount];
        
        return immutableData;  // Returns an immutable copy
    }
}


+ (nullable NSString *)generateBytesAsHex:(NSUInteger)byteCount error:(NSError **)error {
    @autoreleasepool {
        NSData *data = [self generateBytes:byteCount error:error];
        if (!data) {
            return nil;
        }
        
        const unsigned char *bytes = data.bytes;
        NSMutableString *hexString = [NSMutableString stringWithCapacity:byteCount * 2];
        
        for (NSUInteger i = 0; i < byteCount; i++) {
            [hexString appendFormat:@"%02x", bytes[i]];
        }
        
        return [hexString copy];  // Return an immutable copy
    }
}


+ (nullable NSString *)generateBytesAsBase64:(NSUInteger)byteCount error:(NSError **)error {
    @autoreleasepool {
        NSData *data = [self generateBytes:byteCount error:error];
        if (!data) {
            return nil;
        }
        
        return [data base64EncodedStringWithOptions:0];  // Returns immutable string
    }
}

+ (void)secureClearAndFree:(void *)bytes length:(size_t)length {
    if (bytes) {
        volatile uint8_t *volatileBytes = (volatile uint8_t *)bytes;
        memset_s((void *)volatileBytes, length, 0, length);
        free(bytes);
    }
}
@end
