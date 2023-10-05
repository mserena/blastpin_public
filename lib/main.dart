import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:blastpin/services/routes/route_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// TODO: Generic todo's, hacks and tricks
// Flutter modification for local storage persistance on debug https://quango2304.medium.com/keep-flutter-web-storage-after-close-and-run-again-when-developing-7cb2118cbbb3

void main() async{
  //debugPrintGestureArenaDiagnostics = true;

  //Get trigger Url
  gInitialAppUri = Uri.base;
  
  //Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "secret",
      appId: "secret",
      messagingSenderId: "secret",
      projectId: "secret",
      storageBucket: defGeneralBucket,
    )
  );

  runApp(const MaterialApp(home: BlastPin()));
}

class BlastPin extends StatefulWidget {
  const BlastPin({super.key});

  @override
  State<BlastPin> createState() => _BlastPin();
}

class _BlastPin extends State<BlastPin> {
  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      navigatorKey: gNavigatorStateKey,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (initialRoute) {
        debugPrint('onGenerateInitialRoutes: $initialRoute');
        return [RouteManager().generateRoute(RouteSettings(name:initialRoute))];
      },
      onGenerateRoute: RouteManager().generateRoute,
      theme: blastpinTheme(context),
    );
    return app;
  }
}