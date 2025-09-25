import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // Détection simple de plateforme pour choisir l’hôte correct en dev.
  // - Web/Desktop/iOS: 127.0.0.1
  // - Android Émulateur: 10.0.2.2
  // - Téléphone réel: remplacez manuellement par l’IP LAN de votre PC si besoin.
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://127.0.0.1:8080/api';
    }
  }
}
