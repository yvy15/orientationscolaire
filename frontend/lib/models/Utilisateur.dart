class Utilisateur{
  final String nom_user;
  final String email;
  final String role;
  final String token;
  final bool estComplet;

  Utilisateur({
    required this.token,
    required this.nom_user,
    required this.email,
    required this.role,
    this.estComplet = false,
    
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
  return Utilisateur(
    token: json['token'] as String? ?? '', // Valeur par défaut pour une chaîne
    nom_user: json['nom_user'] as String? ?? '', // Valeur par défaut pour une chaîne
    email: json['email'] as String? ?? '', // Valeur par défaut pour une chaîne
    role: json['role'] as String? ?? '', // Valeur par défaut pour une chaîne
    estComplet: json['estComplet'] is bool
        ? json['estComplet']
        : json['estComplet']?.toString().toLowerCase() == 'true', // Gérer les valeurs nulles
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
  };
}

}
