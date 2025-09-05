import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/Config/ApiConfig.dart';

class UtilisateurService {
  static const String baseUrl = "${ApiConfig.baseUrl}/utilisateurs";

  Future<List<Utilisateur>> getAllUtilisateurs() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => Utilisateur.fromJson(user)).toList();
    }
    throw Exception('Erreur lors du chargement des utilisateurs');
  }

  Future<Utilisateur?> addUtilisateur(Utilisateur utilisateur) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(utilisateur.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Utilisateur.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<Utilisateur?> updateUtilisateur(Utilisateur utilisateur, int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(utilisateur.toJson()),
    );
    if (response.statusCode == 200) {
      return Utilisateur.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<bool> deleteUtilisateur(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 204;
  }
}
