import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/ui/auth_screen/login_screen.dart';
import 'package:lawyer/ui/bank_details/bank_details_screen.dart';
import 'package:lawyer/ui/chat_screen/inbox_screen.dart';
import 'package:lawyer/ui/home_screens/home_screen.dart';
import 'package:lawyer/ui/online_registration/online_registartion_screen.dart';
import 'package:lawyer/ui/profile_screen/profile_screen.dart';
import 'package:lawyer/ui/settings_screen/setting_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_history.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:lawyer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:lawyer/ui/vehicle_information/vehicle_information_screen.dart';
import 'package:lawyer/ui/ai_chat/ai_chat_screen.dart';
import 'package:lawyer/ui/wallet/wallet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  RxList<DrawerItem> drawerItems = <DrawerItem>[].obs;

  getDrawerItemWidget(int pos) {
    if (Constant.isSubscriptionModelApplied == true) {
      switch (pos) {
        case 0:
          return const HomeScreen();
        case 1:
          return const WalletScreen();
        case 2:
          return const BankDetailsScreen();
        case 3:
          return const InboxScreen();
        case 4:
          return const ProfileScreen();
        case 5:
          return const OnlineRegistrationScreen();
        case 6:
          return const VehicleInformationScreen();
        case 7:
          return const SettingScreen();
        case 8:
          return const AiChatScreen();
        case 9:
          return const SubscriptionListScreen();
        case 10:
          return const SubscriptionHistory();
        case 11:
          return const TermsAndConditionScreen(
            type: 'terms',
          );
        case 12:
          return const TermsAndConditionScreen(
            type: 'privacy',
          );
        default:
          return const Text("Error");
      }
    } else {
      switch (pos) {
        case 0:
          return const HomeScreen();
        case 1:
          return const WalletScreen();
        case 2:
          return const BankDetailsScreen();
        case 3:
          return const InboxScreen();
        case 4:
          return const ProfileScreen();
        case 5:
          return const OnlineRegistrationScreen();
        case 6:
          return const VehicleInformationScreen();
        case 7:
          return const SettingScreen();
        case 8:
          return const AiChatScreen();
        case 9:
          return const SubscriptionHistory();
        case 10:
          return const TermsAndConditionScreen(
            type: 'terms',
          );
        case 11:
          return const TermsAndConditionScreen(
            type: 'privacy',
          );
        default:
          return const Text("Error");
      }
    }
  }

  RxInt selectedDrawerIndex = 0.obs;

  onSelectItem(int index) async {
    if (Constant.isSubscriptionModelApplied == true) {
      if (index == 13) { // Logout index (14 items, last = 13)
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      } else {
        selectedDrawerIndex.value = index;
      }
    } else {
      if (index == 12) { // Logout index (13 items, last = 12)
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      } else {
        selectedDrawerIndex.value = index;
      }
    }

    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    setDrawerList();

    super.onInit();
  }

  setDrawerList() {
    if (Constant.isSubscriptionModelApplied == true) {
      drawerItems.value = [
        DrawerItem('Cases'.tr, "assets/icons/ic_city.svg"),            // 0
        DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),      // 1
        DrawerItem('Bank Details'.tr, "assets/icons/ic_profile.svg"),  // 2
        DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),           // 3
        DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),       // 4
        DrawerItem('Online Registration'.tr, "assets/icons/ic_document.svg"), // 5
        DrawerItem('Lawyer Information'.tr, "assets/icons/ic_city.svg"), // 6
        DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),     // 7
        DrawerItem('AI Legal Research'.tr, "assets/icons/ic_city.svg"), // 8
        DrawerItem('Subscription'.tr, "assets/icons/ic_subscription.svg"), // 9
        DrawerItem('Subscription History'.tr, "assets/icons/ic_subscription_history.svg"), // 10
        DrawerItem('Terms and Conditions', "assets/icons/ic_terms.svg"), // 11
        DrawerItem('Privacy Policy', "assets/icons/ic_terms.svg"),     // 12
        DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),        // 13
      ];
    } else {
      drawerItems.value = [
        DrawerItem('Cases'.tr, "assets/icons/ic_city.svg"),            // 0
        DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),      // 1
        DrawerItem('Bank Details'.tr, "assets/icons/ic_profile.svg"),  // 2
        DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),           // 3
        DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),       // 4
        DrawerItem('Online Registration'.tr, "assets/icons/ic_document.svg"), // 5
        DrawerItem('Lawyer Information'.tr, "assets/icons/ic_city.svg"), // 6
        DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),     // 7
        DrawerItem('AI Legal Research'.tr, "assets/icons/ic_city.svg"), // 8
        DrawerItem('Subscription History'.tr, "assets/icons/ic_subscription_history.svg"), // 9
        DrawerItem('Terms and Conditions', "assets/icons/ic_terms.svg"), // 10
        DrawerItem('Privacy Policy', "assets/icons/ic_terms.svg"),     // 11
        DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),        // 12
      ];
    }
  }

  Rx<DateTime> currentBackPressTime = DateTime.now().obs;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime.value) > const Duration(seconds: 2)) {
      currentBackPressTime.value = now;
      ShowToastDialog.showToast("Double press to exit",
          position: EasyLoadingToastPosition.center);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class DrawerItem {
  String title;
  String icon;

  DrawerItem(this.title, this.icon);
}
