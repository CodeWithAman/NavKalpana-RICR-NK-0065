import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecurringExpensePage extends StatefulWidget {
  const AddRecurringExpensePage({super.key});

  @override
  State<AddRecurringExpensePage> createState() =>
      _AddRecurringExpensePageState();
}

class _AddRecurringExpensePageState extends State<AddRecurringExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String cycle = "monthly"; // monthly | yearly
  bool isActive = true;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveRecurringExpense() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recurring_expenses')
        .add({
          "title": title,
          "amount": amount,
          "cycle": cycle, // monthly | yearly
          "isActive": isActive,
          "lastProcessed": null,
          "createdAt": FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Recurring expense added")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Add Recurring Expense",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Title", _titleController),
            const SizedBox(height: 12),
            _input("Amount", _amountController, isNumber: true),
            const SizedBox(height: 24),
            _cycleSelector(),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isActive,
              activeColor: Colors.black,
              onChanged: (v) => setState(() => isActive = v),
              title: const Text(
                "Active",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================

  Widget _input(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= CYCLE SELECTOR =================

  Widget _cycleSelector() {
    return Row(
      children: [
        _chip("Monthly", "monthly"),
        const SizedBox(width: 12),
        _chip("Yearly", "yearly"),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = cycle == value;
    return GestureDetector(
      onTap: () => setState(() => cycle = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ================= SAVE BUTTON =================

  Widget _saveButton() {
    return SizedBox(
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
        onPressed: saveRecurringExpense,
        child: const Text(
          "Save",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
