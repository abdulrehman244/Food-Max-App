import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/account/account_viewmodel.dart';
import 'package:food_delivery_app/features/favorite/favorite_itemview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/my_location/mylocation_view.dart';
import 'package:food_delivery_app/features/order/order_view.dart';
import 'package:food_delivery_app/features/profile/profile_view.dart';
import 'package:food_delivery_app/features/settings/setting_view.dart';
import 'package:provider/provider.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeViewModel, AccountViewmodel>(
      builder: (context, homeVm, accountVm, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "Account",
              style: AppText.bodyLarge.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () {
                    Nav.to(context, const SettingsView());
                  },
                  icon: const Icon(Icons.settings, color: Colors.black),
                ),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeVm.currentUser?.name ?? "name not found",
                        style: AppText.titleLarge.copyWith(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Nav.to(context, ProfileView());
                        },
                        child: Text(
                          "View profile",
                          style: AppText.bodyMedium.copyWith(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // PURPLE CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFF5B1E8C),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Save on your future orders\nwith Food Max",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Learn more",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // QUICK BOXES
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickBox("Orders", Icons.receipt_long, () { 
                        Nav.to(context, OrderView());
                      }, context),
                      _quickBox("Favourites", Icons.favorite_border, () {
                        Nav.to(context, FavoriteItemview());
                      }, context),
                      _quickBox("Addresses", Icons.location_on_outlined, () {
                        Nav.to(context, MylocationView());
                      }, context),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "General",
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 25,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _settingTile("Help center", Icons.star),
                        _settingTile("FAQ", Icons.emoji_events_outlined),
                        _settingTile(
                          "Terms & policies",
                          Icons.confirmation_number_outlined,
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      contentPadding: const EdgeInsets.all(20),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.9,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Logging out?",
                                              style: AppText.titleLarge
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Thanks for stopping by. See you again soon!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actionsPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        20,
                                      ),
                                      actions: [
                                        Row(
                                          children: [
                                            // Cancel Button
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Nav.back(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // Logout Button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // logout logic
                                                  accountVm.logout(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                       Theme.of(context).primaryColor,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Log out",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },

                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(width: 1, color: Colors.black),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                "Log out",
                                style: AppText.bodyMedium.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickBox(
    String title,
    IconData icon,
    VoidCallback onpressed,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade500),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(String title, IconData icon) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(
            title,
            style: AppText.bodyMedium.copyWith(color: Colors.black),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        ),
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }
}
