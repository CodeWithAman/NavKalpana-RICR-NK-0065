import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ledger/FrontEnd/Auth/AccessSetupPage.dart';
import 'package:ledger/FrontEnd/Auth/LoginPage.dart';
import 'package:page_transition/page_transition.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _loading = false;
  bool _obscurePassword = true;
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

  void startEmailVerificationCheck(String uid) {
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
          MaterialPageRoute(
            builder: (_) =>
                AccessSetupPage(email: _emailController.text.trim(), uid: uid),
          ),
        );
      }
    });
  }

  // ---------------- EMAIL SIGNUP ----------------

  Future<void> signupWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

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

      startEmailVerificationCheck(userCred.user!.uid);
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

      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception('User is null after Google sign-in');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AccessSetupPage(uid: user.uid, email: user.email ?? ''),
        ),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.09,
            vertical: size.height * 0.08,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.04),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: "Manage your expenses with ",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "\nLedger",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                const Text(
                  "create your account with ledger",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                SizedBox(height: size.height * 0.07),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter email",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                ElevatedButton(
                  onPressed: _loading ? null : signupWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Sign Up"),
                ),

                SizedBox(height: size.height * 0.02),

                const Center(
                  child: Text(
                    "already have an account?",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 6),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Or", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                SizedBox(height: size.height * 0.03),

                OutlinedButton(
                  onPressed: _loading ? null : signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://www.google.com/favicon.ico",
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Login with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.07),

                const Center(
                  child: Text(
                    "by creating account.you agree to our Terms & Conditions and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
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
