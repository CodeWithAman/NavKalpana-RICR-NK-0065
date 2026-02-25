import 'package:flutter/material.dart';
import 'package:ledger/FrontEnd/Onboarding/OnboardingCurrency.dart';

class OnboardingName extends StatefulWidget {
  final String uid;
  final String email;
  final String pin;
  const OnboardingName({
    super.key,
    required this.uid,
    required this.email,
    required this.pin,
  });

  @override
  State<OnboardingName> createState() => _OnboardingNameState();
}

class _OnboardingNameState extends State<OnboardingName> {
  final TextEditingController _nameController = TextEditingController();
  String? errorText;

  bool _isValidName(String value) {
    return value.trim().length >= 2;
  }

  void _onNext() {
    final name = _nameController.text.trim();

    if (!_isValidName(name)) {
      setState(() {
        errorText = "Please enter at least 2 characters";
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingCurrency(
          uid: widget.uid,
          email: widget.email,
          pin: widget.pin,
          name: _nameController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.09,
            vertical: size.height * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              /// Title
              const Text(
                "What's your name?",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              const Text(
                "This helps us personalize your experience.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              SizedBox(height: size.height * 0.05),

              /// Name Field
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  if (errorText != null && _isValidName(value)) {
                    setState(() => errorText = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  hintStyle: const TextStyle(color: Colors.black38),
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
