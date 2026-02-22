import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ledger/FrontEnd/Home/HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _loading = false;

  // ---------------- VALIDATOR ----------------
  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email);
  }

  // ---------------- SHARED PREF SAVE ----------------
  Future<void> _saveAuthData({
    required String uid,
    required String pinHash,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('pinHash', pinHash);
  }

  // ---------------- FETCH PIN HASH ----------------
  Future<String?> _fetchPinHash(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return doc.data()?['pin'] as String?;
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<void> loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidEmail(email)) {
      _showMessage("Invalid email address");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Password cannot be empty");
      return;
    }

    try {
      setState(() => _loading = true);

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        _showMessage("Login failed");
        return;
      }

      // Email verification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        await _auth.signOut();
        _showMessage("Please verify your email before login");
        return;
      }

      final uid = user.uid;

      // Fetch PIN hash from Firestore
      final pinHash = await _fetchPinHash(uid);
      if (pinHash == null) {
        _showMessage("PIN not set. Please set your PIN.");
        return;
      }

      // Save to SharedPreferences
      await _saveAuthData(uid: uid, pinHash: pinHash);

      _showMessage("Login successful");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> loginWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        _showMessage("Google login failed");
        return;
      }

      final uid = user.uid;

      // Fetch PIN hash
      final pinHash = await _fetchPinHash(uid);
      if (pinHash == null) {
        _showMessage("PIN not set. Please set your PIN.");
        return;
      }

      // Save to SharedPreferences
      await _saveAuthData(uid: uid, pinHash: pinHash);

      _showMessage("Google login successful");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (_) {
      _showMessage("Google login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- FORGOT PASSWORD ----------------
  Future<void> resetPassword() async {
    final email = _emailController.text.trim();

    if (!isValidEmail(email)) {
      _showMessage("Enter a valid email to reset password");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage("Password reset email sent");
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Failed to send reset email");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: resetPassword,
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : loginWithEmail,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : loginWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Continue with Google"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
