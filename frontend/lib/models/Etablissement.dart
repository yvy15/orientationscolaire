import 'package:frontend/models/Utilisateur.dart';

class Etablissement {
  final int id;
  final String nom;
  final String region;
  final Utilisateur utilisateur;

  Etablissement({
    required this.id,
    required this.nom,
    required this.region,
    required this.utilisateur,
  });

  factory Etablissement.fromJson(Map<String, dynamic> json) {
  return Etablissement(
    id: json['id'] as int? ?? 0, // Utilisez 0 comme valeur par défaut pour un ID
    nom: json['nom'] as String? ?? '', // Chaîne vide par défaut
    region: json['region'] as String? ?? '', // Chaîne vide par défaut
    utilisateur: Utilisateur.fromJson(json['utilisateur'] as Map<String, dynamic>? ?? {}), // Assurez-vous que c'est un Map
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'region': region,
      'utilisateur': utilisateur.toJson(), // Assurez-vous que Utilisateur a une méthode toJson
    };
  }
}