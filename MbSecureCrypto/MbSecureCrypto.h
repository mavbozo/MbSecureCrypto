//
//  MbSecureCrypto.h
//  MbSecureCrypto
//
//  Created by Maverick Bozo on 29/10/24.
//

/*!
 @framework MbSecureCrypto
 @abstract A secure cryptography library YES!
 @discussion Provides random number generation and encryption
*/

#import <Foundation/Foundation.h>

//! Project version number
FOUNDATION_EXPORT double MbSecureCryptoVersionNumber;

//! Project version string
FOUNDATION_EXPORT const unsigned char MbSecureCryptoVersionString[];

// Public headers
#pragma message "MBSCryptoOperation.h is deprecated. Use MBSRandom.h instead."
#import "MBSCryptoOperation.h"

#import "MBSRandom.h"

#import "MBSCipherTypes.h"
#import "MBSCipher.h"

#import "MBSError.h"
