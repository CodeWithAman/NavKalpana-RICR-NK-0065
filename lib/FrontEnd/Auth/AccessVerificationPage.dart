import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledger/FrontEnd/Home/Navigation.dart';
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
          MaterialPageRoute(builder: (_) => const Navigation()),
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
          MaterialPageRoute(builder: (_) => const Navigation()),
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
    final pinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                color: Color(0xFF8B5CF6),
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Verify Access',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Use fingerprint or enter your PIN',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 28),

            Pinput(
              length: 4,
              controller: _pinController,
              focusNode: _focusNode,
              obscureText: true,
              obscuringCharacter: '●',
              autofocus: false,
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                ),
              ),
              onCompleted: (_) => _verifyPin(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: isPinComplete && !_loading ? _verifyPin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                        ),
                      ),
              ),
            ),

            const Spacer(),

            TextButton.icon(
              onPressed: _tryBiometricAuth,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Use Fingerprint'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
