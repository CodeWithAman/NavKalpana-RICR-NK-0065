import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ledger/FrontEnd/Home/HomePage.dart';
import 'package:ledger/FrontEnd/Auth/SplashScreen.dart';
import 'package:ledger/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.73, 825.45),
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          useMaterial3: true,
          textTheme: GoogleFonts.manropeTextTheme(),
        ),
        initialRoute: "/SplashScreen",
        routes: {
          "/SplashScreen": (context) => const Splashscreen(),
          "/HomePage": (context) => const HomePage(),
        },
      ),
    );
  }
}
