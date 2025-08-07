import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/etablissment/dashboard_layout.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/apprenant2/test_psychotechnique.dart';
import 'package:frontend/utils/common_widgets/invalid_route.dart';
import 'package:frontend/values/app_routes.dart';


class Routes {
  const Routes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Route<dynamic> getRoute({
      required Widget widget,
      bool fullscreenDialog = false,
    }) {
      return MaterialPageRoute<void>(
        builder: (context) => widget,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return getRoute(widget: const LoginPage());

      case AppRoutes.register:
        return getRoute(widget: const RegisterPage());

      case AppRoutes.dashboard:
      final utilisateur = settings.arguments;
      if (utilisateur is Utilisateur) {
        return getRoute(widget: DashboardLayout(utilisateur: utilisateur));
      } else {
        return getRoute(widget: const InvalidRoute());
      }

      case AppRoutes.test:
      final args = settings.arguments as Map<String, dynamic>?;
      final secteur = args?['secteur'] ?? '';
      final metiers = args?['metiers'] ?? <String>[];
      final autreMetier=args?['autreMetier'] ?? '';
      final niveauEtude=args?['niveauEtude'] ?? '';
      return getRoute(
        widget: TestPsychotechniqueScreen(
          secteur: secteur,
          metiers: metiers,
          autreMetier: autreMetier,
          niveauEtude: niveauEtude,
        ),
      );


      default:
        return getRoute(widget: const InvalidRoute());
    }
  }
}
