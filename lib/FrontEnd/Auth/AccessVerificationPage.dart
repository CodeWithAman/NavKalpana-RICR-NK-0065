import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledger/screens/main_navigation.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AccessVerificationPage extends StatefulWidget {
  const AccessVerificationPage({super.key});

  @override
  State<AccessVerificationPage> createState() => _AccessVerificationPageState();
}

class _AccessVerificationPageState extends State<AccessVerificationPage>
    with WidgetsBindingObserver {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _loading = false;
  bool _isBiometricRunning = false;
  bool _biometricAttemptedOnce = false;
  String? _error;

  bool get isPinComplete => _pinController.text.length == 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Trigger biometric ONCE after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_biometricAttemptedOnce) {
        _biometricAttemptedOnce = true;
        _tryBiometricAuth();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localAuth.stopAuthentication();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Hash PIN (must match onboarding)
  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin.trim())).toString();
  }

  /// 🔑 BIOMETRIC AUTH — ANDROID SAFE
  Future<void> _tryBiometricAuth() async {
    if (_isBiometricRunning) return;

    _isBiometricRunning = true;

    try {
      /// MUST cancel any previous session
      await _localAuth.stopAuthentication();

      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) return;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to continue',
        biometricOnly: true,
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } on PlatformException catch (e) {
      /// IGNORE authInProgress (Android bug/behavior)
      if (e.code != 'authInProgress') {
        debugPrint('Biometric error: ${e.code}');
      }
    } catch (e) {
      debugPrint('Biometric exception: $e');
    } finally {
      _isBiometricRunning = false;
    }
  }

  /// VERIFY PIN
  Future<void> _verifyPin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('pinHash');

      if (storedHash == null) {
        throw Exception('PIN not found');
      }

      final enteredHash = _hashPin(_pinController.text);

      if (enteredHash == storedHash) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        setState(() {
          _error = 'Incorrect PIN';
          _pinController.clear();
        });
      }
    } catch (_) {
      setState(() => _error = 'Something went wrong');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Backend based verification - Balze plan required in firebase

  //   Future<void> _verifyPin() async {
  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {
  //     final success =
  //         await verifyPinWithBackend(_pinController.text.trim());

  //     if (success) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const Navigation()),
  //       );
  //     } else {
  //       setState(() {
  //         _error = 'Incorrect PIN';
  //         _pinController.clear();
  //       });
  //     }
  //   } catch (e) {
  //     setState(() => _error = 'Verification failed');
  //   } finally {
  //     setState(() => _loading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 58,
      height: 58,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1.4),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
            stops: [0.0, 0.65],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),

              /// 🛡 Shield Icon
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 22),

              /// 🔐 Title
              const Text(
                'Verify Your Secure PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              /// 📄 Subtitle
              const Text(
                'Enter your 4 digit PIN to access\nyour wallet securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔢 PIN INPUT FIELD
              Pinput(
                length: 4,
                controller: _pinController,
                focusNode: _focusNode,
                obscureText: true,
                obscuringCharacter: '●',
                autofocus: true,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
                onCompleted: (_) => _verifyPin(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 38),

              /// 🔘 Verify Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ElevatedButton(
                  onPressed: isPinComplete && !_loading ? _verifyPin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.black.withOpacity(0.35),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: TextButton.icon(
                  onPressed: _tryBiometricAuth,
                  icon: const Icon(Icons.fingerprint, color: Colors.black),
                  label: const Text(
                    'Use Fingerprint',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
