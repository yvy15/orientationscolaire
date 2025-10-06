import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_register_app.dart';
import 'values/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeController.load().then((_) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
      (_) => runApp(const LoginRegisterApp()),
    );
  });
}
