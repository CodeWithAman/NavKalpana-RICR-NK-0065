import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:ledger/FrontEnd/Onboarding/OnboardingName.dart';
import 'package:pinput/pinput.dart';

class AccessSetupPage extends StatefulWidget {
  final String uid;
  final String email;
  const AccessSetupPage({super.key, required this.uid, required this.email});

  @override
  State<AccessSetupPage> createState() => _AccessSetupPageState();
}

class _AccessSetupPageState extends State<AccessSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get isPinComplete => _pinController.text.length == 4;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
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
                Icons.shield_rounded,
                color: Color(0xFF8B5CF6),
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Set Your Secure PIN',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Add a 4 digit PIN to protect your wallet\nand quick access.',
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
              autofocus: true,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onCompleted: (pin) {
                debugPrint('PIN entered: $pin');
              },
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: isPinComplete
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OnboardingName(
                              uid: widget.uid,
                              email: widget.email,
                              pin: sha256
                                  .convert(utf8.encode(_pinController.text))
                                  .toString(),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  disabledBackgroundColor: const Color(
                    0xFF8B5CF6,
                  ).withOpacity(0.4),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Set Pin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Use keyboard to enter PIN',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
