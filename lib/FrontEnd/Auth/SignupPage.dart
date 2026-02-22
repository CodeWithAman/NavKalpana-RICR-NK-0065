import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ledger/FrontEnd/Auth/LoginPage.dart';
import 'package:ledger/FrontEnd/Onboarding/OnboardingName.dart';
import 'package:page_transition/page_transition.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _loading = false;
  Timer? _emailCheckTimer;

  // ---------------- VALIDATORS ----------------

  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email);
  }

  String? validateStrongPassword(String password) {
    if (password.length < 8) return "Minimum 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(password)) return "Add uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(password)) return "Add lowercase letter";
    if (!RegExp(r'[0-9]').hasMatch(password)) return "Add number";
    if (!RegExp(r'[!@#$%^&*(),.?\":{}|<>]').hasMatch(password)) {
      return "Add special character";
    }
    return null;
  }

  // ---------------- EMAIL VERIFICATION CHECK ----------------

  void startEmailVerificationCheck() {
    _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        timer.cancel();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingName()),
        );
      }
    });
  }

  // ---------------- EMAIL SIGNUP ----------------

  Future<void> signupWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidEmail(email)) {
      show("Invalid email");
      return;
    }

    final error = validateStrongPassword(password);
    if (error != null) {
      show(error);
      return;
    }

    try {
      setState(() => _loading = true);

      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user?.sendEmailVerification();

      show("Verification email sent. Please verify.");

      // start auto-check
      startEmailVerificationCheck();
    } on FirebaseAuthException catch (e) {
      show(e.message ?? "Signup failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- GOOGLE SIGN-IN ----------------

  Future<void> signInWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingName()),
      );
    } catch (e) {
      show("Google Sign-In failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  void show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : signupWithEmail,
              child: const Text("Sign Up with Email"),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: _loading ? null : signInWithGoogle,
              child: const Text("Continue with Google"),
            ),

            SizedBox(height: 26.h),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftJoined,
                    childCurrent: widget,
                    duration: const Duration(milliseconds: 60),
                    reverseDuration: const Duration(milliseconds: 60),
                    child: const LoginPage(),
                  ),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
