import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/models/Utilisateur.dart';


class AuthService {
  final String baseUrl = 'http://localhost:8080/api/auth'; // à adapter // lien vers le controller d'authentification : si l'adresse est en chiffre alors le fontend n'est pas dans le meme reseau que le backend , et ils sont dans le meme reseau dan le cas contraire qu'il y'a localhost. 


  Future<Utilisateur?> seconnecter(String email, String mot_passe) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mot_passe': mot_passe,
        }),
      ).timeout(Duration(seconds: 20)); // ← timeout ici //temps d'attente pour que le backend renvoie les informations attendues

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'];
        final nom_user = data['nom_user'];
        final email = data['email'];
        final role = data['role'];

        if (token == null || nom_user == null || email == null || role == null) {
          throw Exception('Réponse invalide du serveur');
        }

        return Utilisateur(
          token: token,
          nom_user: nom_user,
          email: email,
          role: role,
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

  Future<Map<String, dynamic>> inscrire(String nom_user, String email, String mot_passe, String role) async {
    final url = Uri.parse('$baseUrl/inscrire');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom_user': nom_user,
          'email': email,
          'mot_passe': mot_passe,
          'role': role,
        }),
      ).timeout(Duration(seconds: 20));

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
