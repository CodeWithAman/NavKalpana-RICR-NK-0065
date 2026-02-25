import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:ledger/FrontEnd/Onboarding/OnboardingName.dart';
import 'package:pinput/pinput.dart';

class AccessSetupPage extends StatefulWidget {
  final String uid;
  final String email;

  const AccessSetupPage({
    super.key,
    required this.uid,
    required this.email,
  });

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

        /// 🎨 UPDATED BLACK + WHITE GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.white,
            ],
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
                'Set Your Secure PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              /// 📄 Subtitle
              const Text(
                'Add a 4 digit PIN to protect your wallet\nand quick access.',
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
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.black),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 38),

              /// 🔘 Set Pin Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
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
                    backgroundColor: Colors.black,
                    disabledBackgroundColor:
                        Colors.black.withOpacity(0.35),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Set Pin',
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
                child: Text(
                  'Use keyboard to enter PIN',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
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