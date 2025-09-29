import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static final String baseUrl = "${ApiConfig.baseUrl}/notes";

  Future<List<Map<String, dynamic>>> getNotes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement des notes');
    }
  }

  Future<void> ajouterNote(Map<String, dynamic> note) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'ajout de la note');
    }
  }

  Future<void> modifierNote(int id, Map<String, dynamic> note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de la note');
    }
  }

  Future<void> supprimerNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la note');
    }
  }



 static Future<Map<String, dynamic>> getNotesParTypeParMatiere(String matricule) async {
    final response = await http.get(Uri.parse('$baseUrl/type-matiere/$matricule'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des notes");
    }
  }


  // Récupérer les notes de l'établissement connecté (utilisateur authentifié)
Future<List<Map<String, dynamic>>> getNotesEtablissementConnecte() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  if (email == null || email.isEmpty) {
    throw Exception('Email de l\'utilisateur non trouvé.');
  }
  
  // Utilise le nouvel endpoint /by-user-email
  final uri = Uri.parse('$baseUrl/by-user-email').replace(
    queryParameters: {'email': email},
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Erreur lors du chargement des notes');
  }
}


}
