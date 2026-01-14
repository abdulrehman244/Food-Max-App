import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/features/theme/theme_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool pushNotification = true;
  bool emailOffers = true;

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Text(
          "Settings",
          style: AppText.bodyLarge.copyWith(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ---------- LANGUAGE ----------
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Language",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "English",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ---------- THEME ----------
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Theme",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        themeVm.isPink ? "Pink Theme" : "Orange Theme",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  /// 🔥 SWITCH BUTTON
                  Switch(
                    value: themeVm.isPink,
                    onChanged: (value) {
                      themeVm.toggleTheme(value);
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ---------- PUSH NOTIFICATION ----------
            _card(
              child: _checkboxTile(
                title: "Receive push notifications",
                value: pushNotification,
                onChanged: (v) {
                  setState(() => pushNotification = v!);
                },
              ),
            ),

            const SizedBox(height: 12),

            /// ---------- EMAIL OFFERS ----------
            _card(
              child: _checkboxTile(
                title: "Receive offers by email",
                value: emailOffers,
                onChanged: (v) {
                  setState(() => emailOffers = v!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- CARD ----------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// ---------- CHECKBOX ----------
  Widget _checkboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
