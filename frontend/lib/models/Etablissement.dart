class Etablissement{
  final String nom;
  final String region;
  final String token;

  Etablissement({
    required this.token,
    required this.nom,
    required this.region,

    
  });

  factory Etablissement.fromJson(Map<String, dynamic> json) {
    return Etablissement(
      token: json['token'],
      nom: json['nom'],
      region: json['region'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      nom: nom,
      region: region,
      
    };
  }
}
