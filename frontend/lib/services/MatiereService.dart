import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/Matiere.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';


// Nouvelle classe DTO pour les requêtes POST/PUT
// Elle ne contient que les données nécessaires pour l'envoi.
class MatiereRequestDto {
  final String nom;
  final Map<String, int> filiere;

  MatiereRequestDto({
    required this.nom,
    required int filiereId,
  }) : filiere = {'id': filiereId};

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'filiere': filiere,
    };
  }
}

class MatiereService {
  final String baseUrl = "${ApiConfig.baseUrl}/matieres";

  Future<List<Matiere>> getMatieres(int filiereId) async {
    final response = await http.get(Uri.parse('$baseUrl?filiereId=$filiereId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Matiere.fromJson(json)).toList();
    } else {
      if (kDebugMode) {
        print('Erreur lors du chargement des matières - Statut: ${response.statusCode}');
        print('Erreur lors du chargement des matières - Corps: ${response.body}');
      }
      throw Exception('Erreur lors du chargement des matières: ${response.body}');
    }
  }

  Future<Matiere> ajouterMatiere(Matiere matiere) async {
    // Utiliser le DTO pour formater le corps de la requête
    final matiereDto = MatiereRequestDto(nom: matiere.nom, filiereId: matiere.idFiliere!);
    final body = json.encode(matiereDto.toJson());
    if (kDebugMode) {
      print('Envoi de la requête POST vers: $baseUrl');
      print('Corps de la requête: $body');
    }
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (kDebugMode) {
        print('Matière ajoutée avec succès! Statut: ${response.statusCode}');
      }
      return Matiere.fromJson(json.decode(response.body));
    } else {
      if (kDebugMode) {
        print('Erreur du serveur - Statut: ${response.statusCode}');
        print('Erreur du serveur - Corps: ${response.body}');
      }
      throw Exception('Erreur lors de l\'ajout de la matière: ${response.body}');
    }
  }

  Future<void> modifierMatiere(int id, Matiere matiere) async {
    // Utiliser le DTO pour formater le corps de la requête
    final matiereDto = MatiereRequestDto(nom: matiere.nom, filiereId: matiere.idFiliere!);
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matiereDto.toJson()),
    );
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('Erreur du serveur - Statut: ${response.statusCode}');
        print('Erreur du serveur - Corps: ${response.body}');
      }
      throw Exception('Erreur lors de la modification de la matière: ${response.body}');
    }
  }

  Future<void> supprimerMatiere(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (kDebugMode) {
        print('Erreur du serveur - Statut: ${response.statusCode}');
        print('Erreur du serveur - Corps: ${response.body}');
      }
      throw Exception('Erreur lors de la suppression de la matière: ${response.body}');
    }
  }
}
