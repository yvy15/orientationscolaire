import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static final navigationKey = GlobalKey<NavigatorState>();

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+",
  );

  static final RegExp passwordRegex = RegExp(r'^.{6,}$');

static final RegExp matriculeRegex = RegExp(r'^.{6,}$');

static final RegExp mot_passe1Regex = RegExp(r'^.{6,}$');

}
