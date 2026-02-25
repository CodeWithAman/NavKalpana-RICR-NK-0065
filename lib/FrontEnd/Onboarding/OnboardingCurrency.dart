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

  // 11 Famous Currencies
  final List<Map<String, String>> currencyList = [
    {"symbol": "US\$", "code": "USD", "name": "US Dollar"},
    {"symbol": "€", "code": "EUR", "name": "Euro"},
    {"symbol": "₹", "code": "INR", "name": "Indian Rupee"},
    {"symbol": "£", "code": "GBP", "name": "British Pound"},
    {"symbol": "¥", "code": "JPY", "name": "Japanese Yen"},
    {"symbol": "A\$", "code": "AUD", "name": "Australian Dollar"},
    {"symbol": "CA\$", "code": "CAD", "name": "Canadian Dollar"},
    {"symbol": "CHF", "code": "CHF", "name": "Swiss Franc"},
    {"symbol": "元", "code": "CNY", "name": "Chinese Yuan"},
    {"symbol": "S\$", "code": "SGD", "name": "Singapore Dollar"},
    {"symbol": "AED", "code": "AED", "name": "UAE Dirham"},
  ];

  String selectedCurrency = "USD";
  bool _loading = false;

  Future<void> _onNext() async {
    setState(() => _loading = true);

    try {
      await createUser(
        uid: widget.uid,
        email: widget.email,
        pinHash: widget.pin,
        name: widget.name,
        currency: selectedCurrency,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', widget.uid);
      await prefs.setString('pinHash', widget.pin);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
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
    final filteredList = currencyList.where((item) {
      final q = _searchController.text.toLowerCase();
      return item["code"]!.toLowerCase().contains(q) ||
          item["name"]!.toLowerCase().contains(q) ||
          item["symbol"]!.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Select Currency",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        hintText: "Search currency...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Currency Selector Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                selectedCurrency = item["code"]!;
                              });
                            },
                            child: RadioListTile<String>(
                              value: item["code"]!,
                              groupValue: selectedCurrency,
                              activeColor: Colors.black,
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  Text(
                                    item["symbol"]!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "${item["code"]} - ${item["name"]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrency = value!;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // NEXT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          if (_loading) Container(color: Colors.black.withOpacity(0.2)),
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
