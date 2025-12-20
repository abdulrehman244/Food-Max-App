import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_color.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/rest_detail_view/item_detail_view.dart';
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
      if (_positionsListener.itemPositions.value.isEmpty) return;

      final firstVisibleIndex = _positionsListener.itemPositions.value
          .where((pos) => pos.itemLeadingEdge >= 0)
          .map((pos) => pos.index)
          .reduce((a, b) => a < b ? a : b);

      if (_tabController.index != firstVisibleIndex) {
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
          if (vm.isLoading) {
            return Scaffold(
              body: Center(child: Lottie.asset("assets/lottie/loader.json",height: 100,width: 100)),
            );
          }

          _initTabs(vm.categories.length);

          return Scaffold(
            backgroundColor: Colors.white,
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
                  leading: _circleIcon(Icons.arrow_back, () {
                    Navigator.pop(context);
                  }),
                  actions: [
                    _circleIcon(Icons.favorite_border, () {}),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
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
                            item.description,
                            () {
                              Nav.to(context, ItemDetailScreen(item: item));
                            },
                          ),
                        ),

                        Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(color: Colors.grey.shade100),
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
  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(7),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _itemWidget(
    String title,
    String image,
    double price,
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
                  Text(
                    title,
                    style: AppText.titleLarge.copyWith(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text("Rs. $price.0"),
                  const SizedBox(height: 10),
                  Text(description),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Stack(
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: Image.network(
                //     image,
                //     width: 120,
                //     height: 120,
                //     fit: BoxFit.cover,
                //   ),
                // ),

                ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: CachedNetworkImage(
    imageUrl: image,
    height: 130,
    width: 130,
    fit: BoxFit.cover,
    placeholder: (context, url) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 130,
          width: 130,
          color: Colors.grey.shade200,
        ),
      ),
    ),
    errorWidget: (context, url, error) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 130,
        width: 130,
        color: Colors.grey.shade200,
        child: Icon(Icons.error),
      ),
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
                      border: Border.all(width: 2, color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 20),
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
            indicatorColor: AppColors.appColor,
            labelColor: AppColors.appColor,
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







// import 'package:flutter/material.dart';
// import 'package:food_delivery_app/config/theme/app_color.dart';
// import 'package:food_delivery_app/config/theme/app_text.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// import 'package:food_delivery_app/data/models/restaurant_model.dart';
// import 'package:food_delivery_app/features/rest_detail_view/restaurant_detail_viewmodel.dart';

// class RestaurantDetailView extends StatefulWidget {
//   final RestaurantModel restaurant;

//   const RestaurantDetailView({super.key, required this.restaurant});

//   @override
//   State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
// }

// class _RestaurantDetailViewState extends State<RestaurantDetailView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   final ItemScrollController _scrollController = ItemScrollController();
//   final ItemPositionsListener _positionsListener = ItemPositionsListener.create();


//   bool _isTabInitialized = false;

//   void _initTabs(int length) {
//     if (_isTabInitialized) return;

//     _tabController = TabController(length: length, vsync: this);
//     _isTabInitialized = true;
//   }

//   void _scrollToCategory(int index) {
//     _scrollController.scrollTo(
//       index: index,
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeOutCubic,
//     );
//   }


//   @override
// void initState() {
//   super.initState();

//   _positionsListener.itemPositions.addListener(() {
//     if (_positionsListener.itemPositions.value.isEmpty) return;

//     final firstVisibleIndex = _positionsListener.itemPositions.value
//         .where((position) => position.itemLeadingEdge >= 0)
//         .map((pos) => pos.index)
//         .reduce((a, b) => a < b ? a : b);

//     if (_tabController.index != firstVisibleIndex) {
//       _tabController.animateTo(firstVisibleIndex);
//     }
//   });
// }


//   @override
//   void dispose() {
//     if (_isTabInitialized) {
//       _tabController.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) =>
//           RestaurantDetailViewModel()..loadCategories(widget.restaurant.id),
//       child: Consumer<RestaurantDetailViewModel>(
//         builder: (context, vm, _) {
//           if (vm.isLoading) {
//             return Scaffold(
//               body: Center(child: Lottie.asset("assets/lottie/loader.json")),
//             );
//           }

//           _initTabs(vm.categories.length);

//           return Scaffold(
//             backgroundColor: Colors.white,
//             body: NestedScrollView(
//               headerSliverBuilder: (_, __) => [
//                 /// 🔹 IMAGE APP BAR
//                 SliverAppBar(
//                   expandedHeight: 180,
//                   pinned: false,
//                   backgroundColor: Colors.white,
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Image.network(
//                       widget.restaurant.image,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   leading: _circleIcon(Icons.arrow_back, () {
//                     Navigator.pop(context);
//                   }),
//                   actions: [
//                     _circleIcon(Icons.favorite_border, () {}),
//                     _circleIcon(Icons.share, () {}),
//                   ],
//                 ),

//                 /// 🔹 RESTAURANT INFO
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           widget.restaurant.name,
//                           style: AppText.bodyLarge.copyWith(
//                             color: Colors.black,
//                             fontSize: 20,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               color: Colors.orange,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               "${widget.restaurant.rating} • (5000+ ratings)",
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 14),
//                         _deliveryBox(
//                           widget.restaurant.deliveryTime,
//                           widget.restaurant.deliveryFee.toString(),
//                         ),

//                         const SizedBox(height: 14),

//                         Image.asset("assets/png_images/disscount.png")
//                       ], 
//                     ),
//                   ),
//                 ),

//                 /// 🔹 STICKY SEARCH + TABS
//                 SliverPersistentHeader(
//                   pinned: true,
//                   delegate: _StickyHeader(
//                     tabController: _tabController,
//                     tabs: vm.categories.map((e) => e.name).toList(),
//                     onTap: _scrollToCategory,
//                   ),
//                 ),
//               ],

//               /// 🔹 BODY LIST (NO MANUAL SCROLL)
//               body: ScrollablePositionedList.builder(
//                 itemPositionsListener: _positionsListener,
//                 // physics: const NeverScrollableScrollPhysics(),
//                 itemCount: vm.categories.length,
//                 itemScrollController: _scrollController,
//                 itemBuilder: (context, index) {
//                   final category = vm.categories[index];

//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Text(
//                             category.name,
//                             style: AppText.bodyLarge.copyWith(color: Colors.black,fontSize: 25)
//                           ),
//                         ),

//                         ...category.items.map(
//                           (item) =>  
//                           _itemWidget(item.name, item.image, item.price,item.description),
                          
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// 🔹 SMALL WIDGETS
//   Widget _circleIcon(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.all(10),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//         padding: const EdgeInsets.all(7),
//         child: Icon(icon, color: Colors.black),
//       ),
//     );
//   }

//   Widget _itemWidget(String title,String image,double price,String description){
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,style: AppText.titleLarge.copyWith(color: Colors.black,fontSize: 14)),
//             Text("Rs. $price.0"),
//             SizedBox(height: 10,),
//             Text(description),
//               ],
//             ),
//           ),
//           SizedBox(width: 20,),
//           Stack(
//   children: [
//     // 🖼 Image
//     ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: Image.network(
//         image,
//         width: 120,
//         height: 120,
//         fit: BoxFit.cover,
//       ),
//     ),

//     // ➕ Circle Button on top-right
//     Positioned(
//       bottom: 4,
//       right: 4,
//       child: GestureDetector(
//         onTap: () {
//         },
//         child: Container(
//           height: 33,
//           width: 33,
//           decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           border: Border.all(
//             width: 2,
//             color: Colors.grey.shade400,
//           )
//           ),
//           child: Icon(
//             Icons.add,
//             color: Colors.black,
//             size: 20,
//           ),
//         ),
//       ),
//     ),
//   ],
// )

//         ],
//       ),
//     );
//   }

  

//   Widget _deliveryBox(String time, String fee) {
//     return Container(
//       height: 100,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.directions_bike_outlined),
//           SizedBox(width: 20),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Delivery $time min",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text("Rs. $fee delivery "),
//                   Text(
//                     "free with Rs. 500.00 spend •",
//                     style: TextStyle(color: Colors.pink),
//                   ),
//                 ],
//               ),
//               Text("Min. order Rs. 149.00"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// 🔹 STICKY HEADER
// class _StickyHeader extends SliverPersistentHeaderDelegate {
//   final TabController tabController;
//   final List<String> tabs;
//   final Function(int) onTap;

//   _StickyHeader({
//     required this.tabController,
//     required this.tabs,
//     required this.onTap,
//   });

//   @override
//   Widget build(context, shrinkOffset, overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [

//           SafeArea(
//             top: true,
//             child: SizedBox(height: 1,)),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.search),
//                 SizedBox(width: 10),
//                 Text("Search menu"),
//               ],
//             ),
//           ),

//           TabBar(
//             controller: tabController,
//             isScrollable: true,
//             indicatorColor: AppColors.appColor,
//             labelColor: AppColors.appColor,
//             unselectedLabelColor: Colors.grey,
//             onTap: onTap,
//             tabs: tabs.map((e) => Tab(text: e)).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 160;
//   @override
//   double get minExtent => 160;
//   @override
//   bool shouldRebuild(_) => false;
// }










// import 'package:flutter/material.dart';
// import 'package:food_delivery_app/features/rest_detail_view/item_detail_view.dart';
// import 'package:provider/provider.dart';
// import 'package:food_delivery_app/data/models/restaurant_model.dart';
// import 'restaurant_detail_viewmodel.dart';

// class RestaurantDetailView extends StatelessWidget {
//   final RestaurantModel restaurant;

//   const RestaurantDetailView({super.key, required this.restaurant});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => RestaurantDetailViewModel()..loadCategories(restaurant.id),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(restaurant.name),
//           backgroundColor: Colors.red,
//         ),
//         body: Consumer<RestaurantDetailViewModel>(
//           builder: (context, vm, child) {
//             if (vm.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant Image
//                   Image.network(
//                     restaurant.image,
//                     width: double.infinity,
//                     height: 220,
//                     fit: BoxFit.cover,
//                   ),

//                   const SizedBox(height: 10),

//                   // Restaurant Info
//                   Padding(
//                     padding: const EdgeInsets.all(15),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           restaurant.name,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text("⭐ ${restaurant.rating}  •  ${restaurant.type}",
//                             style: TextStyle(fontSize: 16, color: Colors.grey)),
//                         Text("Delivery Time: ${restaurant.deliveryTime} min",
//                             style: TextStyle(fontSize: 15)),
//                       ],
//                     ),
//                   ),

//                   const Divider(thickness: 1),

//                   // CATEGORIES + ITEMS
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: vm.categories.length,
//                     itemBuilder: (context, index) {
//                       final category = vm.categories[index];

//                       return Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Category Name
//                             Text(
//                               category.name,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 10),

//                             // ITEMS LIST
// ListView.builder(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemCount: category.items.length,
//   itemBuilder: (context, itemIndex) {
//     final item = category.items[itemIndex];

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         leading: Image.network(
//           item.image,
//           width: 60,
//           fit: BoxFit.cover,
//         ),
//         title: Text(item.name),
//         subtitle: Text(item.description),
//         trailing: Text(
//           "Rs ${item.price}",
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         onTap: () {
//           // Navigate to item detail screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ItemDetailScreen(item: item),
//             ),
//           );
//         },
//       ),
//     );
//   },
// ),

//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



/*



import 'package:flutter/material.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RestaurantDetailView extends StatefulWidget {
  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView>
    with TickerProviderStateMixin {
  late TabController _tabController;

   final RestaurantModel restaurant;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: categoryTabs.length, vsync: this);

    _positionsListener.itemPositions.addListener(() {
      int firstVisible = _positionsListener.itemPositions.value
          .where((position) => position.itemLeadingEdge >= 0)
          .map((pos) => pos.index)
          .fold(999, (prev, index) => index < prev ? index : prev);

      if (firstVisible < categoryTabs.length &&
          _tabController.index != firstVisible) {
        _tabController.animateTo(firstVisible);
      }
    });
  }

  void scrollToSection(int index) {
    _scrollController.scrollTo(
      index: index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
           
            SliverAppBar(
              expandedHeight: 260,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  "", // yaha restaurant ki image aye gi 
                  fit: BoxFit.cover,
                ),
              ),
              leading: _circleIcon(Icons.arrow_back, () {
                Navigator.pop(context);
              }),
              actions: [
                _circleIcon(Icons.info_outline, () {}),
                _circleIcon(Icons.favorite_border, () {}),
                _circleIcon(Icons.share, () {}),
              ],
            ),

            // -------------------
            // RESTAURANT INFO
            // -------------------
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "", // yaha restaurant ka name ayega 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        SizedBox(width: 6),
                        Text(""), // yah restaurant ki ratting aye gi ok
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _deliveryBox(),
                  ),

                  SizedBox(height: 12),
                  _discountRow(),
                ],
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeader(
                tabController: _tabController,
                tabs: categoryTabs,
                onTap: scrollToSection,
              ),
            ),
          ];
        },

     
        body: ScrollablePositionedList.builder(
          itemCount: categoryTabs.length,
          itemScrollController: _scrollController,
          itemPositionsListener: _positionsListener,

          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Title
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    categoryTabs[index],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                // Dummy Food Items for each section
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text("${categoryTabs[index]} item $i"),
                      subtitle: Text("Delicious Food"),
                    );
                  },
                ),

                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // -----------------------
  // SMALL WIDGETS
  // -----------------------

  Widget _circleIcon(IconData icon, VoidCallback? ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Padding(
          padding: EdgeInsets.all(3),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }

  Widget _deliveryBox() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery 5–30 min", // delivery time aye ga 
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Rs. 79 delivery  •  Min order Rs. 149"), // yaha deliveri fee ayegi 
        ],
      ),
    );
  }

  Widget _discountRow() {
    return Container(
      height: 90,
      margin: EdgeInsets.only(left: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _discountChip("15% off"),
          _discountChip("10% off"),
          _discountChip("50% off"),
        ],
      ),
    );
  }

  Widget _discountChip(String text) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text),
    );
  }
}

//
// STICKY HEADER (Search + Category TabBar)
//
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
          // Search bar
          Container(
            margin: EdgeInsets.fromLTRB(16, 12, 16, 10),
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.black54),
                SizedBox(width: 10),
                Text("Search menu", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          // Category Tab Bar
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Colors.pink,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pink,
            onTap: onTap,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(_) => true;
}
*/