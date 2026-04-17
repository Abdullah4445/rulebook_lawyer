# Facebook Authentication Setup Guide

## ✅ What I've Done:

1. ✅ Added `flutter_facebook_auth: ^7.1.1` package to pubspec.yaml
2. ✅ Created Facebook sign-in method in `login_controller.dart`
3. ✅ Added Facebook login button in `login_screen.dart`
4. ✅ Added Facebook login type constant (`facebookLoginType`) in `constant.dart`
5. ✅ Updated `AndroidManifest.xml` with Facebook configuration
6. ✅ Created `strings.xml` with Facebook placeholders
7. ✅ Installed the package with `flutter pub get`
8. ✅ Created temporary Facebook icon (replace with proper one)

---

## 🔧 What You Need to Do:

### Step 1: Get Facebook App Credentials

1. **Go to Facebook Developers Console:**
   - Visit: https://developers.facebook.com/apps/
   - Login with your Facebook account

2. **Select Your App:**
   - Click on your "Rulebook Lawyer" app (or create new if needed)
   - Go to **Settings** → **Basic**

3. **Get Your Credentials:**
   - Copy **App ID** (Example: 1234567890123456)
   - Copy **App Secret** (keep this secure!)
   - Scroll down and click **Show** next to Client Token
   - Copy **Client Token**

---

### Step 2: Update Android Configuration

Open file: `android/app/src/main/res/values/strings.xml`

Replace the placeholders with your actual values:

```xml
<!-- Facebook Configuration -->
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
<string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
```

**Example:**
```xml
<!-- Facebook Configuration -->
<string name="facebook_app_id">1234567890123456</string>
<string name="fb_login_protocol_scheme">fb1234567890123456</string>
<string name="facebook_client_token">abcdef123456789...</string>
```

---

### Step 3: Configure Facebook App Settings

1. **Add Android Platform:**
   - In Facebook Developers Console, go to **Settings** → **Basic**
   - Scroll to bottom, click **Add Platform**
   - Select **Android**

2. **Enter Package Name:**
   - Package Name: `com.ailab.rulebooklawyer`

3. **Add Hash Key:**
   You need to generate a hash key for your app.

   **Debug Hash (for testing):**
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore "C:\Users\YOUR_USERNAME\.android\debug.keystore" | openssl sha1 -binary | openssl base64
   ```
   Password: `android`

   **Release Hash (for production):**
   ```bash
   keytool -exportcert -alias YOUR_RELEASE_KEY_ALIAS -keystore YOUR_RELEASE_KEY_PATH | openssl sha1 -binary | openssl base64
   ```

4. **Enable Facebook Login:**
   - Go to **Products** → Click **Set Up** on **Facebook Login**
   - Go to **Facebook Login** → **Settings**
   - Add to **Valid OAuth Redirect URIs:**
     ```
     fbYOUR_APP_ID://authorize
     ```
   - Save changes

---

### Step 4: Update Firebase Console

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com/
   - Select your project: **rulebook804**

2. **Enable Facebook Authentication:**
   - Go to **Authentication** → **Sign-in method**
   - Click on **Facebook**
   - Click **Enable**
   - Enter your **App ID** and **App Secret** from Facebook
   - Copy the **OAuth redirect URI** shown
   - Save

3. **Add OAuth Redirect URI to Facebook:**
   - Go back to Facebook Developers Console
   - Go to **Facebook Login** → **Settings**
   - Add the Firebase OAuth redirect URI to **Valid OAuth Redirect URIs**
   - Save

---

### Step 5: Add Proper Facebook Icon

Replace the temporary icon:

1. **Download Facebook Logo:**
   - Visit: https://www.facebook.com/brand/resources/facebookapp/logo/
   - Download the official Facebook "f" logo (PNG format)
   - Recommended size: 512x512px with transparent background

2. **Replace Icon:**
   - Save as: `assets/icons/ic_facebook.png`
   - Replace the current temporary icon

---

### Step 6: iOS Configuration (if needed)

If you're building for iOS, also update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_FACEBOOK_APP_ID</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Rulebook Lawyer</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

---

### Step 7: Test Facebook Login

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test the login flow:**
   - Tap on "Login with Facebook" button
   - Complete Facebook authentication
   - Verify user is logged in successfully

---

## 🔍 Troubleshooting:

### Error: "Invalid Hash Key"
- Regenerate your hash key using the keytool command
- Make sure you added BOTH debug and release hash keys in Facebook

### Error: "App Not Setup"
- Verify Facebook App ID in strings.xml matches your app
- Check that Facebook Login product is added and configured

### Error: "Invalid OAuth redirect URI"
- Verify OAuth redirect URI in Firebase matches Facebook settings
- Format should be: `https://YOUR-PROJECT.firebaseapp.com/__/auth/handler`

### Login Button Doesn't Work:
- Check logs for error messages
- Verify internet permission in AndroidManifest.xml
- Make sure you ran `flutter pub get`

---

## 📝 Summary of Files Modified:

1. ✅ `pubspec.yaml` - Added flutter_facebook_auth package
2. ✅ `lib/controller/login_controller.dart` - Added signInWithFacebook() method
3. ✅ `lib/ui/auth_screen/login_screen.dart` - Added Facebook login button
4. ✅ `lib/constant/constant.dart` - Added facebookLoginType constant
5. ✅ `android/app/src/main/AndroidManifest.xml` - Added Facebook activities
6. ✅ `android/app/src/main/res/values/strings.xml` - Added Facebook credentials
7. ✅ `assets/icons/ic_facebook.png` - Temporary icon (replace with proper one)

---

## 🎯 Next Steps After Configuration:

Once you've completed the setup:

1. Replace placeholder values in `strings.xml` with your actual Facebook credentials
2. Add proper hash keys to Facebook Developer Console
3. Enable Facebook Login in Firebase Console
4. Replace the temporary Facebook icon with proper one
5. Test on a real device (Facebook login may not work on emulator)
6. Test with both new users and existing users

---

## 📞 Support:

If you encounter issues:
- Check Facebook Developer Console → App Dashboard for error messages
- Review Firebase Console → Authentication logs
- Check app logs with: `flutter logs` or `adb logcat`

---

**Created:** April 16, 2026
**App:** Rulebook Lawyer Driver App
**Package:** com.ailab.rulebooklawyer

