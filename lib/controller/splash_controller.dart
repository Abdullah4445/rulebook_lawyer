import 'dart:async';

import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/ui/auth_screen/login_screen.dart';
import 'package:lawyer/ui/dashboard_screen.dart';
import 'package:lawyer/ui/on_boarding_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:lawyer/utils/Preferences.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        await FireStoreUtils.getDriverProfile(FirebaseAuth.instance.currentUser!.uid).then(
          (value) {
            if (value != null) {
              DriverUserModel userModel = value;
              bool isPlanExpire = false;
              if (userModel.subscriptionPlan?.id != null) {
                if (userModel.subscriptionExpiryDate == null) {
                  if (userModel.subscriptionPlan?.expiryDay == '-1') {
                    isPlanExpire = false;
                  } else {
                    isPlanExpire = true;
                  }
                } else {
                  DateTime expiryDate = userModel.subscriptionExpiryDate!.toDate();
                  isPlanExpire = expiryDate.isBefore(DateTime.now());
                }
              } else {
                isPlanExpire = true;
              }
              if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
                if (Constant.adminCommission?.isEnabled == false && Constant.isSubscriptionModelApplied == false) {
                  Get.offAll(const DashBoardScreen());
                } else {
                  Get.offAll(const SubscriptionListScreen(), arguments: {"isShow": true});
                }
              } else {
                Get.offAll(const DashBoardScreen());
              }
            }
          },
        );
      } else {
        Get.offAll(const LoginScreen());
      }
    }
  }
}
