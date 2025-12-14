import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/app_controller.dart';
import 'package:jar_talk/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jar_talk/controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Get.putAsync(() => AppController().init());
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();

    return Obx(() {
      final theme = appController.currentTheme.value;
      return GetMaterialApp.router(
        title: 'Jar Talk',
        theme: theme.toThemeData(),
        // We explicitly define brightness in the theme data, so we don't need separate darkTheme
        // or themeMode toggling. The Theme itself carries the brightness info.
        themeMode: ThemeMode
            .light, // Force light so it respects our explicit ThemeData brightness?
        // Actually, if we set brightness in ThemeData, Flutter uses it.
        // Let's just set themeMode to ThemeMode.light to avoid system interference if we want strict control,
        // or just let the theme define it.
        debugShowCheckedModeBanner: false,
        locale: appController.locale.value,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routerDelegate: AppRouter.router.routerDelegate,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
      );
    });
  }
}
