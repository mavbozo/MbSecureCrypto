//
//  MBSCipher.m
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 11/11/24.
//


#import "MBSCipher.h"
#import "MBSError.h"

// Handle both framework and static library imports
#if __has_include(<MbSecureCrypto/MbSecureCrypto-Swift.h>)
#import <MbSecureCrypto/MbSecureCrypto-Swift.h>
#else
#import "MbSecureCrypto-Swift.h"
#endif


@implementation MBSCipher

+ (nullable NSString *)encryptString:(NSString *)string
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error {
    return [self encryptString:string
                 withAlgorithm:algorithm
                    withFormat:nil
                       withKey:key
                         error:error];
}

+ (nullable NSString *)encryptString:(NSString *)string
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                          withFormat: (nullable NSNumber *)format
                             withKey:(NSData *)key
                               error:(NSError **)error {
    
    // Input validation
    if (!string) {  // Only check for nil, allow empty string
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Input string cannot be nil"}];
        }
        return nil;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return nil;
    }
    
    // Forward to bridge
    // Default to V0 if format is nil
    MBSCipherFormat actualFormat = format ? format.unsignedIntValue : MBSCipherFormatV0;
    
    return [MBSCipherBridge encryptString:string
                                      key:key
                                algorithm:algorithm
                                   format:actualFormat
                                    error:error];
}

+ (nullable NSString *)decryptString:(NSString *)encryptedString
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                             withKey:(NSData *)key
                               error:(NSError **)error {
    return [self decryptString:encryptedString
                 withAlgorithm:algorithm
                    withFormat:nil
                       withKey:key
                         error:error];
    
}

+ (nullable NSString *)decryptString:(NSString *)encryptedString
                       withAlgorithm:(MBSCipherAlgorithm)algorithm
                          withFormat: (nullable NSNumber *)format
                             withKey:(NSData *)key
                               error:(NSError **)error {
    
    // Input validation
    if (!encryptedString) {  // Only check for nil, allow empty string
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Input string cannot be nil"}];
        }
        return nil;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return nil;
    }
    
    // Forward to bridge
    // Default to V0 if format is nil
    MBSCipherFormat actualFormat = format ? format.unsignedIntValue : MBSCipherFormatV0;
    
    
    return [MBSCipherBridge decryptString:encryptedString
                                      key:key
                                algorithm:algorithm
                                   format: actualFormat
                                    error:error];
}

+ (nullable NSData *)encryptData:(NSData *)data
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                         withKey:(NSData *)key
                           error:(NSError **)error {
    return [self encryptData:data
               withAlgorithm:algorithm
                  withFormat:nil
                     withKey:key
                       error:error];
}

+ (nullable NSData *)encryptData:(NSData *)data
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                      withFormat: (nullable NSNumber *)format
                         withKey:(NSData *)key
                           error:(NSError **)error {
    
    // Input validation
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Input data cannot be nil"}];
        }
        return nil;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return nil;
    }
    
    // Forward to bridge
    MBSCipherFormat actualFormat = format ? format.unsignedIntValue : MBSCipherFormatV0;
    
    return [MBSCipherBridge encryptData:data
                                    key:key
                              algorithm:algorithm
                                 format: actualFormat
                                  error:error];
}

+ (nullable NSData *)decryptData:(NSData *)encryptedData
                   withAlgorithm:(MBSCipherAlgorithm)algorithm

                         withKey:(NSData *)key
                           error:(NSError **)error {
    return [self decryptData:encryptedData
               withAlgorithm:algorithm
                  withFormat:nil
                     withKey:key
                       error:error];
}

+ (nullable NSData *)decryptData:(NSData *)encryptedData
                   withAlgorithm:(MBSCipherAlgorithm)algorithm
                      withFormat: (nullable NSNumber *)format
                         withKey:(NSData *)key
                           error:(NSError **)error {
    
    // Input validation
    if (!encryptedData) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Input data cannot be nil"}];
        }
        return nil;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return nil;
    }
    
    // Forward to bridge
    // Default to V0 if format is nil
    MBSCipherFormat actualFormat = format ? format.unsignedIntValue : MBSCipherFormatV0;
    
    return [MBSCipherBridge decryptData:encryptedData
                                    key:key
                              algorithm:algorithm
                                 format:actualFormat
                                  error:error];
}

+ (BOOL)encryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
            withKey:(NSData *)key
              error:(NSError **)error {
    
    return [self encryptFile:sourceURL
                    toOutput:destinationURL
               withAlgorithm:algorithm
                  withFormat:nil
                     withKey:key
                       error:error];
    
}

