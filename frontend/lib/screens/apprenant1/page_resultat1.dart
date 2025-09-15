import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class ResultatsDialogContent1 extends StatefulWidget {
  final Map<String, dynamic> resultats1;
  final List<String> sousMetiersChoisis1;

  const ResultatsDialogContent1({
    super.key,
    required this.resultats1,
    required this.sousMetiersChoisis1,
  });

  @override
  State<ResultatsDialogContent1> createState() =>
      _ResultatsDialogContent1State();
}

class _ResultatsDialogContent1State extends State<ResultatsDialogContent1>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _scoreController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;
  bool _isLoading = true;
  int _loadingTextIndex = 0;
  final List<String> _loadingTexts = [
    "Analyse du profil cognitif...",
    "Traitement des réponses...",
    "Calcul des scores...",
    "Génération des recommandations...",
    "Finalisation du rapport...",
  ];
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _scoreAnimation =
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic);

    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isLoading) return;
      setState(() {
        _loadingTextIndex = (_loadingTextIndex + 1) % _loadingTexts.length;
      });
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _isLoading = false;
      });
      _loadingTimer?.cancel();
      _introController.forward();
      Future.delayed(
          const Duration(milliseconds: 400), () => _scoreController.forward());
      Future.delayed(
          const Duration(milliseconds: 700), () => _fadeController.forward());
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _scoreController.dispose();
    _fadeController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scores = <String, dynamic>{};
    if (widget.resultats1['scores'] != null) {
      try {
        scores.addAll(Map<String, dynamic>.from(widget.resultats1['scores']));
      } catch (_) {}
    }

    final recommandations = widget.resultats1['recommandations'] is List
        ? List<String>.from(widget.resultats1['recommandations'])
        : [];

    final filieres = widget.resultats1['filieres'] is List
        ? List<String>.from(widget.resultats1['filieres'])
        : [];

    final alternatives = widget.resultats1['alternatives'] is List
        ? List<String>.from(widget.resultats1['alternatives'])
        : [];

    final conseils = widget.resultats1['conseils']?.toString();

    // Responsive width
    final double maxWidth = MediaQuery.of(context).size.width * 0.95;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 120,
                    height: 120,
                    repeat: true,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      _loadingTexts[_loadingTextIndex],
                      key: ValueKey(_loadingTextIndex),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF005F73),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated intro section
                    SizeTransition(
                      sizeFactor: _introController,
                      axis: Axis.vertical,
                      child: Row(
                        children: [
                          Lottie.asset(
                            'assets/lottie/education new color scheme.json',
                            width: 48,
                            height: 48,
                            repeat: true,
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 700),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F73),
                              letterSpacing: 1.2,
                            ),
                            child:
                                const Text("Résultats du Test Psychotechnique"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ...existing code for results UI...
                    FadeTransition(
                      opacity: _scoreAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lottie/Book Animation.json',
                                width: 32,
                                height: 32,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0077B6),
                                ),
                                child: const Text("Scores par sous-métier"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (widget.sousMetiersChoisis1.isEmpty)
                            const Text("Aucun score disponible."),
                          ...widget.sousMetiersChoisis1.map((metier) {
                            final scoreMap = scores[metier];
                            final score = (scoreMap is Map &&
                                    scoreMap['pourcentage'] != null)
                                ? int.tryParse(
                                        scoreMap['pourcentage'].toString()) ??
                                    0
                                : 0;
                            final niveau = (scoreMap is Map)
                                ? scoreMap['niveau']?.toString() ?? ''
                                : '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Niveau : $niveau"),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.blue.shade100,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF023E8A),
                                          ),
                                          child: Text("$metier : " +
                                              "${score}%${niveau.isNotEmpty ? ', niveau: $niveau' : ''}"),
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 700),
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: score >= 80
                                                  ? [
                                                      Colors.greenAccent,
                                                      Colors.green
                                                    ]
                                                  : score >= 60
                                                      ? [
                                                          Colors.lightGreen,
                                                          Colors.yellow
                                                        ]
                                                      : [
                                                          Colors.orange,
                                                          Colors.redAccent
                                                        ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              score >= 80
                                                  ? Icons.verified
                                                  : score >= 60
                                                      ? Icons.thumb_up
                                                      : Icons.warning,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                          begin: 0, end: score / 100),
                                      duration:
                                          const Duration(milliseconds: 1200),
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: Colors.grey.shade200,
                                          minHeight: 12,
                                          valueColor: AlwaysStoppedAnimation(
                                            score >= 80
                                                ? Colors.green
                                                : score >= 60
                                                    ? Colors.lightGreen
                                                    : Colors.redAccent,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    // ...existing code for recommandations, filieres, alternatives, conseils...
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lottie/Search for value.json',
                                width: 32,
                                height: 32,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF009688),
                                ),
                                child: const Text("Carrières recommandées"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...recommandations.map((r) => AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 700),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Carrière : $r"),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor:
                                              Colors.green.shade100,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            r,
                                            style:
                                                const TextStyle(fontSize: 16),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lottie/loading.json',
                                width: 32,
                                height: 32,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3A86FF),
                                ),
                                child: const Text("Filières suggérées"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...filieres.map((f) => AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 700),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Filière : $f"),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: Colors.blue.shade100,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.book,
                                            color: Colors.blue, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            f,
                                            style:
                                                const TextStyle(fontSize: 16),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lottie/Book Animation.json',
                                width: 32,
                                height: 32,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF006E),
                                ),
                                child: const Text("Alternatives proposées"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...alternatives.map((a) => AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 700),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Alternative : $a"),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: Colors.pink.shade100,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.change_circle,
                                            color: Colors.pink, size: 20),
                                        const SizedBox(width: 8),
                                        Text(a,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Lottie.asset(
                                'assets/lottie/education new color scheme.json',
                                width: 32,
                                height: 32,
                                repeat: true,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFC300),
                                ),
                                child: const Text("Conseils d'amélioration"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (conseils != null && conseils.isNotEmpty)
                            AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 700),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  conseils,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF444444)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
