class Apprenant {
  final String matricule;
  final String id_user;
  final String niveau;
  final String etablissment;
  final String secteur_activite;
  final String token;
  final String? classe;
  final String? filiere;
  final DateTime? dateInscription;

  Apprenant({
    required this.token,
    required this.matricule,
    required this.id_user,
    required this.niveau,
    required this.etablissment,
    required this.secteur_activite,
    this.classe,
    this.filiere,
    this.dateInscription,
  });

  factory Apprenant.fromJson(Map<String, dynamic> json) {
    return Apprenant(
      token: json['token'] ?? '',
      matricule: json['matricule'] ?? '',
      id_user: json['id_user'] ?? '',
      niveau: json['niveau'] ?? '',
      etablissment: json['etablissment'] ?? '',
      secteur_activite: json['secteur_activite'] ?? '',
      classe: json['classe'],
      filiere: json['filiere'],
      dateInscription: json['dateInscription'] != null ? DateTime.tryParse(json['dateInscription']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'matricule': matricule,
      'id_user': id_user,
      'niveau': niveau,
      'etablissment': etablissment,
      'secteur_activite': secteur_activite,
      'classe': classe,
      'filiere': filiere,
      'dateInscription': dateInscription?.toIso8601String(),
    };
  }
}