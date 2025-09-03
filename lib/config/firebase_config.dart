// Wrapper around the generated firebase_options.dart from `flutterfire configure`
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart' as generated;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      generated.DefaultFirebaseOptions.currentPlatform;
}
