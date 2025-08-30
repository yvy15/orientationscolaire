class Matiere {
  final int id;
  final String nom;
  final int? idFiliere;

  Matiere({
    required this.id,
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
    return {
      'id': id,
      'nom': nom,
      'id_filiere': idFiliere,
    };
  }
}