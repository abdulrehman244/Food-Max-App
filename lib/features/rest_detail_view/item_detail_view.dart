// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/check_out/confirm_orderview.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final CategoryItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;
  bool _isInCart = false;
  int _cartQuantity = 0;

  @override
  void initState() {
    super.initState();
    final cartVm = context.read<CartViewModel>();
    final cartItems = cartVm.cartItems;

    // check if item is already in cart
    final existingItem = cartItems.firstWhere(
      (e) => e['name'] == widget.item.name,
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      _isInCart = true;
      _cartQuantity = existingItem['quantity'] ?? 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.read<CartViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              QuantityCounter(
                quantity: _quantity,
                onAdd: () {
                  setState(() {
                    _quantity++;
                  });
                },
                onRemove: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
                border: Border.all(color: Colors.grey, width: 1),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MyButton(
                  title: _isInCart ? "Update Cart" : "Add to Cart",
                  ontap: () {
                   if (_isInCart) {
  final newQuantity = _cartQuantity + _quantity;
  cartVm.updateItemQuantity(widget.item.name, newQuantity);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Cart updated")),
  );
  setState(() {
    _cartQuantity = newQuantity;
    _quantity = 1; // reset temp quantity
  });
} else {
  cartVm.addToCart(
    name: widget.item.name,
    image: widget.item.image,
    price: widget.item.price,
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Item added to cart")),
  );
  setState(() {
    _isInCart = true;
    _cartQuantity = _quantity;
    _quantity = 1;
  });
}

                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => Nav.back(context),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(Icons.close_outlined, color: Colors.black),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.item.image,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(widget.item.name,
                        style: AppText.titleLarge.copyWith(
                          color: Colors.black,
                          fontSize: 25,
                        )),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Rs. ${widget.item.price}",
                        style: AppText.bodyLarge.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                        )),
                  ),
                  SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(widget.item.description),
                  ),
                  SizedBox(height: 10),

                   Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                      ),
                    ),

                  if (_isInCart)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              width: 2,color: Colors.grey.shade300
                            )
                            ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(children: [
                              Text("${_cartQuantity}x",style: AppText.bodyLarge.copyWith(color: Colors.black,fontSize: 16)),
                              SizedBox(width: 15,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(widget.item.name,style: AppText.bodyLarge.copyWith(color: Colors.grey.shade700,fontSize: 14)),
                                  Text("Already in your cart",style: AppText.bodyLarge.copyWith(color: Colors.grey,fontSize: 10))
                                ],
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () => Nav.to(context, ConfirmOrderview()),
                                child: Text("Edit in cart",style: AppText.titleLarge.copyWith(color: Colors.black,fontSize: 14)))
                            ],),
                          ),
                        ),
                      ),
                    )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Border? border;
  final Widget? icon;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.border,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// MINUS
        InkWell(
          onTap: quantity > 1 ? onRemove : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: border),
              child: icon ??
                  Icon(
                    Icons.remove,
                    color: quantity > 1 ? Colors.black : Colors.grey,
                  ),
            ),
          ),
        ),

        /// QUANTITY
        Text(
          quantity.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        /// PLUS
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: border),
              child: const Icon(Icons.add_outlined, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
