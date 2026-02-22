import 'package:flutter/material.dart';
// import 'package:ledger/FrontEnd/Onboarding/OnboardingFinish.dart';

class OnboardingCurrency extends StatefulWidget {
  const OnboardingCurrency({super.key});

  @override
  State<OnboardingCurrency> createState() => _OnboardingCurrencyState();
}

class _OnboardingCurrencyState extends State<OnboardingCurrency> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCurrency = "₹ - INR";
  final List<String> currencies = ["₹ - INR", "\$ - USD"];

  void _onNext() {
    // TODO: Save currency (Firestore / SharedPreferences)
    // print("Selected currency: $selectedCurrency");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Placeholder(), // replace with next page
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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

              /// Title
              const Text(
                "Select Currency",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              /// White Card
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
                      /// Search
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

                      /// Currency List
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: currencies
                              .where(
                                (c) => c.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ),
                              )
                              .map((currency) {
                                return RadioListTile<String>(
                                  value: currency,
                                  groupValue: selectedCurrency,
                                  activeColor: const Color(0xFF7B5CFA),
                                  title: Text(
                                    currency,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCurrency = value!;
                                    });
                                  },
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔥 NEXT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5CFA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Next", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
