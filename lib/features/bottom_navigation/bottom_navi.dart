        import 'package:badges/badges.dart' as badges;
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
        import 'package:provider/provider.dart';
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
import 'package:food_delivery_app/features/account/account_view.dart';
import 'package:food_delivery_app/features/cart/cart_view.dart';
import 'package:food_delivery_app/features/grocery/grocery_view.dart';
import 'package:food_delivery_app/features/home/home_view.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/search/search_view.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavi extends StatefulWidget {
  const BottomNavi({super.key});

  @override
  State<BottomNavi> createState() => BottomNaviState();
}

class BottomNaviState extends State<BottomNavi> {
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  // Screens list
  final screens = [
    HomeView(),
    const GroceryView(),
    SearchView(),
    const CartView(),
    const AccountView(),
  ];
  
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // 🔥 USER LOAD
    Provider.of<HomeViewModel>(context, listen: false)
        .loadCurrentUser();

    // 🔥 CART LOAD (THIS WAS MISSING)
    Provider.of<CartViewModel>(context, listen: false)
        .loadCart();
  });
}



  @override
  Widget build(BuildContext context) {

    // ignore: deprecated_member_use
    return WillPopScope(
       onWillPop: () async {
      if (currentIndex.value != 0) {
        // Agar Home tab pe nahi → Home tab pe jao
        currentIndex.value = 0;
        return false; // back press handled
      } else {
        // Home tab pe hai → app close ho jaaye
        return true; // default behavior
      }
    },
      child: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: currentIndex,
          builder: (context, value, child) {
            return screens[value];
          },
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: currentIndex,
          builder: (context, value, child) {
            return CurvedNavigationBar(
              color: AppColors.appColor,
                backgroundColor: Colors.white,
                animationDuration: const Duration(milliseconds: 300),
              index: value,
              onTap: (index) {
                currentIndex.value = index;
                if (currentIndex.value == 0) {
                final model = Provider.of<HomeViewModel>(context, listen: false);
                model.isSearchBarSticky = false;  // hide sticky bar
                // ignore: invalid_use_of_protected_member
                model.notifyListeners();           // UI refresh
              }
                  }, items: [
                     navItem(Icons.home, "Home", 0),
                navItem(Icons.local_grocery_store, "Grocery", 1),
                navItem(Icons.search, "Search", 2),
                navItem(Icons.shopping_bag_outlined, "Cart", 3),
                navItem(Icons.person, "Account", 4),
                  ],);
              },
      
        ),
      ),
    );
  }



Widget navItem(IconData icon, String label, int index) {
  bool isSelected = currentIndex.value == index;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      // 🔥 CART ICON WITH BADGE (index == 3)
      if (index == 3)
        Consumer<CartViewModel>(
          builder: (context, cartVm, child) {
            return badges.Badge(
              showBadge: cartVm.cartItems.isNotEmpty,

              badgeContent: Text(
                cartVm.cartItems.length > 99
                    ? "99+"
                    : cartVm.cartItems.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),

              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.redAccent,
                padding: const EdgeInsets.all(6),
                elevation: 6,
              ),

              badgeAnimation: badges.BadgeAnimation.scale(
                animationDuration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
              ),

              position: badges.BadgePosition.topEnd(
                top: -8,
                end: -8,
              ),

              // ✅ ICON MUST BE CHILD
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            );
          },
        )
      else
        // 🔹 Normal icons (Home, Grocery, Search, Account)
        Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),

      if (!isSelected)
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
    ],
  );
}


}
