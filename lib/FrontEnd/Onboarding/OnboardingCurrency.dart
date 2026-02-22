import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ledger/FrontEnd/Onboarding/WelcomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCurrency extends StatefulWidget {
  final String uid;
  final String email;
  final String pin;
  final String name;

  const OnboardingCurrency({
    super.key,
    required this.uid,
    required this.email,
    required this.pin,
    required this.name,
  });

  @override
  State<OnboardingCurrency> createState() => _OnboardingCurrencyState();
}

class _OnboardingCurrencyState extends State<OnboardingCurrency> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCurrency = "INR";
  final List<String> currencies = ["INR", "USD"];

  bool _loading = false;

  /// 🔥 NEXT ACTION
  Future<void> _onNext() async {
    setState(() => _loading = true);

    try {
      /// Create user in Firestore
      await createUser(
        uid: widget.uid,
        email: widget.email,
        pinHash: widget.pin,
        name: widget.name,
        currency: selectedCurrency,
      );

      /// Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', widget.email);
      await prefs.setString('pinHash', widget.pin);

      ///  Navigate
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomePage(), // next page
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAIN UI
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB99BFF), Color.fromARGB(255, 226, 226, 226)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  const Text(
                    "Select Currency",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search Currency",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: currencies
                                  .where(
                                    (c) => c.toLowerCase().contains(
                                      _searchController.text.toLowerCase(),
                                    ),
                                  )
                                  .map(
                                    (currency) => RadioListTile<String>(
                                      value: currency,
                                      groupValue: selectedCurrency,
                                      activeColor: const Color(0xFF7B5CFA),
                                      title: Text(currency),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCurrency = value!;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B5CFA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                                "Next",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// 🔒 FULLSCREEN LOADER (OPTIONAL)
          if (_loading) Container(color: Colors.black.withOpacity(0.15)),
        ],
      ),
    );
  }
}

Future<void> createUser({
  required String uid,
  required String email,
  required String pinHash,
  required String name,
  required String currency,
}) async {
  final usersRef = FirebaseFirestore.instance.collection('users');

  await usersRef.doc(uid).set({
    'email': email.toLowerCase(),
    'pin': pinHash,
    'name': name.trim(),
    'currency': currency,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
