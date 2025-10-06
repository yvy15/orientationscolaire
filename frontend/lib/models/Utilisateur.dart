class Utilisateur{
  final String nom_user;
  final String email;
  final String role;
  final String token;
  final bool estComplet;
  final int id;

  Utilisateur({
    required this.token,
    required this.nom_user,
    required this.email,
    required this.role,
    this.estComplet = false, // Valeur par défaut pour un booléen
    this.id = 0,// Valeur par défaut pour un entier
    
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
  return Utilisateur(
    token: json['token'] as String? ?? '',
    nom_user: json['nom_user'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    estComplet: json['estComplet'] is bool
        ? json['estComplet']
        : json['estComplet']?.toString().toLowerCase() == 'true',
    id: json['id'] == null
        ? 0
        : (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0),
  );
}


  get id_etablissement => null;
  
Map<String, dynamic> toJson() {
  return {
    'token': token,
    'nom_user': nom_user,
    'email': email,
    'role': role,
    'estComplet': estComplet,
    'id': id,

  };
}

}
