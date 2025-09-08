
class Matiere {
  final int? id;
  final String nom;
  final int? idFiliere;

  Matiere({
    this.id,
    required this.nom,
    required this.idFiliere,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'],
      nom: json['nom'],
      idFiliere: json['id_filiere'] ?? json['idFiliere'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Correction ici: Utiliser 'id_filiere' pour correspondre au backend
      'nom': nom,
      'id_filiere': idFiliere,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}