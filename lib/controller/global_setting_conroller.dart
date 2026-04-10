import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/currency_model.dart';
import 'package:lawyer/model/language_model.dart';
import 'package:lawyer/services/localization_service.dart';
import 'package:lawyer/utils/Preferences.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/utils.dart';

class GlobalSettingController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() async {
    super.onInit();
    await initializeAppSettings();
    // await getCurrentCurrencyAndLanguage();
    isLoading.value = false;
  }

  static void showIncomingCall(RemoteMessage message) async {
    final String callerId = message.data['orderId'] ?? 'unknown';
    final String callerName = message.data['title'] ?? 'New Client Request';
    final String callerNumber = message.data['body'] ?? 'Tap to view case details';

    final CallKitParams params = CallKitParams(
      id: callerId,
      nameCaller: callerName,
      handle: callerNumber,
      type: 0,
      duration: 30000,
      textAccept: 'View Case',
      textDecline: 'Reject',
      ios: const IOSParams(
        iconName: 'Rulebook',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> initializeAppSettings() async {
    // Check if location has been determined previously
    // bool isLocationDetermined = Preferences.getBoolean(Preferences.isLocationDetermined);
    //
    // if (!isLocationDetermined) {
    try {
      // Determine the current position
      Position currentPosition = await Utils.determinePosition();
      FireStoreUtils.getGoogleAPIKey();
      // Get the corresponding zone (which contains language and currency info)
      MyZoneModel? zone = await getZoneForPosition(currentPosition);
      print("My ZONE is: ${zone?.name.toString()}");

      if (zone != null) {
        print("My ZONE is: ${zone.toString()}");
        // Update language based on the zone's language setting
        String langCode = zone.language;
        Locale newLocale = Locale(langCode);
        Get.updateLocale(newLocale);
        LocalizationService.locale = newLocale;

        // Optionally, update a global or local currency variable
        myCurrencyId = zone.currency;
        myLanguageId = zone.language;
        print("currency is: $myCurrencyId");
        print("language is: $myLanguageId");
      } else {
        print("No matching zone found for the current location. Using default language.");
      }
    } catch (e) {
      print("Error determining location: $e");
    }
    // Set the flag to true so we don't determine location again
    //   await Preferences.setBoolean(Preferences.isLocationDetermined, true);
    // }

    // Now, load or fetch the currency and language settings.
    await getCurrentCurrencyAndLanguage();
 
  }



  Future<void> getCurrentCurrencyAndLanguage() async {
    // --- Language Handling ---
    // LanguageModel? languageModel = Preferences().loadLanguage();
    // print("Language Model is $languageModel");
    // if (languageModel != null) {
    //   // Use saved language
    //   LocalizationService().changeLocale(languageModel.code.toString());
    // } else {
    // Fetch languages from Firestore
    List<LanguageModel>? languageList = await FireStoreUtils.getLanguage();
    if (languageList != null && languageList.isNotEmpty) {
      // Get the default language or pick the first one
      LanguageModel? languageModel = languageList
          .firstWhere((lang) => lang.isDefault ?? false, orElse: () => languageList[0]);
      await Preferences().saveLanguage(languageModel);
      print("My lanugage mOdle is: ${languageModel.code}");
      LocalizationService().changeLocale(myLanguageId);
    }
    // }
    // --- Currency Handling ---
    // CurrencyModel? currencyModel = Preferences().loadCurrency();
    // print("Currency Model is: $currencyModel");
    // if (currencyModel != null) {
    //   Constant.currencyModel = currencyModel;
    // } else {

    CurrencyModel? currencyModel = await FireStoreUtils().getCurrency();
    if (currencyModel != null) {
      Constant.currencyModel = Constant.forcePkrCurrency(currencyModel);
      await Preferences().saveCurrency(Constant.currencyModel!);
      update();
    } else {
      // Fallback to default currency if none is fetched
      Constant.currencyModel = Constant.defaultPkrCurrency;
    }
  }
}
