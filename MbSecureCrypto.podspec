Pod::Spec.new do |spec|
  spec.name         = "MbSecureCrypto"
  spec.version      = "0.2.0"
  spec.summary      = "A secure cryptography library for iOS and macOS"
  spec.description  = <<-DESC
                     MbSecureCrypto provides secure cryptographic operations 
                     including random string generation and more. Built with 
                     Apple's Security framework integration for optimal platform security.
                     DESC

  spec.homepage     = "https://github.com/mavbozo/MbSecureCrypto"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Maverick Bozo" => "mavbozo@pm.me" }

  # Platform configuration
  spec.ios.deployment_target = "15.6"
  spec.osx.deployment_target = "12.4"
  
  # Source configuration
  spec.source       = { 
    :git => "https://github.com/mavbozo/MbSecureCrypto.git", 
    :tag => spec.version.to_s 
  }
  
  # File patterns
  spec.source_files = "MbSecureCrypto/**/*.{h,m}"
  spec.public_header_files = "MbSecureCrypto/**/*.h"
  
  # Framework dependencies
  spec.framework    = "Security"
  spec.requires_arc = true
  
  # Additional security settings
  spec.pod_target_xcconfig = {
    'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'YES',
    'GCC_TREAT_WARNINGS_AS_ERRORS' => 'YES',
    'OTHER_CFLAGS' => '-fstack-protector-strong'
  }
end
