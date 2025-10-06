import 'package:flutter/material.dart';

import 'routes.dart';
import 'utils/helpers/navigation_helper.dart';
import 'utils/helpers/snackbar_helper.dart';
import 'values/app_routes.dart';
import 'values/app_strings.dart';
import 'values/app_theme.dart';
import 'values/theme_controller.dart';

class LoginRegisterApp extends StatelessWidget {
  const LoginRegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.loginAndRegister,
          theme: AppTheme.themeData,
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          initialRoute: AppRoutes.accueil,
          scaffoldMessengerKey: SnackbarHelper.key,
          navigatorKey: NavigationHelper.key,
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}
