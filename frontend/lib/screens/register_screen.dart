import 'package:flutter/material.dart';
import 'package:frontend/services/Authservices.dart';
import '../components/app_text_form_field.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nom_userController;
  late final TextEditingController emailController;
  late final TextEditingController mot_passeController;
  late final TextEditingController confirmPasswordController;

  final ValueNotifier<bool> mot_passeNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  String? selectedRole;

  void initializeControllers() {
    nom_userController = TextEditingController()..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    mot_passeController = TextEditingController()..addListener(controllerListener);
    confirmPasswordController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    nom_userController.dispose();
    emailController.dispose();
    mot_passeController.dispose();
    confirmPasswordController.dispose();
  }

  void controllerListener() {
    final nomUser = nom_userController.text;
    final email = emailController.text;
    final motPasse = mot_passeController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nomUser.isEmpty &&
        email.isEmpty &&
        motPasse.isEmpty &&
        confirmPassword.isEmpty) {
      return;
    }

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(motPasse) &&
        AppRegex.passwordRegex.hasMatch(confirmPassword)) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bandeau teal arrondi
            CustomPaint(
              painter: _HeaderPainter(),
              child: Container(
                height: size.height * 0.28,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hello,",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Sign Up!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextFormField(
                      autofocus: true,
                      labelText: AppStrings.name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      controller: nom_userController,
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseEnterName
                            : value.length < 4
                                ? AppStrings.invalidName
                                : null;
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextFormField(
                      labelText: AppStrings.email,
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        return value!.isEmpty
                            ? AppStrings.pleaseEnterEmailAddress
                            : AppConstants.emailRegex.hasMatch(value)
                                ? null
                                : AppStrings.invalidEmailAddress;
                      },
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<bool>(
                      valueListenable: mot_passeNotifier,
                      builder: (_, passwordObscure, __) {
                        return AppTextFormField(
                          obscureText: passwordObscure,
                          controller: mot_passeController,
                          labelText: AppStrings.password,
                          textInputAction: TextInputAction.next,
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
                                mot_passeNotifier.value = !passwordObscure,
                            icon: Icon(
                              passwordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder(
                      valueListenable: confirmPasswordNotifier,
                      builder: (_, confirmPasswordObscure, __) {
                        return AppTextFormField(
                          labelText: AppStrings.confirmPassword,
                          controller: confirmPasswordController,
                          obscureText: confirmPasswordObscure,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            return value!.isEmpty
                                ? AppStrings.pleaseReEnterPassword
                                : AppConstants.passwordRegex.hasMatch(value)
                                    ? mot_passeController.text ==
                                            confirmPasswordController.text
                                        ? null
                                        : AppStrings.passwordNotMatched
                                    : AppStrings.invalidPassword;
                          },
                          suffixIcon: IconButton(
                            onPressed: () =>
                                confirmPasswordNotifier.value =
                                    !confirmPasswordObscure,
                            icon: Icon(
                              confirmPasswordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Rôle',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(
                          value: 'Etablissement',
                          child: Text('Établissement'),
                        ),
                        DropdownMenuItem(
                          value: 'Apprenant1',
                          child: Text('Apprenant scolarisé'),
                        ),
                        DropdownMenuItem(
                          value: 'Apprenant2',
                          child: Text('Apprenant indépendant'),
                        ),
                        DropdownMenuItem(
                          value: 'Admin',
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? 'Veuillez sélectionner un rôle'
                            : null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // Bouton gradient teal arrondi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: submitRegister,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Lien vers connexion
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous avez déjà un compte ? "),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(color: Color(0xFF005F73)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void submitRegister() async {
    final authService = AuthService();

    final result = await authService.inscrire(
      nom_userController.text,
      emailController.text,
      mot_passeController.text,
      selectedRole!,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie. Connectez-vous.'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Échec de l’inscription.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// 🎨 Painter pour la forme teal arrondie
class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25, size.height,
        size.width * 0.5, size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.5,
        size.width, size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
