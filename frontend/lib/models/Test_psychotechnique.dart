import 'package:frontend/models/Utilisateur.dart';

class TestPsychotechnique {
  final String matricule;
  final String secteur;
  final List<String> metiers;
  final String questionsJson;
  final String reponsesJson;
  final String resultatsJson;
  final Utilisateur utilisateur; 

  TestPsychotechnique({
    required this.matricule,
    required this.secteur,
    required this.metiers,
    required this.questionsJson,
    required this.reponsesJson,
    required this.resultatsJson,
    required this.utilisateur,
  });

  Map<String, dynamic> toJson() {
    return {
      "matricule": matricule,
      "secteur": secteur,
      "metiers": metiers,
      "questionsJson": questionsJson,
      "reponsesJson": reponsesJson,
      "resultatsJson": resultatsJson,
      "utilisateur": utilisateur.toJson(),
    };
  }

  static fromJson(e) {}
}
