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
  int get logoutIndex => drawerItems.isEmpty ? -1 : drawerItems.length - 1;

  DrawerItem? get selectedDrawerItem {
    final index = selectedDrawerIndex.value;
    if (index < 0 || index >= drawerItems.length) {
      return null;
    }

    return drawerItems[index];
  }

  bool shouldShowAppBarTitle(int index) {
    if (index < 0 || index >= drawerItems.length) {
      return false;
    }

    if (index == logoutIndex) {
      return false;
    }

    return drawerItems[index].showAppBarTitle;
  }

  Widget getDrawerItemWidget(int pos) {
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

  Future<void> onSelectItem(int index) async {
    if (index == logoutIndex) {
      await FirebaseAuth.instance.signOut();
      Get.offAll(const LoginScreen());
    } else {
      selectedDrawerIndex.value = index;
    }

    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    setDrawerList();

    super.onInit();
  }

  void setDrawerList() {
    if (Constant.isSubscriptionModelApplied == true) {
      drawerItems.value = [
        const DrawerItem(
          'Cases',
          "assets/icons/cases.svg",
          subtitle: 'Track your ongoing and past matters',
          showAppBarTitle: false,
        ),
        const DrawerItem(
          'My Wallet',
          "assets/icons/ic_wallet.svg",
          subtitle: 'Top up and review payment activity',
        ),
        const DrawerItem(
          'Bank Details',
          "assets/icons/ic_profile.svg",
          subtitle: 'Manage your payout account information',
        ),
        const DrawerItem(
          'Inbox',
          "assets/icons/ic_inbox.svg",
          subtitle: 'Stay connected with clients and updates',
        ),
        const DrawerItem(
          'Profile',
          "assets/icons/ic_profile.svg",
          subtitle: 'Update your professional details',
        ),
        const DrawerItem(
          'Online Registration',
          "assets/icons/ic_document.svg",
          subtitle: 'Upload and manage your verification documents',
        ),
        const DrawerItem(
          'Lawyer Information',
          "assets/icons/lawyer.svg",
          subtitle: 'Maintain your practice and service details',
        ),
        const DrawerItem(
          'Settings',
          "assets/icons/ic_settings.svg",
          subtitle: 'Preferences, language and notifications',
        ),
        const DrawerItem(
          'AI Legal System',
          "assets/icons/ic_support.svg",
          subtitle: 'Research, drafting and smart legal assistance',
        ),
        const DrawerItem(
          'Subscription',
          "assets/icons/ic_subscription.svg",
          subtitle: 'Review available plans and upgrades',
        ),
        const DrawerItem(
          'Subscription History',
          "assets/icons/ic_subscription_history.svg",
          subtitle: 'View your past membership payments',
        ),
        const DrawerItem(
          'Terms and Conditions',
          "assets/icons/ic_terms.svg",
          subtitle: 'Read platform rules and usage policies',
        ),
        const DrawerItem(
          'Privacy Policy',
          "assets/icons/ic_terms.svg",
          subtitle: 'Understand how your data is protected',
        ),
        const DrawerItem(
          'Log out',
          "assets/icons/ic_logout.svg",
          subtitle: 'Securely sign out from your account',
        ),
      ];
    } else {
      drawerItems.value = [
        const DrawerItem(
          'Cases',
          "assets/icons/cases1.svg",
          subtitle: 'Track your ongoing and past matters',
          showAppBarTitle: false,
        ),
        const DrawerItem(
          'My Wallet',
          "assets/icons/ic_wallet.svg",
          subtitle: 'Top up and review payment activity',
        ),
        const DrawerItem(
          'Bank Details',
          "assets/icons/ic_profile.svg",
          subtitle: 'Manage your payout account information',
        ),
        const DrawerItem(
          'Inbox',
          "assets/icons/ic_inbox.svg",
          subtitle: 'Stay connected with clients and updates',
        ),
        const DrawerItem(
          'Profile',
          "assets/icons/ic_profile.svg",
          subtitle: 'Update your professional details',
        ),
        const DrawerItem(
          'Online Registration',
          "assets/icons/ic_document.svg",
          subtitle: 'Upload and manage your verification documents',
        ),
        const DrawerItem(
          'Lawyer Information',
          "assets/icons/lawyer.svg",
          subtitle: 'Maintain your practice and service details',
        ),
        const DrawerItem(
          'Settings',
          "assets/icons/ic_settings.svg",
          subtitle: 'Preferences, language and notifications',
        ),
        const DrawerItem(
          'AI Legal System',
          "assets/icons/ic_support.svg",
          subtitle: 'Research, drafting and smart legal assistance',
        ),
        const DrawerItem(
          'Subscription History',
          "assets/icons/ic_subscription_history.svg",
          subtitle: 'View your past membership payments',
        ),
        const DrawerItem(
          'Terms and Conditions',
          "assets/icons/ic_terms.svg",
          subtitle: 'Read platform rules and usage policies',
        ),
        const DrawerItem(
          'Privacy Policy',
          "assets/icons/ic_terms.svg",
          subtitle: 'Understand how your data is protected',
        ),
        const DrawerItem(
          'Log out',
          "assets/icons/ic_logout.svg",
          subtitle: 'Securely sign out from your account',
        ),
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
  final String title;
  final String icon;
  final String subtitle;
  final bool showAppBarTitle;

  const DrawerItem(
    this.title,
    this.icon, {
    this.subtitle = '',
    this.showAppBarTitle = true,
  });
}
