// =====================================================
// SettingsScreen
// =====================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _budgetAlerts  = true;
  bool _aiInsights    = true;
  String _currency    = 'INR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Notifications'),
          _switchTile('Push Notifications', _notifications, (v) => setState(() => _notifications = v)),
          _switchTile('Budget Alerts', _budgetAlerts, (v) => setState(() => _budgetAlerts = v)),
          _switchTile('AI Insights', _aiInsights, (v) => setState(() => _aiInsights = v)),

          const SizedBox(height: 20),
          _sectionTitle('Preferences'),
          _dropdownTile('Currency', _currency, ['INR', 'USD', 'EUR', 'GBP', 'JPY'],
              (v) => setState(() => _currency = v!)),
          _actionTile('Export Data', Icons.download, AppTheme.accent),
          _actionTile('Clear Cache', Icons.cleaning_services, AppTheme.warning),

          const SizedBox(height: 20),
          _sectionTitle('About'),
          _infoTile('Version', '1.0.0'),
          _infoTile('Build', 'Release'),
          _actionTile('Privacy Policy', Icons.privacy_tip, AppTheme.textSec),
          _actionTile('Terms of Service', Icons.description, AppTheme.textSec),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(color: AppTheme.textSec, fontSize: 12,
        fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  );

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
        const Spacer(),
        Switch(value: value, onChanged: onChanged),
      ]),
    );

  Widget _dropdownTile<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
        const Spacer(),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox(),
          dropdownColor: AppTheme.surface2,
          style: const TextStyle(color: AppTheme.textSec),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.toString()))).toList(),
          onChanged: onChanged,
        ),
      ]),
    );

  Widget _actionTile(String label, IconData icon, Color iconColor) =>
    GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: AppTheme.textDim, size: 14),
        ]),
      ),
    );

  Widget _infoTile(String label, String value) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppTheme.textSec)),
      ]),
    );
}
