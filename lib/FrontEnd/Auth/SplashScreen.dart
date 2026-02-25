import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ledger/FrontEnd/Auth/AccessVerificationPage.dart';
import 'package:ledger/FrontEnd/Onboarding/IntoPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _lineController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _subtitleAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );

    _initAnimations();
    _checkAndNavigate();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    _lineAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _lineController, curve: Curves.easeOut));

    _subtitleAnimation = Tween<double>(begin: 0, end: 0.8).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _lineController.forward();
    });
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('uid');

    if (user != null && savedEmail != null && savedEmail.isNotEmpty) {
      _navigateTo(const AccessVerificationPage());
    } else {
      _navigateTo(const IntroPage());
    }
  }

  void _navigateTo(Widget page) {
    if (!mounted) return;

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
  void dispose() {
    _mainController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.16;
    final lineWidth = size.width * 0.25;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color.fromARGB(255, 12, 12, 12),
              Color.fromARGB(255, 10, 8, 19),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return Container(
                      width: lineWidth * _lineAnimation.value,
                      height: 2,
                      color: const Color.fromARGB(255, 7, 7, 7),
                    );
                  },
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'Ledger',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 245, 247, 245),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return Container(
                      width: lineWidth * _lineAnimation.value,
                      height: 2,
                      color: const Color.fromRGBO(103, 102, 102, 1),
                    );
                  },
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _subtitleAnimation,
                  child: Text(
                    'Expence Tracker',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      letterSpacing: 3,
                      color: const Color.fromARGB(255, 252, 251, 254),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
