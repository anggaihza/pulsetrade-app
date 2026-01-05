// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PulseTrade';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get login => 'Ingresar';

  @override
  String get register => 'Registrar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get submit => 'Enviar';

  @override
  String get surveyTitle => 'Encuesta';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String welcomeMessage(Object email) {
    return 'Bienvenido de nuevo, $email';
  }
}
