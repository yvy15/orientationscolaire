class AppRegex {
  const AppRegex._();

  static final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+");
 static final RegExp passwordRegex = RegExp(r'^.{6,}$');

 static final RegExp matriculeRegex = RegExp(r'^[A-Z]{2}\d{4,6}$');

static final RegExp mot_passe1Regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');

}
