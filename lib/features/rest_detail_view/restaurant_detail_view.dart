import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/cart/cart_view.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/rest_detail_view/item_detail_view.dart';
import 'package:food_delivery_app/features/rest_detail_view/rest_location.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:food_delivery_app/features/rest_detail_view/restaurant_detail_viewmodel.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantDetailView extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailView({super.key, required this.restaurant});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  final ScrollController _nestedController = ScrollController();

  bool _isTabInitialized = false;
  bool _isSticky = false;

  void _initTabs(int length) {
    if (_isTabInitialized) return;
    _tabController = TabController(length: length, vsync: this);
    _isTabInitialized = true;
  }

  void _scrollToCategory(int index) {
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();

    _nestedController.addListener(() {
      if (_nestedController.hasClients) {
        // Adjust this value according to AppBar + Restaurant info height
        bool stickyNow = _nestedController.offset >= 280;
        if (stickyNow != _isSticky) {
          setState(() {
            _isSticky = stickyNow;
          });
        }
      }
    });

    _positionsListener.itemPositions.addListener(() {
      final positions = _positionsListener.itemPositions.value;

      if (positions.isEmpty) return;

      final visiblePositions = positions
          .where((pos) => pos.itemLeadingEdge >= 0)
          .toList();

      if (visiblePositions.isEmpty) return;

      final firstVisibleIndex = visiblePositions
          .map((pos) => pos.index)
          .reduce((a, b) => a < b ? a : b);

      if (_isTabInitialized &&
          firstVisibleIndex < _tabController.length &&
          _tabController.index != firstVisibleIndex) {
        _tabController.animateTo(firstVisibleIndex);
      }
    });
  }

  @override
  void dispose() {
    _nestedController.dispose();
    if (_isTabInitialized) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          RestaurantDetailViewModel()..loadCategories(widget.restaurant.id),
      child: Consumer<RestaurantDetailViewModel>(
        builder: (context, vm, _) {

          final allItems = vm.categories
    .expand((category) => category.items)
    .toList();

          if (vm.isLoading) {
            return Scaffold(
              body: Center(
                child: Lottie.asset(
                  "assets/lottie/loader.json",
                  height: 100,
                  width: 100,
                ),
              ),
            );
          }

          _initTabs(vm.categories.length);

          return Scaffold(
            backgroundColor: Colors.white,

            bottomNavigationBar: Consumer<CartViewModel>(
  builder: (context, cartVm, _) {
    // Check if this restaurant has any item in cart
    final restaurantInCart = cartVm.cart.firstWhere(
      (r) => r['restaurantId'] == widget.restaurant.id,
      orElse: () => {},
    );

    if (restaurantInCart.isEmpty) return const SizedBox.shrink();

    // Calculate total items & price
    final items = List<Map<String, dynamic>>.from(restaurantInCart['items'] ?? []);
    int totalItems = items.fold(0, (sum, item) => sum + (item['qty'] ?? 0) as int);
    double totalPrice = items.fold(0.0, (sum, item) => sum + ((item['price'] ?? 0) * (item['qty'] ?? 1)));

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to Cart screen
          Nav.to(context, CartView()); // replace with your cart screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white,width: 1)),
              child: Text("$totalItems")),
            Text("View your Cart"),
            Text("Rs. ${totalPrice.toStringAsFixed(0)}"),
          ],
        ),
      ),
    );
  },
),

         
     
            body: NestedScrollView(
              controller: _nestedController,
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: false,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      widget.restaurant.image,
                      fit: BoxFit.cover,
                    ),
                  ),

                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: _circleIcon(Icons.arrow_back, () {
                          Nav.back(context);
                        }, 5),
                      ),
                      // Container(height: 5,width: 5,color: Colors.red,)
                    ],
                  ),

                  actions: [
                    _circleIcon(Icons.info_outline, () {
                      Nav.toAnimated(
                        context,
                        RestaurantInfoScreen(restaurant: widget.restaurant),
                      ); // yaha error araha hai
                    }),
                    
                    _circleIcon(Icons.share, () {}),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: AppText.bodyLarge.copyWith(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${widget.restaurant.rating} • (5000+ ratings)",
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _deliveryBox(
                          widget.restaurant.deliveryTime,
                          widget.restaurant.deliveryFee.toString(),
                        ),
                        const SizedBox(height: 14),
                        Image.asset("assets/png_images/disscount.png"),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeader(
                    tabController: _tabController,
                    tabs: vm.categories.map((e) => e.name).toList(),
                    onTap: _scrollToCategory,
                  ),
                ),
              ],
              body: ScrollablePositionedList.builder(
                itemPositionsListener: _positionsListener,
                itemScrollController: _scrollController,
                physics: _isSticky
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: vm.categories.length,
                itemBuilder: (context, index) {
                  final category = vm.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 5,
                            bottom: 18,
                          ),
                          child: Text(
                            category.name,
                            style: AppText.bodyLarge.copyWith(
                              color: Colors.black,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        ...category.items.map(
                          (item) => _itemWidget(
                            item.name,
                            item.image,
                            item.price,
                            item.oldPrice,
                            item.description,
                            () {
                              Nav.to(context, 
                              ItemDetailScreen(
                                item: item,
                                allItems: allItems,
                                restaurantName: widget.restaurant.name, // yaha kiya pass kro  
                                restaurantImage:widget.restaurant.image,
                                restaurantLocation: widget.restaurant.location  
                              )); 
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  

  /// Small Widgets
  Widget _circleIcon(IconData icon, VoidCallback onTap, [double? padding]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(padding ?? 7),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _itemWidget(
    String title,
    String image,
    double price,
    double? oldPrice, 
    String description, 
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ITEM NAME
                  Text(
                    title,
                    style: AppText.titleLarge.copyWith(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// PRICE ROW
                  Row(
                    children: [
                      /// NEW PRICE (ALWAYS SHOW)
                    oldPrice != null ? 
                      Text(
                        "Rs. ${price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:   Colors.pink,
                        ),
                      ) 
                      : 
                        Text(
                        "Rs. ${price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:   Colors.black,
                        ),
                      ), 

                      /// OLD PRICE (OPTIONAL)
                      if (oldPrice != null && oldPrice > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          "Rs. ${oldPrice.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// DESCRIPTION (MAX 2 LINES + ...)
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            /// IMAGE + ADD BUTTON
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 130,
                        width: 130,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 130,
                      width: 130,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    height: 33,
                    width: 33,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryBox(String time, String fee) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bike_outlined),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delivery $time min",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Rs. $fee delivery "),
                  const Text(
                    "free with Rs. 500.00 spend •",
                    style: TextStyle(color: Colors.pink),
                  ),
                ],
              ),
              const Text("Min. order Rs. 149.00"),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sticky Header
class _StickyHeader extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;
  final Function(int) onTap;

  _StickyHeader({
    required this.tabController,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SafeArea(top: true, child: SizedBox(height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 10),
                Text("Search menu"),
              ],
            ),
          ),
          TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            onTap: onTap,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 160;
  @override
  double get minExtent => 160;
  @override
  bool shouldRebuild(_) => false;
}
////////////////