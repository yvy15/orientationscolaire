import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/Config/ApiConfig.dart';


class AuthService {
  final String baseUrl = "${ApiConfig.baseUrl}/auth"; // à adapter // lien vers le controller d'authentification : si l'adresse est en chiffre alors le fontend n'est pas dans le meme reseau que le backend , 
  //et ils sont dans le meme reseau dan le cas contraire qu'il y'a localhost. 


  Future<Utilisateur?> seconnecter(String email, String motPasse) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mot_passe': motPasse,
        }),
      ).timeout(Duration(seconds: 20)); // ← timeout ici //temps d'attente pour que le backend renvoie les informations attendues

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'];
        final nomUser = data['nom_user'];
        final email = data['email'];
        final role = data['role'];
        final estComplet=data['estComplet'];
        final id = data['id'] ?? 0; 

        if (token == null || nomUser == null || email == null || role == null || estComplet == null || id == 0) {
          throw Exception('Réponse invalide du serveur');
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

  Future<Map<String, dynamic>> inscrire(String nomUser, String email, String motPasse, String role) async {
    final url = Uri.parse('$baseUrl/inscrire');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom_user': nomUser,
          'email': email,
          'mot_passe': motPasse,
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
