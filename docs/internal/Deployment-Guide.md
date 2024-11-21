# MbSecureCrypto CocoaPods Deployment Guide

## Prerequisites

- [CocoaPods](https://cocoapods.org) installed (`gem install cocoapods`)
- [CocoaPods Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html) account
- Git repository with proper access rights
- Xcode Command Line Tools installed

## Pre-deployment Checklist

1. [ ] All tests passing
2. [ ] Documentation updated
3. [ ] CHANGELOG.md updated
4. [ ] Version number updated in Config/MbSecureCrypto.xcconfig
5. [ ] README.md updated with latest version
6. [ ] Git working directory clean
7. [ ] All changes committed and pushed

## Deployment Steps

### 1. Register with CocoaPods Trunk (First Time Only)

```bash
# Register your machine with CocoaPods Trunk
pod trunk register mavbozo@pm.me 'Maverick Bozo' --description='MacBook Pro M1'

# Verify the email sent by CocoaPods
```

### 2. Update Version Numbers

1. Update version in `Config/MbSecureCrypto.xcconfig`:
```
MARKETING_VERSION = X.Y.Z
```

2. Update version in README.md installation instructions:
```ruby
pod 'MbSecureCrypto', '~> X.Y.Z'
```

3. Update CHANGELOG.md with new version section

### 3. Validate the Podspec

```bash
# Lint the podspec
pod lib lint MbSecureCrypto.podspec --verbose

# If you get warnings but want to proceed:
pod lib lint MbSecureCrypto.podspec --allow-warnings
```

### 4. Create and Push Git Tag

```bash
# Create git tag
git tag -a X.Y.Z -m "Release X.Y.Z"

# Push tag to remote
git push origin X.Y.Z
```

### 5. Publish to CocoaPods

```bash
# Push to CocoaPods Trunk
pod trunk push MbSecureCrypto.podspec

# If you need to allow warnings:
pod trunk push MbSecureCrypto.podspec --allow-warnings
```

### 6. Verify Deployment

1. Wait a few minutes for CocoaPods to process the submission
2. Search for your pod:
```bash
pod search MbSecureCrypto
```
3. Verify the new version appears on [CocoaPods.org](https://cocoapods.org)

### 7. Post-deployment Tasks

1. [ ] Create GitHub release with release notes
2. [ ] Update documentation website (if applicable)
3. [ ] Notify users through appropriate channels
4. [ ] Update sample projects to use new version
5. [ ] Start next development cycle

## Troubleshooting

### Common Issues

1. **Podspec Validation Fails**
   - Check paths in podspec match actual file structure
   - Verify all dependencies are correctly specified
   - Ensure version numbers are consistent

2. **Tag Issues**
   - Verify tag matches version in podspec
   - Ensure tag is pushed to remote
   - Check tag format (should be just numbers and dots)

3. **Trunk Authentication Issues**
   - Verify email is confirmed
   - Try running `pod trunk me` to check registration
   - Re-register if necessary

### Important Notes

- The podspec validation might take several minutes
- Keep your CocoaPods installation updated (`gem install cocoapods`)
- Always test the pod in a sample project before releasing
- Remember to increment version numbers according to [Semantic Versioning](https://semver.org)

## Support

If you encounter issues during deployment:
1. Check CocoaPods [Guides](https://guides.cocoapods.org)
2. Visit CocoaPods [Discuss](https://discuss.cocoapods.org)
3. Contact the team at mavbozo@pm.me

## Security Considerations

- Never include sensitive information in podspec
- Verify the integrity of your release artifacts
- Use secure connections for all operations
- Keep your CocoaPods trunk credentials secure
