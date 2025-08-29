import 'package:frontend/models/Etablissement.dart';

class Classe {
  final int? id;
  final String classe;
  final Etablissement? etablissement; // Changez le type ici

  Classe({
    this.id,
    required this.classe,
    required this.etablissement,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      id: json['id'] as int?,
      classe: json['classe'] as String,
      etablissement: json['etablissement'] != null
          ? Etablissement.fromJson(
              json['etablissement'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classe': classe,
      'etablissement': etablissement?.toJson(),
    };
  }
}
