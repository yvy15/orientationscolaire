import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/admin/layout_administrateur.dart';
import 'package:frontend/screens/apprenant1/dashboard_layout.dart';
import 'package:frontend/screens/apprenant2/dashboard_layout.dart';
import 'package:frontend/screens/etablissment/dashboard_layout.dart';
import 'package:frontend/services/Authservices.dart';
import 'package:frontend/utils/helpers/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/app_text_form_field.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  void initializeControllers() {
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 👉 Bandeau teal arrondi en haut
            SizedBox(
              height: size.height * 0.35,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(size.width, size.height * 0.35),
                    painter: _HeaderPainter(),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Bienvenue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Se connecter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextFormField(
                      controller: emailController,
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseEnterEmailAddress
                            : AppConstants.emailRegex.hasMatch(value)
                                ? null
                                : AppStrings.invalidEmailAddress;
                      },
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable: passwordNotifier,
                      builder: (_, passwordObscure, __) {
                        return AppTextFormField(
                          obscureText: passwordObscure,
                          controller: passwordController,
                          labelText: "Mot de passe",
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            return value!.isEmpty
                                ? AppStrings.pleaseEnterPassword
                                : AppConstants.passwordRegex.hasMatch(value)
                                    ? null
                                    : AppStrings.invalidPassword;
                          },
                          suffixIcon: IconButton(
                            onPressed: () =>
                                passwordNotifier.value = !passwordObscure,
                            icon: Icon(
                              passwordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),

                    // Remember me + Forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle,
                                size: 18, color: Colors.teal),
                            SizedBox(width: 6),
                            Text("se souvenir de moi",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "oublié le mot de passe?",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bouton dégradé teal
                    ValueListenableBuilder(
                      valueListenable: fieldValidNotifier,
                      builder: (_, isValid, __) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ).copyWith(
                              backgroundColor: WidgetStateProperty.all(null),
                            ),
                            onPressed: isValid ? seconnecter : null,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                constraints: const BoxConstraints(
                                  minHeight: 50,
                                ),
                                child: const Text(
                                  "Se connecter",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Register Now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous n'avez pas de compte?"),
                TextButton(
                  onPressed: () => NavigationHelper.pushReplacementNamed(
                    AppRoutes.register,
                  ),
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(color: Color(0xFF005F73)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void seconnecter() async {
    try {
      final authService = AuthService();
      final utilisateur = await authService.seconnecter(
          emailController.text, passwordController.text);

      if (utilisateur != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nom_user', utilisateur.nom_user ?? '');
        await prefs.setString('email', utilisateur.email ?? '');
        await prefs.setString('role', utilisateur.role ?? '');
        await prefs.setString('token', utilisateur.token ?? '');
        await prefs.setBool('estComplet', utilisateur.estComplet);
        await prefs.setInt('id', utilisateur.id ?? 0);

        switch (utilisateur.role) {
          case 'Etablissement':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DashboardLayout(utilisateur: utilisateur)),
            );
            break;
          case 'Admin':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      LayoutAdministrateur(utilisateur: utilisateur)),
            );
            break;
          case 'Apprenant1':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      DashboardLayoutApprenant(utilisateur: utilisateur)),
            );
            break;
          case 'Apprenant2':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      DashboardLayoutApprenant1(utilisateur: utilisateur)),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rôle inconnu.')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }
}

// 🎨 Dessine la forme teal en haut
class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
