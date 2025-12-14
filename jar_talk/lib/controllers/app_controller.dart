import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jar_talk/utils/app_theme.dart';

class AppController extends GetxController {
  late SharedPreferences _prefs;

  // Keys
  final String _keyThemeType = 'theme_type'; // Changed from theme_mode/color
  final String _keyLanguage = 'language';
  final String _keyIsLoggedIn = 'is_logged_in';
  final String _keyUserInfo = 'user_info';
  final String _keyIsFirstTime = 'is_first_time';
  final String _keyNotifications = 'notifications';

  // State
  // Hold the current AppTheme object
  final Rx<AppTheme> currentTheme = AppTheme.bruno().obs;
  // We can also expose the type directly for UI selection state
  AppThemeType get currentThemeType => currentTheme.value.type;

  final Rx<Locale> locale = const Locale('en', 'US').obs;
  final RxBool isLoggedIn = false.obs;
  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  final RxBool isFirstTime = true.obs;
  final RxBool notificationsEnabled = true.obs;

  Future<AppController> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    return this;
  }

  void _loadSettings() {
    // Theme Type
    String? typeStr = _prefs.getString(_keyThemeType);
    if (typeStr == 'patel') {
      currentTheme.value = AppTheme.patel();
    } else {
      currentTheme.value = AppTheme.bruno(); // Default
    }

    // Language
    String? langCode = _prefs.getString(_keyLanguage);
    if (langCode != null) {
      locale.value = Locale(langCode);
    }

    // Auth
    isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
    String? userInfoStr = _prefs.getString(_keyUserInfo);
    if (userInfoStr != null) {
      try {
        userInfo.value = jsonDecode(userInfoStr) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding user info: $e');
      }
    }

    // First Time
    isFirstTime.value = _prefs.getBool(_keyIsFirstTime) ?? true;

    // Notifications
    notificationsEnabled.value = _prefs.getBool(_keyNotifications) ?? true;
  }

  // Methods to update state

  void switchTheme(AppThemeType type) {
    if (type == AppThemeType.bruno) {
      currentTheme.value = AppTheme.bruno();
      _prefs.setString(_keyThemeType, 'bruno');
    } else {
      currentTheme.value = AppTheme.patel();
      _prefs.setString(_keyThemeType, 'patel');
    }

    // Apply the new theme immediately
    Get.changeTheme(currentTheme.value.toThemeData());
  }

  void changeLanguage(String langCode, String countryCode) {
    Locale newLocale = Locale(langCode, countryCode);
    locale.value = newLocale;
    _prefs.setString(_keyLanguage, langCode);
    Get.updateLocale(newLocale);
  }

  void login(Map<String, dynamic> user) {
    isLoggedIn.value = true;
    userInfo.value = user;
    _prefs.setBool(_keyIsLoggedIn, true);
    _prefs.setString(_keyUserInfo, jsonEncode(user));
  }

  void logout() {
    isLoggedIn.value = false;
    userInfo.clear();
    _prefs.setBool(_keyIsLoggedIn, false);
    _prefs.remove(_keyUserInfo);
  }

  void completeFirstTime() {
    isFirstTime.value = false;
    _prefs.setBool(_keyIsFirstTime, false);
  }

  void toggleNotifications(bool enable) {
    notificationsEnabled.value = enable;
    _prefs.setBool(_keyNotifications, enable);
  }
}