+ (BOOL)encryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
         withFormat: (nullable NSNumber *)format
            withKey:(NSData *)key
              error:(NSError **)error {
    
    // Input validation
    if (!sourceURL || !destinationURL) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Source or destination URL is nil"}];
        }
        return NO;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return NO;
    }
    
    // Check file size
    NSError *attributesError = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:sourceURL.path
                                                                                error:&attributesError];
    if (attributesError) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read source file attributes",
                                                NSUnderlyingErrorKey: attributesError}];
        }
        return NO;
    }
    
    unsigned long long fileSize = [attributes fileSize];
    if (fileSize > kMBSCipherMaxFileSize) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorFileTooLarge
                                     userInfo:@{NSLocalizedDescriptionKey:
                                                    [NSString stringWithFormat:@"File size %llu exceeds maximum allowed size of %lu bytes",
                                                     fileSize, (unsigned long)kMBSCipherMaxFileSize]}];
        }
        return NO;
    }
    
    // Read source file
    NSError *readError = nil;
    NSData *fileData = [NSData dataWithContentsOfURL:sourceURL
                                             options:NSDataReadingMappedIfSafe
                                               error:&readError];
    if (!fileData) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read source file",
                                                NSUnderlyingErrorKey: readError}];
        }
        return NO;
    }
    
    // Reuse existing data encryption
    NSError *encryptError = nil;
    NSData *encryptedData = [self encryptData:fileData
                                withAlgorithm:algorithm
                                   withFormat:format
                                      withKey:key
                                        error:&encryptError];
    if (!encryptedData) {
        if (error) {
            *error = encryptError;
        }
        return NO;
    }
    
    // Write to destination
    NSError *writeError = nil;
    BOOL success = [encryptedData writeToURL:destinationURL
                                     options:NSDataWritingAtomic
                                       error:&writeError];
    if (!success) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to write encrypted file",
                                                NSUnderlyingErrorKey: writeError}];
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)decryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm

            withKey:(NSData *)key
              error:(NSError **)error {
    return  [self decryptFile:sourceURL
                     toOutput:destinationURL
                withAlgorithm:algorithm
                   withFormat:nil
                      withKey:key
                        error:error];
}

+ (BOOL)decryptFile:(NSURL *)sourceURL
           toOutput:(NSURL *)destinationURL
      withAlgorithm:(MBSCipherAlgorithm)algorithm
         withFormat: (nullable NSNumber *)format
            withKey:(NSData *)key
              error:(NSError **)error {
    
    // Input validation
    if (!sourceURL || !destinationURL) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidInput
                                     userInfo:@{NSLocalizedDescriptionKey: @"Source or destination URL is nil"}];
        }
        return NO;
    }
    
    if (!key || key.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorInvalidKey
                                     userInfo:@{NSLocalizedDescriptionKey: @"Key cannot be empty"}];
        }
        return NO;
    }
    
    // Check file size
    NSError *attributesError = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:sourceURL.path
                                                                                error:&attributesError];
    if (attributesError) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read source file attributes",
                                                NSUnderlyingErrorKey: attributesError}];
        }
        return NO;
    }
    
    unsigned long long fileSize = [attributes fileSize];
    if (fileSize > kMBSCipherMaxFileSize) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorFileTooLarge
                                     userInfo:@{NSLocalizedDescriptionKey:
                                                    [NSString stringWithFormat:@"File size %llu exceeds maximum allowed size of %lu bytes",
                                                     fileSize, (unsigned long)kMBSCipherMaxFileSize]}];
        }
        return NO;
    }
    
    // Read encrypted file
    NSError *readError = nil;
    NSData *encryptedData = [NSData dataWithContentsOfURL:sourceURL
                                                  options:NSDataReadingMappedIfSafe
                                                    error:&readError];
    if (!encryptedData) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read encrypted file",
                                                NSUnderlyingErrorKey: readError}];
        }
        return NO;
    }
    
    // Reuse existing data decryption
    NSError *decryptError = nil;
    NSData *decryptedData = [self decryptData:encryptedData
                                withAlgorithm:algorithm
                                   withFormat:format
                                      withKey:key
                                        error:&decryptError];
    if (!decryptedData) {
        if (error) {
            *error = decryptError;
        }
        return NO;
    }
    
    // Write decrypted file
    NSError *writeError = nil;
    BOOL success = [decryptedData writeToURL:destinationURL
                                     options:NSDataWritingAtomic
                                       error:&writeError];
    if (!success) {
        if (error) {
            *error = [NSError errorWithDomain:MBSErrorDomain
                                         code:MBSCipherErrorIOFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to write decrypted file",
                                                NSUnderlyingErrorKey: writeError}];
        }
        return NO;
    }
    
    return YES;
}

@end
