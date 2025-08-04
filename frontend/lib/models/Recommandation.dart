class Recommandation{
  final String apprenant;
  final String filiere_suggerer;
  final String metier_suggerer;
  final String token;

  Recommandation({
    required this.token,
    required this.apprenant,
    required this.filiere_suggerer,
    required this.metier_suggerer,

    
  });

  factory Recommandation.fromJson(Map<String, dynamic> json) {
    return Recommandation(
      token: json['token'],
      apprenant: json['nom'],
      filiere_suggerer: json['filiere_suggerer'],
      metier_suggerer: json['metier_suggerer'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      apprenant: apprenant,
      filiere_suggerer: filiere_suggerer,
      metier_suggerer: metier_suggerer,
      
    };
  }
}
