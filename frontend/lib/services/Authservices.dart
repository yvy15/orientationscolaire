import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/Config/ApiConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/ApprenantService.dart';

class AuthService {
  // Résolution dynamique de l'URL du serveur (override > ApiConfig)
  Future<String> _resolveBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_base_url_override') ?? ApiConfig.baseUrl;
  }

  Future<Utilisateur?> seconnecter(String email, String motPasse) async {
    final base = await _resolveBaseUrl();
    final url = Uri.parse('$base/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'mot_passe': motPasse,
            }),
          )
          .timeout(const Duration(
              seconds: 30)); // timeout porté à 30s pour connexions lentes

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'];
        final nomUser = data['nom_user'];
        final email = data['email'];
        final role = data['role'];
        final estComplet = data['estComplet'];
        final id = data['id'] ?? 0;

        if (token == null ||
            nomUser == null ||
            email == null ||
            role == null ||
            estComplet == null ||
            id == 0) {
          throw Exception('Réponse invalide du serveur');
        }

        // Récupérer le matricule et le stocker dans SharedPreferences
        final matricule = await ApprenantService.getMatriculeByEmail(email);
        print('Matricule récupéré : $matricule');
        if (matricule != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('matricule', matricule);
        }

        return Utilisateur(
          token: token,
          nom_user: nomUser,
          email: email,
          role: role,
          estComplet: estComplet,
          id: id,
        );
      } else {
        String errorMessage = 'Erreur inconnue';

        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Réponse invalide du serveur';
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      // Affiche l’erreur exacte dans la console
      print('Erreur de connexion : $e');
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<Map<String, dynamic>> inscrire(
      String nomUser, String email, String motPasse, String role) async {
    final base = await _resolveBaseUrl();
    final url = Uri.parse('$base/auth/inscrire');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nom_user': nomUser,
              'email': email,
              'mot_passe': motPasse,
              'role': role,
            }),
          )
          .timeout(Duration(seconds: 20));

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        String errorMessage = 'Erreur inconnue';

        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Réponse invalide du serveur';
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion : $e',
      };
    }
  }
}
