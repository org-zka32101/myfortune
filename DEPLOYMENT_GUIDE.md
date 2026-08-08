# App Store Connect Deployment Guide

This guide explains how to configure your iOS app for deployment to the App Store and TestFlight through GitHub Actions CI/CD.

## Prerequisites

Before setting up the deployment pipeline, you need:

1. **Apple Developer Account** - Active enrollment in the Apple Developer Program
2. **App ID** - Created in your Apple Developer account
3. **Provisioning Profiles** - Distribution profile for App Store deployment
4. **Code Signing Certificate** - Distribution certificate from Apple

## Step 1: Obtain Apple Developer Credentials

### 1.1 Download Distribution Certificate

1. Go to [Apple Developer Account](https://developer.apple.com/account/)
2. Navigate to **Certificates, IDs & Profiles** → **Certificates**
3. Click the **+** button to create a new certificate
4. Select **Apple Distribution** and follow the prompts
5. Download the certificate (`.cer` file)
6. Double-click to add to your Keychain
7. In Keychain, right-click the certificate and **Export** it as `.p12`
   - Name it: `distribution-certificate.p12`
   - Set a strong password (you'll need this)

### 1.2 Get Provisioning Profile

1. Navigate to **Certificates, IDs & Profiles** → **Profiles**
2. Click **+** to create a new profile
3. Select **App Store Connect** and click **Continue**
4. Select your App ID and click **Continue**
5. Select the **Distribution** certificate you just created
6. Name it (e.g., `myfortune-distribution`) and click **Generate**
7. Download the `.mobileprovision` file

### 1.3 Get Team ID and App ID

1. Navigate to **Membership Details**
2. Find your **Team ID** (10-character identifier)
3. Note your **Apple ID** (email address)

### 1.4 Create App-Specific Password

1. Go to [AppleID.apple.com](https://appleid.apple.com/)
2. Navigate to **Security** → **App-Specific Passwords**
3. Select **Generate password**
4. Choose "Other (specify)" and type "GitHub Actions"
5. Copy the generated password (you'll need this)

## Step 2: Configure GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** for each of these:

### Required Secrets:

#### APPLE_TEAM_ID
- **Value**: Your 10-character Team ID from Step 1.3
- **Example**: ABC1234567

#### APPLE_USERNAME
- **Value**: Your Apple ID email address
- **Example**: you@example.com

#### APPLE_APP_SPECIFIC_PASSWORD
- **Value**: The app-specific password from Step 1.4
- **Do NOT use your regular Apple password**

#### SIGNING_CERTIFICATE_BASE64
- **How to create**:
  ```
  base64 -i distribution-certificate.p12 | pbcopy
  ```
  Or on Linux:
  ```
  base64 -w 0 distribution-certificate.p12 | xclip -selection clipboard
  ```
- **Value**: Paste the base64-encoded certificate

#### SIGNING_CERTIFICATE_PASSWORD
- **Value**: The password you set when exporting the .p12 file

#### PROVISIONING_PROFILE_BASE64
- **How to create**:
  ```
  base64 -i myfortune.mobileprovision | pbcopy
  ```
  Or on Linux:
  ```
  base64 -w 0 myfortune.mobileprovision | xclip -selection clipboard
  ```
- **Value**: Paste the base64-encoded provisioning profile

#### KEYCHAIN_PASSWORD
- **Value**: Create a strong random password for the build keychain
- **Example**: A 32-character random string

## Step 3: Update Project Configuration

Make sure your Xcode project is properly configured:

### 3.1 Provisioning Profile in Xcode

1. Open your project in Xcode
2. Select the **myfortune** target
3. Go to **Build Settings**
4. Search for "Provisioning Profile"
5. Set **Provisioning Profile (Automatic)** to the distribution profile name
6. Ensure **Code Sign Identity** is set to "Apple Distribution"

### 3.2 Update Podfile

Ensure your Podfile includes:
```
use_modular_headers!
```

This ensures Swift/Objective-C interoperability.

## Step 4: Trigger Deployment

### Option 1: Automatic Deployment (Recommended)

Create a Git tag to automatically trigger deployment:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

The workflow will automatically:
1. Build and archive the app
2. Export the IPA
3. Upload to App Store Connect
4. Upload to TestFlight
5. Create a GitHub Release
6. Send a Slack notification

### Option 2: Manual Deployment

1. Go to **Actions** → **App Store Deployment**
2. Click **Run workflow**
3. The workflow will run immediately

## Step 5: Monitor the Deployment

1. Go to **Actions** → **App Store Deployment**
2. Watch the workflow run in real-time
3. Check each job's logs for any issues

## Step 6: Verify in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **My Apps** → **myfortune**
3. Go to **Builds**
4. You should see your build appearing within 5-15 minutes after upload

## Troubleshooting

### Build fails during Archive
- Check that your provisioning profile is valid and not expired
- Ensure the certificate is properly imported
- Verify the Team ID matches your Apple Developer account

### Upload fails with authentication error
- Verify your app-specific password is correct
- Check that your Apple ID is correct
- Ensure you're using an app-specific password, not your regular Apple password

### Build doesn't appear in App Store Connect
- Check the workflow logs for upload errors
- Wait 5-15 minutes for processing
- Verify the Team ID is correct in your project settings

## Next Steps

1. Set up Apple Developer account and credentials
2. Configure GitHub Secrets
3. Create a version tag to trigger deployment
4. Monitor the workflow in GitHub Actions
5. Check App Store Connect for your build
