import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/features/settings/theme_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool pushNotification = true;
  bool emailOffers = true;
  bool floatingIcon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Text(
          "Settings",
          style: AppText.bodyLarge.copyWith(color: Colors.black, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Language Card
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Language",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "English",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      //  const Text(
                      //   "Theme",
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.grey,
                      //   ),
                      // ),

                      // Consumer<SettingViewmodel>(
                      //   builder: (context, vm, child) =>
                      //    Switch(
                      //         value: vm.isSwitched,
                      //         onChanged: (value) {
                      //           vm.toggle(value);
                      //         },
                      //         activeColor: Colors.pink, // ON color
                      //         inactiveThumbColor: Colors.grey, // OFF thumb color
                      //         inactiveTrackColor:
                      //             Colors.grey.shade300, // OFF track color
                      //       ),
                      // )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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

                     Consumer<ThemeViewModel>(
  builder: (context, vm, child) => Switch(
    value: vm.isDarkMode,
    onChanged: (value) {
      vm.toggleTheme(value);
    },
    activeColor: vm.appColor,
    inactiveThumbColor: Colors.grey,
    inactiveTrackColor: Colors.grey.shade300,
  ),
),

                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Push Notification
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

            // Email Offers
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

  // ---------- Reusable Card ----------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  // ---------- Checkbox Tile ----------
  Widget _checkboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: Colors.black),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
