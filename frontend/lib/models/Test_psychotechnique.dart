import 'package:frontend/models/Utilisateur.dart';
import 'dart:convert'; 

class TestPsychotechnique {
  final String matricule;
  final String secteur;
  final List<String> metiers;
  final String questionsJson;
  final String reponsesJson;
  final String resultatsJson;
  final Utilisateur? utilisateur; 
  final String datePassage; 
  

  TestPsychotechnique({
    required this.matricule,
    required this.secteur,
    required this.metiers,
    required this.questionsJson,
    required this.reponsesJson,
    required this.resultatsJson,
    required this.utilisateur,
    required this.datePassage, 
  });

 factory TestPsychotechnique.fromJson(Map<String, dynamic> json) {
    // Le backend Java renvoie la liste de String directement pour 'metiers'
    final List<String> metiersList = 
        (json['metiers'] as List?)?.map((item) => item.toString()).toList() ?? [];

   
    // Le champ 'datePassage' peut être une chaîne de caractères ou un objet date complexe, 
    // nous le prenons comme une simple chaîne pour simplifier.
    String dateStr = json['datePassage'] != null 
        ? DateTime.parse(json['datePassage']).toLocal().toString().split('.')[0]
        : 'Date inconnue';


    return TestPsychotechnique(
      //id: json['id'] as int?,
      secteur: json['secteur'] as String? ?? 'N/A',
      metiers: metiersList,
      questionsJson: json['questionsJson'] as String? ?? '{}',
      reponsesJson: json['reponsesJson'] as String? ?? '{}',
      resultatsJson: json['resultatsJson'] as String? ?? '{}',
      datePassage: dateStr, matricule: '', 
      utilisateur: null,
      
    );
  }

  // Méthode utilitaire pour décoder les résultats formatés par Mistral
  Map<String, dynamic> get decodedResults {
    try {
      if (resultatsJson == null || resultatsJson.isEmpty || resultatsJson == "null") {
        return {};
      }
      final decoded = jsonDecode(resultatsJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List && decoded.isEmpty) {
        // Cas où le backend renvoie [] au lieu d'un objet
        return {};
      } else {
        print("Format inattendu pour resultatsJson: $decoded");
        return {};
      }
    } catch (e) {
      print("Erreur de décodage JSON des résultats: $e");
      return {};
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "matricule": matricule,
      "secteur": secteur,
      "metiers": metiers,
      "questionsJson": questionsJson,
      "reponsesJson": reponsesJson,
      "resultatsJson": resultatsJson,
      "utilisateur": utilisateur?.toJson(),
      "datePassage": datePassage,
    };
  }
  
}