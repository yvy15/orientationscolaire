import 'package:flutter/material.dart';

class PageResultat extends StatelessWidget {
  final Map<String, dynamic> resultats;
  final List<String> metiers;

  const PageResultat({
    super.key,
    required this.resultats,
    required this.metiers,
  });

  @override
  Widget build(BuildContext context) {
    final scores = resultats['scores'] as Map<String, dynamic>? ?? {};
    final recommandations = List<String>.from(resultats['recommandations'] ?? []);
    final filieres = List<String>.from(resultats['filieres'] ?? []);
    final alternatives = List<String>.from(resultats['alternatives'] ?? []);
    final conseils = List<String>.from(resultats['conseils'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du Test'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              "Vos scores par métier",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.teal[800],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...metiers.map((m) {
              final score = scores[m];
              if (score == null) return const SizedBox();
              final pourcentage = score is Map ? (score['pourcentage'] ?? 0) : 0;
              final niveau = score is Map ? (score['niveau'] ?? "") : "";
              return _AnimatedScoreBar(
                metier: m,
                pourcentage: pourcentage is int ? pourcentage : int.tryParse("$pourcentage") ?? 0,
                niveau: niveau,
              );
            }),
            const SizedBox(height: 32),
            if (recommandations.isNotEmpty) ...[
              _SectionTitle("Recommandations de carrière"),
              ...recommandations.map((r) => _AnimatedTextCard(text: r)),
              const SizedBox(height: 24),
            ],
            if (filieres.isNotEmpty) ...[
              _SectionTitle("Filières adaptées"),
              ...filieres.map((f) => _AnimatedTextCard(text: f)),
              const SizedBox(height: 24),
            ],
            if (alternatives.isNotEmpty) ...[
              _SectionTitle("Alternatives proposées"),
              ...alternatives.map((a) => _AnimatedTextCard(text: a)),
              const SizedBox(height: 24),
            ],
            if (conseils.isNotEmpty) ...[
              _SectionTitle("Conseils personnalisés"),
              ...conseils.map((c) => _AnimatedTextCard(text: c)),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedScoreBar extends StatelessWidget {
  final String metier;
  final int pourcentage;
  final String niveau;

  const _AnimatedScoreBar({
    required this.metier,
    required this.pourcentage,
    required this.niveau,
  });

  Color get color {
    if (pourcentage >= 80) return Colors.green;
    if (pourcentage >= 60) return Colors.lightGreen;
    if (pourcentage >= 40) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: pourcentage / 100),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metier,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$pourcentage%",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    niveau,
                    style: TextStyle(
                      color: Colors.teal[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.teal[900],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _AnimatedTextCard extends StatefulWidget {
  final String text;
  const _AnimatedTextCard({required this.text});

  @override
  State<_AnimatedTextCard> createState() => _AnimatedTextCardState();
}

class _AnimatedTextCardState extends State<_AnimatedTextCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.text,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}