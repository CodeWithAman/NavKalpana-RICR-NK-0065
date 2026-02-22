import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledger/FrontEnd/Onboarding/IntoPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    checkAndNavigate();
  }

  Future<void> checkAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUser = prefs.getString('LoggedInUser');

    Timer(const Duration(seconds: 2), () {
      if (loggedInUser == null || loggedInUser.isEmpty) {
        _navigateTo(const IntroPage());
      } else {
        // setState(() {
        //   loggedUser.loggedUserName = loggedInUser;
        // });
        // _navigateTo(HomePage(isNew: false));
      }
    });
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 400),
        child: page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewPadding.bottom != 0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFFFFFFFF),
        ),
      );
    }
    return Scaffold(body: Center(child: Text('Ledger\nSplash Screen')));
  }
}
