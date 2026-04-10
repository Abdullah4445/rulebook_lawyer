// ignore_for_file: file_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/currency_model.dart';
import '../model/language_model.dart';

class Preferences {
  static const isFinishOnBoardingKey = "isFinishOnBoardingKey";
  static const languageCodeKey = "languageCodeKey";
  static const themKey = "themKey";

  static const currencyKey = "currencyKey";
  static const isCurrAndLangAccessed = "isCurrAndLangAccessed";
  static const isLocationDetermined = "isLocationDetermined";

  static late SharedPreferences pref;

  static initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  Future<void> saveLanguage(LanguageModel language) async {
    await Preferences.setString(Preferences.languageCodeKey, jsonEncode(language));
  }

  LanguageModel? loadLanguage() {
    String savedLanguage = Preferences.getString(Preferences.languageCodeKey);
    if (savedLanguage.isNotEmpty) {
      return LanguageModel.fromJson(jsonDecode(savedLanguage));
    }
    return null;
  }

  Future<void> saveCurrency(CurrencyModel currency) async {
    await Preferences.setString(Preferences.currencyKey, jsonEncode(currency));
  }

  CurrencyModel? loadCurrency() {
    String savedCurrency = Preferences.getString(Preferences.currencyKey);
    if (savedCurrency.isNotEmpty) {
      return CurrencyModel.fromJson(jsonDecode(savedCurrency));
    }
    return null;
  }

  static bool getBoolean(String key) {
    return pref.getBool(key) ?? false;
  }

  static Future<void> setBoolean(String key, bool value) async {
    await pref.setBool(key, value);
  }

  static String getString(String key) {
    return pref.getString(key) ?? "";
  }

  static Future<void> setString(String key, String value) async {
    await pref.setString(key, value);
  }

  static int getInt(String key) {
    return pref.getInt(key) ?? 0;
  }

  static Future<void> setInt(String key, int value) async {
    await pref.setInt(key, value);
  }

  static Future<void> clearSharPreference() async {
    await pref.clear();
  }

  static Future<void> clearKeyData(String key) async {
    await pref.remove(key);
  }
}
