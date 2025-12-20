import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/buildTimeline_widget.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/check_out/check_outview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class ConfirmOrderview extends StatelessWidget {
  const ConfirmOrderview({super.key});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.read<CartViewModel>();

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
            bottomNavigationBar:
             Container(
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
                        Column(
                          children: [
                            cartViewModel.isSwitched ? 
                                 Text(
                                    cartVm.finalTotal.toStringAsFixed(2),
                                    style: AppText.bodyLarge.copyWith(
                                      color: Colors.pink,
                                      fontSize: 16,
                                    ),
                                  ) :
                            Text(
                                    cartVm.totalPrice.toStringAsFixed(2),
                                    style: AppText.bodyLarge.copyWith(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                
                            cartViewModel.isSwitched ? Text(
                               cartVm.totalPrice.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ) : SizedBox(),
                          ],
                        ),
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
                        Nav.to(context, CheckoutScreen());
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
                      child: _deliveryCard(),
                    ),
                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartVm.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartVm.cartItems[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: item['image'] ?? "",
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey.shade300,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(width: 20),

                                  // NAME + PRICE + QUANTITY
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: AppText.bodyLarge.copyWith(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          children: [
                                            // DECREASE BUTTON
                                            Container(
                                              height: 38,
                                              width: 117,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  IconButton(
                                                    icon: item["quantity"] == 1
                                                        ? Icon(
                                                            FontAwesomeIcons
                                                                .trashCan,
                                                            size: 16,
                                                          )
                                                        : Icon(Icons.remove),
                                                    onPressed: () {
                                                      if (item['quantity'] >
                                                          1) {
                                                        cartVm
                                                            .updateItemQuantity(
                                                              item['name'],
                                                              item['quantity'] -
                                                                  1,
                                                            );
                                                      } else {
                                                        cartVm.removeFromCart(
                                                          item['name'],
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  // QUANTITY
                                                  Text(
                                                    item['quantity'].toString(),
                                                    style: AppText.bodyLarge
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                  ),

                                                  // INCREASE BUTTON
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      cartVm.updateItemQuantity(
                                                        item['name'],
                                                        item['quantity'] + 1,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Spacer(),
                                            // TOTAL PRICE PER ITEM
                                            Text(
                                              "Rs. ${(item['price'] * item['quantity']).toStringAsFixed(0)}",
                                              style: AppText.bodyLarge.copyWith(
                                                color: Colors.grey.shade600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Nav.to(context, BottomNavi());
                          final model = Provider.of<HomeViewModel>(
                            context,
                            listen: false,
                          );
                          model.isSearchBarSticky = false; // hide sticky bar
                          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                          model.notifyListeners();
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
                      child: Row(
                        children: [
                          Text(
                            "Subtotal",
                            style: AppText.titleLarge.copyWith(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Rs. ${cartVm.totalPrice.toStringAsFixed(2)}",
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
                              color: AppColors.learnMore,
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
                          Switch(
                            value: cartVm.isSwitched,
                            onChanged: (value) {
                              cartVm.toggle(value);
                            },
                            activeColor: Colors.pink, // ON color
                            inactiveThumbColor: Colors.grey, // OFF thumb color
                            inactiveTrackColor:
                                Colors.grey.shade300, // OFF track color
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

  Widget _deliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 3, color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, size: 40, color: AppColors.appColor),
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






