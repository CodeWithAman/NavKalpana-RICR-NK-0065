// ProfileScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snap) {
          final d     = snap.data?.data() as Map<String, dynamic>? ?? {};
          final name  = d['name'] ?? '';
          final email = d['email'] ?? user.email ?? '';
          final pic   = d['profilePicture'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Avatar ───────────────────────────
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.surface2,
                backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                child: pic.isEmpty
                    ? const Icon(Icons.person, color: AppTheme.textSec, size: 40)
                    : null,
              ),
              const SizedBox(height: 14),
              Text(_capitalize(name),
                  style: const TextStyle(color: AppTheme.textPri, fontSize: 20, fontWeight: FontWeight.w700)),
              Text(email, style: const TextStyle(color: AppTheme.textSec)),
              const SizedBox(height: 32),

              // ── Stats row ────────────────────────
              _StatsRow(uid: user.uid),
              const SizedBox(height: 24),

              // ── Settings tiles ───────────────────
              _tile(icon: Icons.person_outline, label: 'Edit Profile'),
              _tile(icon: Icons.notifications_outlined, label: 'Notifications'),
              _tile(icon: Icons.language, label: 'Currency / Language'),
              _tile(icon: Icons.lock_outline, label: 'Privacy & Security'),
              _tile(icon: Icons.help_outline, label: 'Help & Support'),
              const SizedBox(height: 8),
              _tile(icon: Icons.logout, label: 'Sign Out', danger: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/SplashScreen', (_) => false);
                    }
                  }),
            ]),
          );
        },
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    bool danger = false,
    VoidCallback? onTap,
  }) {
    final color = danger ? AppTheme.danger : AppTheme.textPri;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: AppTheme.textDim, size: 14),
        ]),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _StatsRow extends StatelessWidget {
  final String uid;
  const _StatsRow({required this.uid});

  @override
  Widget build(BuildContext context) {
    final monthId = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid)
          .collection('analytics').doc(monthId).snapshots(),
      builder: (context, snap) {
        final spent = snap.hasData && snap.data!.exists
            ? ((snap.data!.data() as Map)['totalSpent'] ?? 0).toDouble() : 0.0;
        return Row(children: [
          Expanded(child: _stat('This Month', '₹${spent.toStringAsFixed(0)}')),
          Container(width: 1, height: 40, color: AppTheme.border),
          Expanded(child: _stat('Goals', '—')),
          Container(width: 1, height: 40, color: AppTheme.border),
          Expanded(child: _stat('Days Tracked', '${DateTime.now().day}')),
        ]);
      },
    );
  }

  Widget _stat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 18)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
  ]);
}
