import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/widgets/info_card.dart';

class DashboardHome extends StatelessWidget {
  final Utilisateur utilisateur;

  const DashboardHome({super.key, required this.utilisateur});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final isLargeScreen = screenWidth > 600;

    return Stack(
      children: [
        // 🎓 Fond éducatif défilant (modifiable)
        SizedBox.expand(
          child: PageView(
            children: [
              // 👉 AJOUTER ICI VOS IMAGES DANS assets/images/...
              const Image(
                image: AssetImage("assets/img1.jpeg"),
                fit: BoxFit.cover,
              ),
              const Image(
                image: AssetImage("assets/img2.jpeg"),
                fit: BoxFit.cover,
              ),
              const Image(
                image: AssetImage("assets/logo.png"),
                fit: BoxFit.cover,
              ),
              
            ],
          ),
        ),

        // 🎨 Superposition du contenu avec fond flouté
        Container(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.5),
        ),

        // Contenu principal
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // En-tête de bienvenue
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenue ${utilisateur.nom_user}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenue sur notre plateforme éducative',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // Cartes info (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      InfoCard(title: '👨‍🎓 Élèves total', value: '124'),
                      InfoCard(title: '✅ Tests complétés', value: '87'),
                      InfoCard(title: '💡 Recommandations', value: '62'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Zone dynamique : Graphiques ou contenu supplémentaire
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: Text(
                        'Graphiques à insérer ici',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
