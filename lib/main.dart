import 'package:country_code_picker/country_code_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/ui/splash_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// nawa kam
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controller/global_setting_conroller.dart';
import 'firebase_options.dart';
import 'services/localization_service.dart';
import 'themes/Styles.dart';
import 'utils/Preferences.dart';
// not working

/// Handles background notifications
/// new code pushing

@pragma('vm:entry-point')
Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  print("BackGround Message Is now working :: ${message.messageId}");
  GlobalSettingController.showIncomingCall(message);
}

Future<void> _initializeFirebase() async {
  await Preferences.initPref();
}

void main() async {
  print("Faheem work will start from here!");
  WidgetsFlutterBinding.ensureInitialized();
  print("ðŸŒ¼ Firebase Initialized ðŸŒ¼");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessageBackgroundHandle);
  await _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    _setupAppLifecycleListeners();
  }

  void _setupAppLifecycleListeners() {
    WidgetsBinding.instance.addObserver(this);
    _updateTheme();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateTheme();
  }

  void _updateTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'Rulebook Lawyer',
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
              themeChangeProvider.darkTheme == 0
                  ? true
                  : themeChangeProvider.darkTheme == 1
                      ? false
                      : themeChangeProvider.getSystemThem(),
              context,
            ),
            localizationsDelegates: const [
              CountryLocalizations.delegate,
            ],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetX<GlobalSettingController>(
              init: GlobalSettingController(),
              builder: (controller) {
                return controller.isLoading.value
                    ? Constant.loader(context)
                    : const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
