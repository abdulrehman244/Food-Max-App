import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/PromoFixedBar.dart';
import 'package:food_delivery_app/core/widgets/bottomSheet_widget.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/core/widgets/custom_searchbar.dart';
import 'package:food_delivery_app/core/widgets/locationBottom_widget.dart';
import 'package:food_delivery_app/core/widgets/promoPopup_widget.dart';
import 'package:food_delivery_app/core/widgets/shimmer_cards.dart';
import 'package:food_delivery_app/features/account/account_view.dart';
import 'package:food_delivery_app/features/bottom_navigation/bottom_navi.dart';
import 'package:food_delivery_app/features/favorite/favorite_itemview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/home/itemView.dart';
import 'package:food_delivery_app/features/rest_detail_view/restaurant_detail_view.dart';
import 'package:food_delivery_app/features/search/search_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:shimmer/shimmer.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late HomeViewModel homeVm;

  double topSpace = 170;
  double containerOffset = -40;
  // bool showPromo = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homeVm = context.read<HomeViewModel>();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Post-frame safe calls
  WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  homeVm.fetchAndSaveRestaurants();
  homeVm.loadCurrentUser();
  if (!homeVm.restaurantsFetched) homeVm.fetchRestaurants();

  // Scroll listener
  homeVm.scroll.addListener(_scrollListener);

  // Start promo timer & show after delay
  homeVm.showPromoWithDelay(); // ✅ fixed delay + single source

  _startContainerAnimation();
});

 
  }

  void _scrollListener() {
    if (!mounted) return;

    // Sticky search logic
    if (homeVm.scroll.offset > 160 && !homeVm.stickySearch.value) {
      homeVm.stickySearch.value = true;
    } else if (homeVm.scroll.offset <= 160 && homeVm.stickySearch.value) {
      homeVm.stickySearch.value = false;
    }

    // Lazy load restaurants
    if (homeVm.scroll.position.pixels >=
        homeVm.scroll.position.maxScrollExtent - 100) {
      if (!homeVm.isLoadingMore) homeVm.loadMoreRestaurants();
    }
  }

  void _startContainerAnimation() {
    if (!mounted) return;
    setState(() {
      topSpace = 170;
      containerOffset = -40;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        topSpace = 280;
        containerOffset = -20;
      });
    });
  }

  bool _promoTimerStarted = false;


  // void showPromoBar() => setState(() => showPromo = true);
  // void hidePromoBar() => setState(() => showPromo = false);

  @override
  void dispose() {
    homeVm.scroll.removeListener(_scrollListener);
    homeVm.stickySearch.value = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin

   final vm = context.watch<HomeViewModel>();

  if (vm.isRestaurantLoading &&
      !_promoTimerStarted &&
      !vm.promoPopupShownThisSession) {

    _promoTimerStarted = true;

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      if (vm.canShowPromoPopup()) {
        showPromotionalPopup(context);
      }
    });
  }

    return Stack(
      children: [
        // MAIN HOME CONTENT
        homeWidget(context, topSpace, containerOffset, homeVm),

        // PROMO BAR
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: (vm.promoVisible && !vm.isRestaurantLoading) ? 0 : -120,
          child: PromoFixedBar(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const PromoBottomSheet(),
              );
            },
            icon: GestureDetector(
              onTap: () {
                vm.dismissPromo(); // ✅ MAIN FIX
              },
              child: const Icon(Icons.close, size: 22),
            ),
          ),
        ),


      ],
    );
  }
}







