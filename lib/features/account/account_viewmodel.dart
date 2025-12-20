// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/auth/login/login_view.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class AccountViewmodel extends ChangeNotifier {
  Future<void> logout(BuildContext context) async {
    await context.read<HomeViewModel>().logout();
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
cartVM.clearCart();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginView()),
      (route) => false,
    );
  }
}
