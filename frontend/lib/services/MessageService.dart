
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';

class MessageService {
  static final String baseUrl = "${ApiConfig.baseUrl}/messages";

  // Récupérer l'id de l'utilisateur de l'établissement affilié à un apprenant
  static Future<int?> getEtablissementUtilisateurId(int apprenantId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/apprenants/$apprenantId/etablissement-utilisateur-id'));
    if (response.statusCode == 200) {
      return int.tryParse(response.body);
    } else {
      print('Erreur récupération id utilisateur établissement : ${response.body}');
      return null;
    }
  }

  // Récupérer le fil de discussion entre deux utilisateurs
  static Future<List<Map<String, dynamic>>> getFilDiscussion(int user1Id, int user2Id) async {
    final response = await http.get(Uri.parse('$baseUrl/fil?user1Id=$user1Id&user2Id=$user2Id'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      // Gérer le cas d'une erreur 404 (Not Found), 500 (Internal Server Error), etc.
      throw Exception('Erreur lors de la récupération des messages. Code: ${response.statusCode}');
    }
  }

  // Envoyer un message
  static Future<void> envoyerMessage(int expediteurId, int destinataireId, String contenu) async {
    final response = await http.post(
      Uri.parse('$baseUrl/envoyer?expediteurId=$expediteurId&destinataireId=$destinataireId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"contenu": contenu}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Gérer les erreurs côté serveur de manière plus spécifique
      print('Erreur du serveur: ${response.body}');
      throw Exception('Échec de l\'envoi du message. Code: ${response.statusCode}');
    }
  }

  // Récupérer les conversations (dernier message par expéditeur)
  static Future<List<Map<String, dynamic>>> getConversations(int destinataireId) async {
    final response = await http.get(Uri.parse('$baseUrl/conversations?destinataireId=$destinataireId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Erreur récupération conversations : ${response.body}");
    }
  }


// Récupérer toutes les conversations d’un utilisateur (expéditeur OU destinataire)
static Future<List<Map<String, dynamic>>> getConversationsUser(int utilisateurId) async {
  final response = await http.get(Uri.parse('$baseUrl/conversations-user?utilisateurId=$utilisateurId'));
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    throw Exception("Erreur récupération conversations utilisateur : ${response.body}");
  }
}

  static Future<void> supprimerMessage(int messageId) async {}


  static Future<Map<String, dynamic>?> getConseiller(int apprenantId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/apprenants/$apprenantId/conseiller'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Si le backend renvoie un objet Utilisateur
      if (data is Map<String, dynamic> && data.containsKey('id')) {
        return data;
      }
      // Si le backend renvoie un message d'erreur
      return null;
    } else {
      // Gérer les erreurs explicites du backend
      print('Erreur récupération conseiller : ${response.body}');
      return null;
    }
  }

}