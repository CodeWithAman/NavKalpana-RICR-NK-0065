import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SetBudgePage extends StatefulWidget {
  const SetBudgePage({super.key});

  @override
  State<SetBudgePage> createState() => _SetBudgePageState();
}

class _SetBudgePageState extends State<SetBudgePage> {
  String amount = "";

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get currentMonth => DateFormat('yyyy-MM').format(DateTime.now());

  void onKeyTap(String value) {
    setState(() {
      if (value == "⌫") {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += value;
      }
    });
  }

  Future<void> saveBudget() async {
    final user = _auth.currentUser;
    if (user == null || amount.isEmpty) return;

    final budget = double.tryParse(amount);
    if (budget == null || budget <= 0) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(currentMonth)
        .set({
          "month": currentMonth,
          "totalBudget": budget,
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Monthly budget saved")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 16),
            _budgetCard(),
            const SizedBox(height: 32),
            _amountDisplay(),
            const SizedBox(height: 24),
            _numberPad(),
            const Spacer(),
            _saveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------------- UI SECTIONS ----------------

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          BackButton(color: Colors.black),
          Spacer(),
          Text(
            "Set Budget",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _budgetCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: const [
          CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Monthly Budget",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Set your spending limit",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountDisplay() {
    return Text(
      amount.isEmpty ? "₹0.00" : "₹$amount",
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    );
  }

  Widget _numberPad() {
    final keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "⌫"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onKeyTap(keys[index]),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                keys[index],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: saveBudget,
          child: const Text(
            "Save Budget",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
