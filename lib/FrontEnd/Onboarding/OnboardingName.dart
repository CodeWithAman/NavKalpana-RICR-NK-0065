import 'package:flutter/material.dart';
import 'package:ledger/FrontEnd/Onboarding/OnboardingCurrency.dart';

class OnboardingName extends StatefulWidget {
  const OnboardingName({super.key});

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
      MaterialPageRoute(builder: (_) => const OnboardingCurrency()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Text(
                "What's your name?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "This helps us personalize your experience.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  // Live validation per alphabet
                  if (errorText != null && _isValidName(value)) {
                    setState(() => errorText = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onNext, // always enabled
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
