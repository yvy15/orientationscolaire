import 'Matiere.dart';

class Note {
  final int id;
  final double valeur;
  final int idApprenant;
  final int idMatiere;
  final String typeEval;
  final DateTime dateEval;
  final String matiere; // <-- ici on précise bien le type

  Note({
    required this.id,
    required this.valeur,
    required this.idApprenant,
    required this.idMatiere,
    required this.typeEval,
    required this.dateEval,
    required this.matiere, 
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      valeur: (json['notes'] as num).toDouble(),
      idApprenant: json['id_apprenant'],
      idMatiere: json['id_matiere'],
      typeEval: json['type_eval'],
      dateEval: DateTime.parse(json['date_eval']),
      matiere: json['matiere']); 
    
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': valeur,
      'id_apprenant': idApprenant,
      'id_matiere': idMatiere,
      'type_eval': typeEval,
      'date_eval': dateEval.toIso8601String(),
      'matiere': matiere,
    };
  }
}
