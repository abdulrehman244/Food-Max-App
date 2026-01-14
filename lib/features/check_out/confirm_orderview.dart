import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/buildTimeline_widget.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/check_out/check_outview.dart';
import 'package:provider/provider.dart';

class ConfirmOrderview extends StatelessWidget {
  final String restaurantId;

  const ConfirmOrderview({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();


  final restaurant = cartVm.cart.firstWhere(
  (r) => r["restaurantId"] == restaurantId,
  orElse: () => {},
);

if (restaurant.isEmpty) {
  return const Scaffold(
    body: Center(
      child: Text(
        "Cart is empty",
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}


    final List items = restaurant["items"];

    double subTotal = 0;

    for (var item in items) {
      final price = (item["price"] as num).toDouble();
      final qty = (item["qty"] as num).toInt();
      subTotal += price * qty;
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Consumer<CartViewModel>(
          builder: (context, cartVm, child) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent, // 🔥 IMPORTANT
              scrolledUnderElevation: 0, // 🔥 IMPORTANT
              leading: Icon(Icons.close, color: Colors.black, size: 20),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cart',
                    style: AppText.bodyLarge.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  40,
                ), // increased for title/subtitle
                child: buildTimeline(),
              ),
            ),
            bottomNavigationBar: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Total",
                          style: AppText.titleLarge.copyWith(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "(incl. fees and tax)",
                          style: AppText.bodyLarge.copyWith(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),

                        cartVm.isSwitched ?  

                        Column(
                          children: [
                            Text(
                                    "Rs. ${subTotal - 430}0",
                                    style:  TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                           Text(
                      "Rs. ${subTotal}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                         fontSize: 18
                      ),
                    ),
                          ],
                        )  : Text(
                                    "Rs. ${subTotal + 150}0",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ) 

                      
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  Divider(color: Colors.grey.shade400, indent: 0, endIndent: 0),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MyButton(
  title: "Confirm payment and address",
  ontap: () {
    
    Nav.toAnimated(
      context,
      CheckoutScreen(
        restaurantId: restaurantId,
      ),
    );
  },
),


                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),

            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _deliveryCard(context),
                    ),
                    const SizedBox(height: 16),

                    Column(
                      children: [
                        /// ================= ITEMS LIST =================
                        ...items.map<Widget>((item) {
                          final mapItem = Map<String, dynamic>.from(item);

                          final int qty = (mapItem["qty"] as num).toInt();
                          final double price = (mapItem["price"] as num)
                              .toDouble();
                          final double itemTotal = price * qty;

                   return 
                   Column(
                     children: [
                       Container(
                         margin: const EdgeInsets.only(bottom: 14),
                         padding: const EdgeInsets.all(12),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                       
                             /// IMAGE
                             ClipRRect(
                               borderRadius: BorderRadius.circular(8),
                               child: Image.network(
                                 mapItem["image"],
                                 height: 60,
                                 width: 60,
                                 fit: BoxFit.cover,
                               ),
                             ),
                       
                             const SizedBox(width: 12),
                       
                             /// CENTER CONTENT
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                       
                                   /// ITEM NAME
                                   Text(
                                     mapItem["name"],
                                     style: const TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                       
                                   const SizedBox(height: 18),
                       
                                   /// QUANTITY ROW
                                   Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                   
                                       /// MINUS / DELETE
                                       Container(
                                         height: 35,
                                         decoration: BoxDecoration(
                                       border: Border.all(color: Colors.grey.shade300),
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                         child: 
                                         Row(
                        children: [
                           GestureDetector(
                         onTap: () {
                           HapticFeedback.vibrate();
                       
                           cartVm.decreaseQty(
                             restaurantId,
                             mapItem["itemId"],
                           );
                         },
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           child: Icon(
                             qty == 1 ? Icons.delete_outline : Icons.remove,
                             size: 18,
                           ),
                         ),
                       ),
                                   
                                       Text(
                                         qty.toString(),
                                         style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                   
                                     GestureDetector(
                         onTap: () {
                           HapticFeedback.vibrate();
                           cartVm.increaseQty(
                             restaurantId,
                             mapItem["itemId"],
                           );
                         },
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           child: const Icon(Icons.add, size: 18),
                         ),
                       ),
                       
                        ],
                                         ),
                                       
                                       
                                       ),
                                       Spacer(),
                                       Text(
                        "Rs. ${itemTotal.toStringAsFixed(2)}",
                        style: AppText.bodyLarge.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                                         ),
                                     ],
                                   ),
                                 
                                 // Divider(color: Colors.black,)
                                 
                                 ],
                               ),
                             ),
                       
                           ],
                         ),
                       ),
                     
                     Divider(color: Colors.grey.shade300)
                     ],
                   );
                        }).toList(),


                        /// ================= SUBTOTAL =================
                      ],
                    ),

                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Nav.to(context, BottomNavi());
                        },
                        child: const Text(
                          '+ Add more items',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spacer ki jagah ye
                        children: [
                          Text(
                            "Subtotal",
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "Rs. ${subTotal.toStringAsFixed(2)}",
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                    ),
                    SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text("Standard delivery"),
                          Spacer(),
                          Text("Rs. 99.00"),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text("Platform Fee", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),

                          Tooltip(
                            triggerMode: TooltipTriggerMode.tap, // 🔥 IMPORTANT
                            message:
                                "This helps us improve product features, experience & manage operational costs",
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF5B1E8C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            preferBelow: false,
                            showDuration: const Duration(seconds: 3),
                            child: const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Color.fromARGB(255, 97, 97, 97),
                            ),
                          ),
                          Spacer(),
                          Text("Rs. 14.99"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.ticket),
                          SizedBox(width: 10),
                          Text(
                            "Apply a Voucher",
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                           Consumer<CartViewModel>(
        builder: (context, cartVm, child) => Switch(
          value: cartVm.isSwitched,
          onChanged: (value) {
            cartVm.toggleSwitch(value);
          },
          activeColor: Colors.pink, // ON color
          inactiveThumbColor: Colors.grey, // OFF thumb color
          inactiveTrackColor: Colors.grey.shade300, // OFF track
        ),
      ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deliveryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 3, color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, size: 40, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated delivery', style: TextStyle(color: Colors.grey)),
              Text(
                'Standard (20–35 mins)',
                style: AppText.titleLarge.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text('Change', style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }


}
