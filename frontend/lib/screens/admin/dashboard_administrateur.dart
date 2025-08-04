import 'package:flutter/material.dart';

class DashboardAdministrateur extends StatelessWidget {
  const DashboardAdministrateur({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6, // Rendu plus compact
        children: const [
          CarteDashboard(
            couleur: Color(0xFF1565C0),
            icone: Icons.school,
            titre: "Apprenants Scolarisés",
          ),
          CarteDashboard(
            couleur: Color(0xFFEF6C00),
            icone: Icons.person_pin,
            titre: "Apprenants Indépendants",
          ),
          CarteDashboard(
            couleur: Color(0xFF2E7D32),
            icone: Icons.account_balance,
            titre: "Établissements",
          ),
          CarteDashboard(
            couleur: Color(0xFF6A1B9A),
            icone: Icons.people,
            titre: "Total Utilisateurs",
          ),
        ],
      ),
    );
  }
}

class CarteDashboard extends StatelessWidget {
  final Color couleur;
  final IconData icone;
  final String titre;

  const CarteDashboard({
    super.key,
    required this.couleur,
    required this.icone,
    required this.titre,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: couleur,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