Widget homeWidget(
  BuildContext context,
  double topSpace,
  double containerOffset,
  HomeViewModel homeVm,
) {
  return RepaintBoundary(
    child: Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              /// HEADER
              RepaintBoundary(
                child: Container(
                  height: 350,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 30,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),

                          Consumer<HomeViewModel>(
                            builder: (context, model, child) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    model.userAddress.isEmpty
                                        ? "loading address...."
                                        : model.userAddress,
                                    style: AppText.titleLarge.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  model.userCity.isEmpty
                                      ? "loading..."
                                      : "${model.userCity}, Pakistan",
                                  style: AppText.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountView(),
                                ),
                              );
                            },
                            child: IconButton(
                              onPressed: () {
                                Nav.to(context, AccountView());
                              },
                              icon: const Icon(
                                Icons.favorite_border_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Consumer<HomeViewModel>(
                        builder: (context, model, child) {
                          return GestureDetector(
                            onTap: () {
                              Nav.to(context, SearchView());
                            },
                            child: const CustomSearchbar(),
                          );
                        },
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back! Enjoy",
                                  style: AppText.titleLarge.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "50% off & free delivery",
                                  style: AppText.titleLarge.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "order now",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_circle_right,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://cdn.pixabay.com/photo/2022/06/26/09/41/chicken-bucket-7284948_1280.png",
                              height: 130,
                              width: 130,
                              placeholder: (context, url) => Center(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  period: Duration(milliseconds: 1000),
                                  child: Container(
                                    height: 80,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ), // <-- placeholder bhi rounded
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// SCROLLABLE CONTENT + WHITE CONTAINER
              Consumer<HomeViewModel>(
                builder: (context, model, child) => model.isRestaurantLoading
                    ? Container(
                        margin: const EdgeInsets.only(top: 130),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 86,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 5,
                                  itemBuilder: (c, i) => TopItemShimmer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 105,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 5,
                                  itemBuilder: (c, i) => CategoryItemShimmer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              shimmerContainer(),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 235,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 2,
                                  itemBuilder: (c, i) =>
                                      const RestaurantCardShimmer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 235,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 2,
                                  itemBuilder: (c, i) =>
                                      const RestaurantCardShimmer(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => model.refreshData(),
                        color: Colors.red, // loader color (optional)
                        backgroundColor: Colors.white,
                        displacement: 40, // loader ka niche se distance

                        child: SingleChildScrollView(
                          controller: model.scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: RepaintBoundary(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                  height: topSpace,
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                  transform: Matrix4.translationValues(
                                    0,
                                    containerOffset,
                                    0,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 30),
                                        // Top Items
                                        SizedBox(
                                          height: 86,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: model.items.length,
                                            itemBuilder: (c, i) {
                                              final item = model.items[i];
                                              return TopItem(
                                                title: item["title"].toString(),
                                                image: item["image"].toString(),
                                                onTap: () {
                                                  model.selectItem(
                                                    item["title"]!,
                                                  );
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      transitionDuration:
                                                          const Duration(
                                                            milliseconds: 800,
                                                          ),
                                                      reverseTransitionDuration:
                                                          const Duration(
                                                            milliseconds: 400,
                                                          ),
                                                      pageBuilder:
                                                          (_, animation, __) {
                                                            return Itemview();
                                                          },
                                                      transitionsBuilder:
                                                          (
                                                            _,
                                                            animation,
                                                            secondaryAnimation,
                                                            child,
                                                          ) {
                                                            // 🔥 Right-to-left slide animation
                                                            final offsetAnimation =
                                                                Tween<Offset>(
                                                                  begin: const Offset(
                                                                    1.0,
                                                                    0.0,
                                                                  ), // Right side se start
                                                                  end: Offset
                                                                      .zero,
                                                                ).animate(
                                                                  CurvedAnimation(
                                                                    parent:
                                                                        animation,
                                                                    curve: Curves
                                                                        .easeOutCubic,
                                                                    reverseCurve:
                                                                        Curves
                                                                            .easeInCubic,
                                                                  ),
                                                                );

                                                            return SlideTransition(
                                                              position:
                                                                  offsetAnimation,
                                                              child: child,
                                                            );
                                                          },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                          indent: 0,
                                          endIndent: 0,
                                        ),
                                        SizedBox(height: 5),
                                        // Categories
                                        SizedBox(
                                          height: 105,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                model.categoryTitles.length,
                                            itemBuilder: (c, i) {
                                              final title =
                                                  model
                                                      .categoryTitles[i]["title"] ??
                                                  "";

                                              return CategoryItem(
                                                imageUrl:
                                                    model
                                                        .categoryTitles[i]["image"] ??
                                                    "",
                                                title: title,
                                                isSelected:
                                                    model.selectedCategory ==
                                                    title,
                                                onTap: () {
                                                  model.selectCategory(title);
                                                },
                                              );
                                            },
                                          ),
                                        ),

                                        model.selectedCategory.isNotEmpty
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                    ),
                                                child: Container(
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                            66,
                                                            88,
                                                            88,
                                                            88,
                                                          ),
                                                    ),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(height: 20),

                                        model.selectedCategory.isNotEmpty
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: model
                                                    .filteredRestaurants
                                                    .length,
                                                itemBuilder: (c, i) {
                                                  final r = model
                                                      .filteredRestaurants[i];

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Nav.to(
                                                        context,
                                                        RestaurantDetailView(
                                                          restaurant: r,
                                                        ),
                                                      );
                                                    },
                                                    child: RestaurantCard(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 12,
                                                          ),
                                                      width: double.infinity,
                                                      imageUrl: r.image,
                                                      title: r.name,
                                                      rating:
                                                          "${r.rating} (5000+)",
                                                      time:
                                                          "${r.deliveryTime} min • \$\$ • ${r.type}",
                                                      price:
                                                          "From ${r.deliveryFee} With Saver",
                                                      restaurant: r,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 200,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                      child: Container(
                                                        height: 230,
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                              child: CarouselSlider(
                                                                items: model
                                                                    .images
                                                                    .map(
                                                                      (
                                                                        img,
                                                                      ) => Image.network(
                                                                        img,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width: double
                                                                            .infinity,
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                                options: CarouselOptions(
                                                                  height: 230,
                                                                  autoPlay:
                                                                      true,
                                                                  autoPlayInterval:
                                                                      Duration(
                                                                        seconds:
                                                                            3,
                                                                      ),
                                                                  viewportFraction:
                                                                      1,
                                                                  onPageChanged:
                                                                      (
                                                                        index,
                                                                        reason,
                                                                      ) {
                                                                        model.setCurrentIndex(
                                                                          index,
                                                                        );
                                                                      },
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 15,
                                                              left: 0,
                                                              right: 0,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: List.generate(
                                                                  model
                                                                      .images
                                                                      .length,
                                                                  (index) {
                                                                    bool
                                                                    active =
                                                                        index ==
                                                                        model
                                                                            .current;
                                                                    return AnimatedContainer(
                                                                      duration: Duration(
                                                                        milliseconds:
                                                                            300,
                                                                      ),
                                                                      margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4,
                                                                      ),
                                                                      width:
                                                                          active
                                                                          ? 30
                                                                          : 10,
                                                                      height:
                                                                          10,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white.withOpacity(
                                                                          active
                                                                              ? 1
                                                                              : 0.6,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 30),

                                                  // Popular Restaurants
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Popular Restaurants",
                                                            style: AppText
                                                                .titleLarge
                                                                .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .chevron_right_outlined,
                                                            size: 32,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  // Horizontal Restaurant Cards
                                                  SizedBox(
                                                    height: 270,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: model
                                                          .randomPopular
                                                          .length,
                                                      itemBuilder: (c, i) {
                                                        final r = model
                                                            .randomPopular[i];
                                                        return RestaurantCard(
                                                          imageUrl: r.image,
                                                          title: r.name,
                                                          rating:
                                                              ("${r.rating} (5000+)"),
                                                          time:
                                                              ("${r.deliveryTime} min • \$\$ • ${r.type}"),
                                                          price:
                                                              ("From ${r.deliveryFee} With Saver"),
                                                          restaurant: r,
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(height: 15),
                                                  // up to 30% off
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Up to 30% off!",
                                                            style: AppText
                                                                .titleLarge
                                                                .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .chevron_right_outlined,
                                                            size: 32,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  // Horizontal Restaurant Cards
                                                  SizedBox(
                                                    height: 290,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: model
                                                          .randomDiscount
                                                          .length,
                                                      itemBuilder: (c, i) {
                                                        final r = model
                                                            .randomDiscount[i];
                                                        return RestaurantCard(
                                                          imageUrl: r.image,
                                                          title: r.name,
                                                          rating:
                                                              ("${r.rating} (5000+)"),
                                                          time:
                                                              ("${r.deliveryTime} min • \$\$ • ${r.type}"),
                                                          price:
                                                              ("From ${r.deliveryFee} With Saver"),
                                                          restaurant: r,
                                                          container: Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 5,
                                                                ),
                                                            height: 20,
                                                            // width: 50,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    248,
                                                                    215,
                                                                    220,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  "assets/png_images/discount_2.png",
                                                                  height: 14,
                                                                  width: 14,
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  "30% off selected items",
                                                                  style: AppText
                                                                      .bodyLarge
                                                                      .copyWith(
                                                                        color: Colors
                                                                            .pink
                                                                            .shade700,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(height: 30),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Try something new",
                                                            style: AppText
                                                                .titleLarge
                                                                .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  // Horizontal Restaurant Cards
                                                  SizedBox(
                                                    height: 270,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: model
                                                          .randomNew
                                                          .length,
                                                      itemBuilder: (c, i) {
                                                        final r =
                                                            model.randomNew[i];
                                                        return RestaurantCard(
                                                          imageUrl: r.image,
                                                          title: r.name,
                                                          rating:
                                                              ("${r.rating} (5000+)"),
                                                          time:
                                                              ("${r.deliveryTime} min • \$\$ • ${r.type}"),
                                                          price:
                                                              ("From ${r.deliveryFee} With Saver"),
                                                          restaurant: r,
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(height: 30),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Top Brands",
                                                            style: AppText
                                                                .bodyLarge
                                                                .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20,
                                                                ),
                                                          ),
                                                        ),

                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                          child: Icon(
                                                            Icons.arrow_right,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  SizedBox(height: 15),

                                                  SizedBox(
                                                    height: 160,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: model
                                                          .restaurantsWithLogo
                                                          .length,
                                                      itemBuilder: (context, index) {
                                                        final r = model
                                                            .restaurantsWithLogo[index];
                                                        return TopBrandCard(
                                                          restaurant: r,
                                                          image: r
                                                              .logo, // Firebase se logo
                                                          name: r
                                                              .name, // restaurant ka name
                                                          city:
                                                              "Karachi", // ya r.location
                                                          time:
                                                              "${r.deliveryTime} min",
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 20,
                                                        ),
                                                    child: Container(
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              const Color.fromARGB(
                                                                66,
                                                                88,
                                                                88,
                                                                88,
                                                              ),
                                                        ),
                                                        color: Colors
                                                            .grey
                                                            .shade100,
                                                      ),
                                                    ),
                                                  ),

                                                  // SizedBox(height: 25,),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                        ),
                                                    child: Text(
                                                      "Explore Restaurants",
                                                      style: AppText.bodyLarge
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 25,
                                                          ),
                                                    ),
                                                  ),

                                                  AnimationLimiter(
                                                    // ✅ ADDED
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount: model
                                                          .restaurants
                                                          .length,
                                                      itemBuilder: (c, i) {
                                                        final r = model
                                                            .restaurants[i];

                                                        return AnimationConfiguration.staggeredList(
                                                          position: i,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    450,
                                                              ),
                                                          child: SlideAnimation(
                                                            verticalOffset: 60,
                                                            curve: Curves
                                                                .easeOutCubic,
                                                            child: FadeInAnimation(
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  Nav.to(
                                                                    context,
                                                                    RestaurantDetailView(
                                                                      restaurant:
                                                                          r,
                                                                    ),
                                                                  );
                                                                },
                                                                child: RestaurantCard(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                  width: double
                                                                      .infinity,
                                                                  imageUrl:
                                                                      r.image,
                                                                  title: r.name,
                                                                  rating:
                                                                      "${r.rating} (5000+)",
                                                                  time:
                                                                      "${r.deliveryTime} min • \$\$ • ${r.type}",
                                                                  price:
                                                                      "From ${r.deliveryFee} With Saver",
                                                                  restaurant: r,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  /// Show loader if lazy loading is in progress
                                                  if (model.isLoadingMore)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 20,
                                                          ),
                                                      child: Center(
                                                        child: Lottie.asset(
                                                          "assets/lottie/loader.json",
                                                          height: 80,
                                                          width: 80,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              ValueListenableBuilder<bool>(
                valueListenable: homeVm.stickySearch,
                builder: (context, isSticky, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    top: isSticky ? 0 : -80,
                    left: 0,
                    right: 0,
                    child: child!,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Theme.of(context).primaryColor,
                  child: const CustomSearchbar(),
                ),
              ),

              // Transparent tap area for search
              ValueListenableBuilder<bool>(
                valueListenable: homeVm.stickySearch,
                builder: (context, isSticky, child) =>
                    isSticky ? const SizedBox() : child!,
                child: Positioned(
                  top: 80,
                  left: 31,
                  child: GestureDetector(
                    onTap: () {
                      final bottomNaviState = context
                          .findAncestorStateOfType<BottomNaviState>();
                      bottomNaviState?.currentIndex.value = 2;
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 40,
                      width: 355,
                    ),
                  ),
                ),
              ),

              // Favorite icon
              ValueListenableBuilder<bool>(
                valueListenable: homeVm.stickySearch,
                builder: (context, isSticky, child) =>
                    isSticky ? const SizedBox() : child!,
                child: Positioned(
                  right: 13,
                  top: 6,
                  child: GestureDetector(
                    onTap: () {
                      Nav.to(context, FavoriteItemview());
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ),

              // Pressable card
              ValueListenableBuilder<bool>(
                valueListenable: homeVm.stickySearch,
                builder: (context, isSticky, child) =>
                    isSticky ? const SizedBox() : child!,
                child: Positioned(
                  left: 20,
                  top: 17,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const LocationConfirmBottomSheet(),
                      );
                    },
                    child: Container(color: Colors.transparent, height: 35, width: 260),
                  ),
                ),
              ),

              /// STICKY SEARCH BAR
              // Consumer<HomeViewModel>(
              //   builder: (context, model, child) => AnimatedPositioned(
              //     duration: const Duration(milliseconds: 300),
              //     curve: Curves.easeOut,
              //     top: model.isSearchBarSticky ? 0 : -80,
              //     left: 0,
              //     right: 0,
              //     child: Container(
              //       padding: const EdgeInsets.only(
              //         top: 10,
              //         left: 10,
              //         right: 10,
              //         bottom: 5,
              //       ),
              //       color: Theme.of(context).primaryColor,
              //       child: const CustomSearchbar(),
              //     ),
              //   ),
              // ),

              // Consumer<HomeViewModel>(
              //   builder: (context, model, child) {
              //     return model.isSearchBarSticky
              //         ? SizedBox()
              //         : Positioned(
              //             top: 80,
              //             left: 31,
              //             child: GestureDetector(
              //               onTap: () {
              //                 final bottomNaviState = context
              //                     .findAncestorStateOfType<BottomNaviState>();
              //                 if (bottomNaviState != null) {
              //                   bottomNaviState.currentIndex.value =
              //                       2; // Search screen
              //                 }
              //               },
              //               child: Container(
              //                 color: Colors.transparent,
              //                 height: 40,
              //                 width: 355,
              //               ),
              //             ),
              //           );
              //   },
              // ),

              // Consumer<HomeViewModel>(
              //   builder: (context, model, child) {
              //     return model.isSearchBarSticky
              //         ? SizedBox()
              //         : Positioned(
              //             right: 13,
              //             top: 6,
              //             child: GestureDetector(
              //               onTap: () {
              //                 Nav.to(context, FavoriteItemview());
              //               },
              //               child: Container(
              //                 color: Colors.transparent,
              //                 height: 40,
              //                 width: 40,
              //               ),
              //             ),
              //           );
              //   },
              // ),

              // Consumer<HomeViewModel>(
              //   builder: (context, model, child) {
              //     return model.isSearchBarSticky
              //         ? SizedBox()
              //         : Positioned(
              //             left: 20,
              //             top: 20,
              //             child: PressableCard(
              //               onTap: () {},
              //               child: Container(
              //                 color: Colors.transparent,
              //                 height: 30,
              //                 width: 260,
              //               ),
              //             ),
              //           );
              //   },
              // ),
            ],
          ),
        ),
      ),
    ),
  );
}








//==========================================================================
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';

// import 'package:food_delivery_app/features/home/home_viewmodel.dart';
// import 'package:provider/provider.dart';
// import 'package:food_delivery_app/config/theme/app_color.dart';
// import 'package:food_delivery_app/config/theme/app_text.dart';
// import 'package:food_delivery_app/core/widgets/custom_searchbar.dart';
// import 'package:food_delivery_app/core/widgets/shimmer_cards.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   double topSpace = 170;
//   double containerOffset = -40;


//   @override
//   void initState() {
//     super.initState();

//     // Animation controller agar kisi child widget me chahiye ho
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );

//     // Pehle frame render hone ke baad animation aur data fetch
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _startContainerAnimation(); // animation har navigation
//       final model = Provider.of<HomeViewModel>(context, listen: false);
//       model.fetchRestaurants(); // data sirf first time load
//     });
//   }

//   // Animation function for container
//   void _startContainerAnimation() {

//     // // Reset values pehle
//     setState(() {
//       topSpace = 170;
//       containerOffset = -40;
//     });

//     Future.delayed(Duration(milliseconds: 200), () {
//       if (mounted) {
//         setState(() {
//           topSpace = 280;
//           containerOffset = -20;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeViewModel>(
//       builder: (context, model, child) {
//         return Container(
//           color: Theme.of(context).primaryColor,
//           child: SafeArea(
//             bottom: false,
//             child: Scaffold(
//               backgroundColor: AppColors.whiteColor,
//               body: Stack(
//                 children: [
//                   /// HEADER
//                   Container(
//                     height: 350,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 10,
//                     ),
//                     color: Theme.of(context).primaryColor,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Top Row: Location + Favorite Icon
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_outlined,
//                               size: 30,
//                               color: Colors.white,
//                             ),
//                             SizedBox(width: 5),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     print("Location tapped");
//                                   },
//                                   child: Text(
//                                     "JJ Public High School",
//                                     style: AppText.titleLarge.copyWith(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: AppColors.topTextColor,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   "Karachi",
//                                   style: AppText.bodyMedium.copyWith(
//                                     color: AppColors.topTextColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Spacer(),
//                             IconButton(
//                               onPressed: () => model.toggleFavorite(),
//                               icon: Icon(
//                                 Icons.favorite_border_outlined,
//                                 size: 30,
//                                 color: AppColors.topTextColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         if (!model.isSearchBarSticky) CustomSearchbar(),
//                         SizedBox(height: 15),
//                         // Welcome text & image
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Welcome back! Enjoy",
//                                     style: AppText.titleLarge.copyWith(
//                                       fontSize: 18,
//                                       color: AppColors.topTextColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     "50% off & free delivery",
//                                     style: AppText.titleLarge.copyWith(
//                                       fontSize: 18,
//                                       color: AppColors.topTextColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.only(bottom: 20),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           "order now",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: AppColors.topTextColor,
//                                           ),
//                                         ),
//                                         SizedBox(width: 5),
//                                         Icon(
//                                           Icons.arrow_circle_right,
//                                           size: 20,
//                                           color: AppColors.topTextColor,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 10),
//                               child: Image.network(
//                                 "https://cdn.pixabay.com/photo/2022/06/26/09/41/chicken-bucket-7284948_1280.png",
//                                 height: 130,
//                                 width: 130,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // / SCROLLABLE CONTENT + WHITE CONTAINER
//                   model.isLoading
//                       ? Container(
//                           margin: EdgeInsets.only(top: 130),
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height: 86,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: 5,
//                                     itemBuilder: (c, i) => TopItemShimmer(),
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 SizedBox(
//                                   height: 105,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: 5,
//                                     itemBuilder: (c, i) =>
//                                         CategoryItemShimmer(),
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 shimmerContainer(),
//                                 SizedBox(height: 20),
//                                 SizedBox(
//                                   height: 235,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: 2,
//                                     itemBuilder: (c, i) =>
//                                         RestaurantCardShimmer(),
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                               ],
//                             ),
//                           ),
//                         )
//                       : 
//                       SingleChildScrollView(
//                           controller: model.scroll,
//                           child: Column(
//                             children: [
//                               AnimatedContainer(
//                                 duration: Duration(milliseconds: 800),
//                                 curve: Curves.easeOut,
//                                 height: topSpace,
//                               ),
//                               AnimatedContainer(
//                                 duration: Duration(milliseconds: 800),
//                                 curve: Curves.easeOut,
//                                 transform: Matrix4.translationValues(
//                                   0,
//                                   containerOffset,
//                                   0,
//                                 ),
//                                 child: Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(20),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(height: 30),
//                                       // Top Items
//                                       SizedBox(
//                                         height: 86,
//                                         child: ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount: model.items.length,
//                                           itemBuilder: (c, i) {
//                                             final item = model.items[i];
//                                             return TopItem(
//                                               title: item["title"].toString(),
//                                               image: item["image"].toString(),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       Divider(color: Colors.grey.shade300),
//                                       SizedBox(height: 20),

//                                       // Categories
//                                       SizedBox(
//                                         height: 105,
//                                         child: ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount:
//                                               model.categoryTitles.length,
//                                           itemBuilder: (c, i) => CategoryItem(
//                                             imageUrl:
//                                                 "https://cdn.pixabay.com/photo/2017/02/15/10/57/pizza-2068272_1280.jpg",
//                                             title: model.categoryTitles[i],
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 20),

//                                       // Carousel Slider
//                                       SizedBox(
//                                         height: 200,
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                           ),
//                                           child: Container(
//                                             height: 230,
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(16),
//                                               color: Colors.grey[300],
//                                             ),
//                                             child: Stack(
//                                               children: [
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(16),
//                                                   child: CarouselSlider(
//                                                     items: model.images
//                                                         .map(
//                                                           (
//                                                             img,
//                                                           ) => Image.network(
//                                                             img,
//                                                             fit: BoxFit.cover,
//                                                             width:
//                                                                 double.infinity,
//                                                           ),
//                                                         )
//                                                         .toList(),
//                                                     options: CarouselOptions(
//                                                       height: 230,
//                                                       autoPlay: true,
//                                                       autoPlayInterval:
//                                                           Duration(seconds: 3),
//                                                       viewportFraction: 1,
//                                                       onPageChanged:
//                                                           (index, reason) {
//                                                             model
//                                                                 .setCurrentIndex(
//                                                                   index,
//                                                                 );
//                                                           },
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   bottom: 15,
//                                                   left: 0,
//                                                   right: 0,
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: List.generate(
//                                                       model.images.length,
//                                                       (index) {
//                                                         bool active =
//                                                             index ==
//                                                             model.current;
//                                                         return AnimatedContainer(
//                                                           duration: Duration(
//                                                             milliseconds: 300,
//                                                           ),
//                                                           margin:
//                                                               EdgeInsets.symmetric(
//                                                                 horizontal: 4,
//                                                               ),
//                                                           width: active
//                                                               ? 30
//                                                               : 10,
//                                                           height: 10,
//                                                           decoration: BoxDecoration(
//                                                             color: Colors.white
//                                                                 .withOpacity(
//                                                                   active
//                                                                       ? 1
//                                                                       : 0.6,
//                                                                 ),
//                                                             borderRadius:
//                                                                 BorderRadius.circular(
//                                                                   20,
//                                                                 ),
//                                                           ),
//                                                         );
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 25),

//                                       // Popular Restaurants
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 "Popular Restaurants",
//                                                 style: AppText.bodyLarge
//                                                     .copyWith(
//                                                       color: Colors.black,
//                                                       fontSize: 20,
//                                                     ),
//                                               ),
//                                             ),
//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color: Colors.white,
//                                                 border: Border.all(
//                                                   color: Colors.grey.shade400,
//                                                   width: 1,
//                                                 ),
//                                               ),
//                                               child: Icon(
//                                                 Icons.chevron_right_outlined,
//                                                 size: 35,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 10),

//                                       // Horizontal Restaurant Cards
//                                       SizedBox(
//                                         height: 235,
//                                         child: ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount:
//                                               model.restaurants.length > 10
//                                               ? 10
//                                               : model.restaurants.length,
//                                           itemBuilder: (c, i) {
//                                             final r = model.restaurants[i];
//                                             return RestaurantCard(
//                                               imageUrl: r.image,
//                                               title: r.name,
//                                               rating: ("${r.rating} (5000+)"),
//                                               time:
//                                                   ("${r.deliveryTime} min • \$\$ • ${r.type}"),
//                                               price:
//                                                   ("From ${r.deliveryFee} With Saver"),
//                                               controller: _controller,
//                                               isFavorite: r.isFav,
//                                               onFavoriteTap: () {
//                                                 model.toggleFavorite();
//                                               },
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       SizedBox(height: 25),
//                                       SizedBox(
//                                         height: 366,
//                                         child: Container(
//                                           height: 60,
//                                           width: double.infinity,
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 Color.fromARGB(
//                                                   255,
//                                                   249,
//                                                   235,
//                                                   243,
//                                                 ), // light pink shade
//                                                 Color.fromARGB(
//                                                   255,
//                                                   255,
//                                                   250,
//                                                   253,
//                                                 ), // very light pink to white
//                                                 Colors.white,
//                                               ],
//                                               begin: Alignment.topCenter,
//                                               end: Alignment.bottomCenter,
//                                             ),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               SizedBox(height: 10),
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 12,
//                                                     ),
//                                                 child: Row(
//                                                   children: [
//                                                     Icon(
//                                                       Icons.local_offer,
//                                                       color: Colors.pink,
//                                                       size: 25,
//                                                     ),
//                                                     SizedBox(width: 5),
//                                                     Text(
//                                                       "Dishes up to 40% off",
//                                                       style: AppText.bodyLarge
//                                                           .copyWith(
//                                                             color: Colors.black,
//                                                           ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),

//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 12,
//                                                     ),
//                                                 child: Text(
//                                                   "Minimum spend applies",
//                                                   style: AppText.bodyMedium
//                                                       .copyWith(
//                                                         color: Colors.black,
//                                                       ),
//                                                 ),
//                                               ),
//                                               SizedBox(height: 10),

//                                               SizedBox(
//                                                 height: 280,
//                                                 child: ListView.builder(
//                                                   scrollDirection:
//                                                       Axis.horizontal,
//                                                   itemCount: 10,
//                                                   itemBuilder: (c, i) {
//                                                     return DisscountRestaurantCard(
//                                                       // yaha ya hardcoded data htao aur database say data lo waha 10 restarants aye gay ok unki image, title, ratting, time, prize, isfav ok randon 10 rest yaha show kar wana ok
//                                                       imageUrl:
//                                                           "https://cdn.pixabay.com/photo/2023/01/01/22/02/burger-7690927_1280.jpg",
//                                                       title: "burger lab",
//                                                       price: 400,
//                                                       Resttitle:
//                                                           "Optp in the town os karachi",
//                                                       oldprize: 800,
//                                                       disscount: "10",
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 25),

//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 "Top Brands",
//                                                 style: AppText.bodyLarge
//                                                     .copyWith(
//                                                       color: Colors.black,
//                                                       fontSize: 20,
//                                                     ),
//                                               ),
//                                             ),

//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color: Colors.white,
//                                                 border: Border.all(
//                                                   color: Colors.grey.shade400,
//                                                   width: 1,
//                                                 ),
//                                               ),
//                                               child: Icon(
//                                                 Icons.arrow_right,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),

//                                       SizedBox(height: 10),

//                                       SizedBox(
//                                         height: 130,
//                                         child: ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount:
//                                               model.restaurantsWithLogo.length,
//                                           itemBuilder: (context, index) {
//                                             final r = model
//                                                 .restaurantsWithLogo[index];
//                                             return TopBrandCard(
//                                               image: r.logo, // Firebase se logo
//                                               name:
//                                                   r.name, // restaurant ka name
//                                               city: "Karachi", // ya r.location
//                                               time: "${r.deliveryTime} min",
//                                             );
//                                           },
//                                         ),
//                                       ),

//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 20,
//                                         ),
//                                         child: Container(
//                                           height: 15,
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                               color: const Color.fromARGB(
//                                                 66,
//                                                 88,
//                                                 88,
//                                                 88,
//                                               ),
//                                             ),
//                                             color: Colors.grey.shade100,
//                                           ),
//                                         ),
//                                       ),

//                                       // SizedBox(height: 25,),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 12,
//                                         ),
//                                         child: Text(
//                                           "Explore",
//                                           style: AppText.bodyLarge.copyWith(
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),

//                                       ListView.builder(
//                                         shrinkWrap: true,
//                                         physics: NeverScrollableScrollPhysics(),
//                                         itemCount: model.restaurants.length,
//                                         itemBuilder: (c, i) {
//                                           final r = model.restaurants[i];
//                                           return RestaurantCardExplore(
//                                             imageUrl: r.image,
//                                             title: r.name,
//                                             rating: r.rating.toString(),
//                                             time: r.deliveryTime,
//                                             price: r.deliveryFee.toString(),
//                                             controller: _controller,
//                                             isFavorite: r.isFav,
//                                             onFavoriteTap: () {
//                                               model.toggleFavorite();
//                                             },
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                   /// STICKY SEARCH BAR when scrolling
//                   AnimatedPositioned(
//                     duration: Duration(milliseconds: 300),
//                     curve: Curves.easeOut,
//                     top: model.isSearchBarSticky ? 0 : -80,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       padding: const EdgeInsets.only(
//                         top: 10,
//                         left: 10,
//                         right: 10,
//                         bottom: 5,
//                       ),
//                       color: Theme.of(context).primaryColor,
//                       child: CustomSearchbar(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
