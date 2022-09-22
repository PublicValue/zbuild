# zbuild
Simple Build-Tool for iOS XCode projects.
Wraps xcodebuild (building and archiving), altool (uploading) and uses the Appstore Connect API to receive distribution profiles.

# Creating an AuthKey for Appstore Connect
Go to https://appstoreconnect.apple.com/access/api and create a key, store

# Creating a signing key + app profile
Signing key is created here: https://developer.apple.com/account/resources/certificates/list
Choose type: iOS Distribution and put the key somewhere safe.

If you already have a distribution certificate, you can also export the key from your Mac OS Keychain App. 

Base64 encode the key for later use:
```bash
cat <path-to-keyfile> | base64 -e > signing_key.p12.b64
```

# Building
```bash
zbuild archive 
  [\<project-dir>] 
  --scheme <scheme> 
  --authentication-key-path <path-to-authkey-file> 
  --authentication-key-id <authkey-id> 
  --authentication-key-issuer-id <authkey-issuer-id> 
  --signing-key-path <path to base64-encoded signing key>
  --signing-key-password <password to base64-encoded signing key>
  ```

Authentication key is used to fetch Provisioning Profiles.

# Export IPA
```bash
zbuild export-ipa
  [<project-dir>] 
  --scheme <scheme>
  --authentication-key-path <path-to-authkey-file> 
  --authentication-key-id <authkey-id> 
  --authentication-key-issuer-id <authkey-issuer-id> 
  --signing-key-path <path to base64-encoded signing key>
  --signing-key-password <password to base64-encoded signing key>
```

Authentication key is used to fetch Provisioning Profiles.

# Upload IPA
```bash
zbuild upload-ipa 
  [<project-dir>]  
  --scheme <scheme>
  --authentication-key-path <path-to-authkey-file> 
  --authentication-key-id <authkey-id> 
  --authentication-key-issuer-id <authkey-issuer-id>
```