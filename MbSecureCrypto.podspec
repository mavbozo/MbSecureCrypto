
Pod::Spec.new do |spec|
  # Helper function needs to be defined within the spec block
  config_path = 'Config/MbSecureCrypto.xcconfig'
  
  # Validate xcconfig exists
  unless File.exist?(config_path)
    raise "Configuration file not found: #{config_path}"
  end
  
  # Read and parse xcconfig
  xcconfig_content = File.read(config_path)
  
  # Extract required values with error checking
  marketing_version = xcconfig_content.match(/MARKETING_VERSION\s*=\s*(.*)/)&.[](1)
  ios_target = xcconfig_content.match(/IPHONEOS_DEPLOYMENT_TARGET\s*=\s*(.*)/)&.[](1)
  macos_target = xcconfig_content.match(/MACOSX_DEPLOYMENT_TARGET\s*=\s*(.*)/)&.[](1)
  
  # Validate required values
  unless marketing_version && ios_target && macos_target
    raise "Required configuration values missing from xcconfig"
  end
  
  
  spec.name         = "MbSecureCrypto"
  spec.version      = marketing_version.strip
  spec.summary      = "A secure cryptography library for iOS and macOS"
  spec.homepage     = "https://github.com/mavbozo/MbSecureCrypto"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Maverick Bozo" => "mavbozo@pm.me" }
  
  spec.ios.deployment_target = ios_target.strip
  spec.osx.deployment_target = macos_target.strip
  
  # Swift version specification
  spec.swift_versions = ['5.0']
  
  # Source configuration
  if ENV['COCOAPODS_TRUNK_PUBLISH']
    spec.source = { 
      :git => "https://github.com/mavbozo/MbSecureCrypto.git", 
      :tag => spec.version.to_s 
    }
  else
    spec.source = { 
      :git => "file://#{File.expand_path(__dir__)}", 
      :tag => spec.version.to_s 
    }
  end
  
  # Source files configuration
  spec.source_files = [
    "MbSecureCrypto/*.{h,m,swift}",
    "MbSecureCrypto/**/*.{h,m,swift}"
  ]
  
  spec.public_header_files = [
    "MbSecureCrypto/*.h",
    "MbSecureCrypto/Random/*.h",
    "MbSecureCrypto/Cipher/*.h"
  ]
  
  # Module configuration
  spec.module_name = 'MbSecureCrypto'
  
  # Required frameworks
  spec.frameworks = 'Security', 'Foundation'
  
  # Read build settings from xcconfig
  xcconfig = File.read('Config/MbSecureCrypto.xcconfig')
  build_settings = xcconfig.scan(/^([A-Z_]+)\s*=\s*(.*)$/).to_h
  
  # Merge with pod-specific settings
  spec.pod_target_xcconfig = build_settings.merge(
    {
      'DEFINES_MODULE' => 'YES',
      'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/MbSecureCrypto',
      'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'MbSecureCrypto-Swift.h',
      'CLANG_ENABLE_MODULES' => 'YES',
      'SWIFT_OPTIMIZATION_LEVEL[config=Debug]' => '-Onone',
      'SWIFT_COMPILATION_MODE' => 'wholemodule'
    }
  )
  
  spec.requires_arc = true
end
