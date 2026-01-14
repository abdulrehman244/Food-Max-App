// ignore_for_file: use_build_context_synchronously
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final CategoryItemModel item;
  final List<CategoryItemModel> allItems;
  final String restaurantName;
  final String restaurantImage;
  final Map<String, dynamic> restaurantLocation;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.allItems,
    required this.restaurantName,
    required this.restaurantImage,
    required this.restaurantLocation,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final hive = HiveService();
  final TextEditingController _instructionController = TextEditingController();
  int quantity = 1;

  // Quantity will be managed in CartViewModel
  late List<CategoryItemModel> frequentItems;
  bool showMore = false;
  final Map<String, bool> selectedFrequentItems = {};

  @override
  void initState() {
    super.initState();
    // Shuffle only once
    frequentItems =
        widget.allItems.where((e) => e.id != widget.item.id).toList()
          ..shuffle(Random());
    if (frequentItems.length > 6)
      frequentItems = frequentItems.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final vm = context.watch<CartViewModel>();

    final visibleItems = showMore
        ? frequentItems
        : frequentItems.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      /// ================= BOTTOM BAR =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<CartViewModel>(
            builder: (context, cartVm, _) {
              return Row(
                children: [
                  QuantityCounter(
                    quantity: quantity,
                    onAdd: () {
                      HapticFeedback.vibrate();

                      setState(() {
                        quantity++;
                      });
                    },
                    onRemove: () {
                      HapticFeedback.vibrate();

                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),

                  SizedBox(width: 10),
                  Expanded(
                    child: MyButton(
                      title: "Add to Cart",
                      ontap: () async {
                        // // Add main item

                        await cartVm.addToCart(
                          restaurantId: widget.item.restaurantId,
                          restaurantName: widget.restaurantName,
                          restaurantImage: widget.restaurantImage,
                          restaurantLocation: widget.restaurantLocation,
                          item: {
                            "itemId": widget.item.id,
                            "name": widget.item.name,
                            "image": widget.item.image,
                            "price": widget.item.price,
                            "qty": quantity, // ✅ local quantity
                            "instructions": _instructionController.text,
                          },
                        );

                        // 2️⃣ Add frequently bought items (if selected) with quantity = 1
                        for (var item in frequentItems) {
                          if (selectedFrequentItems[item.id] == true) {
                            await cartVm.addToCart(
                              restaurantId: item.restaurantId,
                              restaurantName: widget.restaurantName,
                              restaurantImage: widget.restaurantImage,
                              restaurantLocation: widget.restaurantLocation,
                              item: {
                                "itemId": item.id,
                                "name": item.name,
                                "image": item.image,
                                "price": item.price,
                                "qty": 1, // always 1
                                "instructions": "",
                              },
                            );
                          }
                        }

                        // Reset after adding
                        setState(() {
                          quantity = 1;
                          _instructionController.clear();
                          selectedFrequentItems.clear(); // uncheck all
                        });

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      /// ================= APP BAR =================
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => Nav.back(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.close_outlined, color: Colors.black),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),

      /// ================= BODY =================
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

            //=====================================================================
            Consumer<CartViewModel>(
              builder: (context, cartVm, _) {
                if (cartVm.isItemInCart(widget.item.id)) {
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "This item is already in your cart",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 10),

            //============================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.item.name,
                style: AppText.titleLarge.copyWith(
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Rs. ${widget.item.price.toStringAsFixed(0)}",
                    style: AppText.bodyLarge.copyWith(
                      color: widget.item.oldPrice != null
                          ? Colors.pink
                          : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  if (widget.item.oldPrice != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      "Rs. ${widget.item.oldPrice}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 15),
            Container(height: 8, color: Colors.grey.shade100),
            const SizedBox(height: 15),

            /// ================= FREQUENTLY BOUGHT =================
            if (frequentItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Frequently bought together",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Other customers also ordered these"),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Optional"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...visibleItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          height: 55,
                          width: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text("Rs. ${item.price.toStringAsFixed(0)}"),
                          ],
                        ),
                      ),
                      Consumer<CartViewModel>(
                        builder: (context, cartVm, _) {
                          return Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.black,
                            value: selectedFrequentItems[item.id] ?? false,
                            onChanged: (val) {
                              setState(() {
                                selectedFrequentItems[item.id] = val ?? false;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (frequentItems.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextButton(
                    onPressed: () => setState(() => showMore = !showMore),
                    child: Row(
                      children: [
                        Icon(
                          showMore ? Icons.expand_less : Icons.expand_more,
                          size: 30,
                          color: Colors.black,
                        ),
                        Text(
                          showMore ? "View less" : "View 3 more",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 15),
            Container(height: 8, color: Colors.grey.shade100),
            const SizedBox(height: 15),

            /// ================= SPECIAL INSTRUCTIONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Special instructions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Please let us know if you are allergic to anything or if we need to avoid anything",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _instructionController,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "e.g. no mayo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= QUANTITY COUNTER =================
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Border? border;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: quantity > 1 ? onRemove : null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.remove,
              color: quantity > 1 ? Colors.black : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
