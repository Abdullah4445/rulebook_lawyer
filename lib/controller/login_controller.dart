import 'dart:convert';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:crypto/crypto.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/ui/auth_screen/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../utils/utils.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  RxString countryCode = "+1".obs;

  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  sendCode() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);

      await FirebaseAuth.instance
          .verifyPhoneNumber(
        phoneNumber: countryCode + phoneNumberController.value.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("FirebaseAuthException--->${e.message}");
          ShowToastDialog.closeLoader();
          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("The provided phone number is not valid.".tr);
          } else {
            ShowToastDialog.showToast("Something went wrong.".tr);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          Get.to(const OtpScreen(), arguments: {
            "countryCode": countryCode.value,
            "phoneNumber": phoneNumberController.value.text,
            "verificationId": verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      )
          .catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            "You have try many time please send otp after some time".tr);
      });
    } catch (e) {
      print(e);
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}".tr);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint("Google Sign-In timeout");
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Sign in timeout. Please try again.".tr);
          return null;
        },
      ).catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Something went wrong".tr);
        return null;
      });

      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled by user.");
        ShowToastDialog.closeLoader();
        return null;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth == null || googleAuth.idToken == null) {
        debugPrint("Failed to get Google auth credentials");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Authentication failed. Please try again.".tr);
        return null;
      }

      // Create a new credential using only the idToken for Firebase Authentication
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Unexpected Google Sign-In error: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Sign in failed: ${e.toString()}".tr);
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print(appleCredential);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode);

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {"appleCredential": appleCredential, "userCredential": userCredential};
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status == LoginStatus.success) {
        // Get the access token
        final AccessToken? accessToken = loginResult.accessToken;

        if (accessToken == null) {
          debugPrint("Failed to get Facebook access token");
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Authentication failed. Please try again.".tr);
          return null;
        }

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in to Firebase with the Facebook credential
        return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      } else if (loginResult.status == LoginStatus.cancelled) {
        debugPrint("Facebook Sign-In cancelled by user.");
        ShowToastDialog.closeLoader();
        return null;
      } else {
        debugPrint("Facebook Sign-In failed: ${loginResult.message}");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Sign in failed. Please try again.".tr);
        return null;
      }
    } catch (e) {
      debugPrint("Unexpected Facebook Sign-In error: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Sign in failed: ${e.toString()}".tr);
      return null;
    }
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  getLocation() async {
    Position? currentPosition = await Utils.determinePosition();
    await updateAppLanguageBasedOnLocation(currentPosition!);
  }

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    getLocation();
  }

  Future<void> _checkPermissions() async {
    // await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      var status = await Permission.systemAlertWindow.request();
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "System Alert Window permission denied");
      }
    }

    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      var status = await Permission.ignoreBatteryOptimizations.request();
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Battery Optimization permission denied");
      }
    }

    if (!await Permission.notification.isGranted) {
      var status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Notification permission denied");
      }
    }

    // if (!await Permission.locationAlways.isGranted) {
    //   var status = await Permission.locationAlways.request();
    //   if (status != PermissionStatus.granted) {
    //     Fluttertoast.showToast(msg: "Location permission denied");
    //   }
    // }
    // if (!await Permission.location.isGranted) {
    //   var status2 = await Permission.location.request();
    //   if (status2 != PermissionStatus.granted) {
    //     Fluttertoast.showToast(msg: "Location permission denied");
    //   }
    // }

    // Guide user to enable WRITE_SETTINGS manually
    Fluttertoast.showToast(
        msg: "Please enable Locations and WRITE_SETTINGS manually if not allowed");
    await AppSettings.openAppSettings(type: AppSettingsType.settings);
  }

//
// Location location = Location();
//
// getLocation() async {
//   bool serviceEnabled;
//   PermissionStatus permissionGranted;
//
//
//   serviceEnabled = await location.serviceEnabled();
//   print(serviceEnabled);
//   if (!serviceEnabled) {
//     serviceEnabled = await location.requestService();
//     if (!serviceEnabled) {
//       return;
//     }
//   }
//
//   permissionGranted = await location.hasPermission();
//   print(permissionGranted);
//   if (permissionGranted == PermissionStatus.denied) {
//     permissionGranted = await location.requestPermission();
//     if (permissionGranted != PermissionStatus.granted) {
//       return;
//     }
//   }
//   print("111");
//   Geolocator.getCurrentPosition().then((value){
//     print("location-->${value}");
//   });
//   await location.getLocation().then((value) {
//     print("location-->");
//     Constant.currentLocation = value;
//     update();
//   });
// }
}
