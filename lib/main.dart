import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/config/routes/app_pages.dart';
import 'package:food_delivery_app/config/routes/app_routes.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/core/services/notification_service.dart';
import 'package:food_delivery_app/features/account/account_viewmodel.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/CategoryItemViewModel.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/CategoryViewModel.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/NotificationAdminViewModel.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/restaurant_view_model.dart';
import 'package:food_delivery_app/features/auth/location%20access/location_viewmodel.dart';
import 'package:food_delivery_app/features/auth/login/login_viewmodel.dart';
import 'package:food_delivery_app/features/auth/notification%20access/notification_viewmodel.dart';
import 'package:food_delivery_app/features/cart/cart_viewmodel.dart';
import 'package:food_delivery_app/features/rest_detail_view/restaurant_detail_viewmodel.dart';
import 'package:food_delivery_app/features/search/search_viewmodel.dart';
import 'package:food_delivery_app/features/splash/onboarding/onboarding_viewmodel.dart';
import 'package:food_delivery_app/features/auth/signup/signup_viewmodel.dart';
import 'package:food_delivery_app/features/splash/splash_viewmodel.dart';
import 'package:food_delivery_app/features/theme/theme_viewmodel.dart';
import 'package:food_delivery_app/firebase_options.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';






@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  // 🔥 VERY IMPORTANT
  await NotificationService.initializeNotification(
    requestPermission: false,
  );

  await NotificationService.showSimpleNotification( 
    title: message.notification?.title ?? "Notification",
    body: message.notification?.body ?? "Message",
  );
}







Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 REGISTER BACKGROUND HANDLER (VERY IMPORTANT)
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // 🔔 INIT NOTIFICATION (permission included)
  await NotificationService.initializeNotification(
    requestPermission: false,
  );

  Directory dir = await getApplicationDocumentsDirectory(); 
  Hive.init(dir.path);

  

  await HiveService.init();


  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewmodel()),
        ChangeNotifierProvider(create: (_) => LoginViewmodel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewmodel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RestaurantViewModel()),
        ChangeNotifierProvider(create: (_) => AddCategoryNameViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationAdminViewModel()),
        ChangeNotifierProvider(create: (_) => RestaurantDetailViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => AccountViewmodel()),
        ChangeNotifierProvider(create: (_) => AddCategoryItemViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
       final themeVm = context.watch<ThemeViewModel>();


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
    theme: ThemeData(
        primaryColor: themeVm.appColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeVm.appColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: themeVm.appColor,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themeVm.appColor,
        ),
      ),
   
      // home: AdminPanelView(),
      initialRoute: AppRoutes.splash,
      routes: AppPages.routes,
    );
  }
}













// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:food_delivery_app/config/theme/app_color.dart';
// import 'package:food_delivery_app/config/theme/app_text.dart';
// import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
// import 'package:food_delivery_app/core/widgets/custom_searchbar.dart';
// import 'package:food_delivery_app/core/widgets/shimmer_cards.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView>
//     with SingleTickerProviderStateMixin {
//   final scroll = ScrollController();
//   bool isSearchBarSticky = false;
//   late final AnimationController _controller;
//   bool favorite = false;
//   bool isLoading = false;
//   int current = 0;

//   final items = [
//     {"image": "assets/png_images/discount.png", "title": "Offers"},
//     {"image": "assets/png_images/basket.png", "title": "Mart"},
//     {"image": "assets/png_images/food.png", "title": "New restaurants"},
//     {"image": "assets/png_images/chef-hat.png", "title": "Homechef"},
//     {"image": "assets/png_images/deal.png", "title": "Deals"},
//     {"image": "assets/png_images/delivery-bike.png", "title": "Fast Delivery"},
//   ];

//   final List<String> images = [
//     "https://cdn.pixabay.com/photo/2017/02/15/10/57/pizza-2068272_1280.jpg",
//     "https://cdn.pixabay.com/photo/2014/10/19/20/59/hamburger-494706_1280.jpg",
//     "https://cdn.pixabay.com/photo/2021/12/13/17/59/fast-food-6868812_1280.jpg",
//     "https://cdn.pixabay.com/photo/2017/02/15/10/57/pizza-2068272_1280.jpg",
//     "https://cdn.pixabay.com/photo/2014/10/19/20/59/hamburger-494706_1280.jpg",
//     "https://cdn.pixabay.com/photo/2021/12/13/17/59/fast-food-6868812_1280.jpg",
//   ];

//   double topSpace = 170; // initial height above container
//   double containerOffset = -40; // initial offset

//   List<String> categoryTitles = [
//     "Pizza",
//     "Biryani",
//     "Fast Food",
//     "Burgers",
//     "Halwa Puri",
//     "Pasta",
//     "Chamin",
//     "Soap",
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//       reverseDuration: Duration(milliseconds: 200),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         topSpace = 280;
//         containerOffset = -20;
//       });
//     });

//     scroll.addListener(() {
//       if (scroll.offset > 160 && !isSearchBarSticky) {
//         setState(() => isSearchBarSticky = true);
//       } else if (scroll.offset <= 160 && isSearchBarSticky) {
//         setState(() => isSearchBarSticky = false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     _controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.appColor,
//       child: SafeArea(
//         bottom: false,
//         child: Scaffold(
//           backgroundColor: AppColors.whiteColor,
//           body: Stack(
//             children: [
//               /// HEADER
//               Container(
//                 height: 350,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 10,
//                 ),
//                 color: AppColors.appColor,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Top Row: Location + Favorite Icon
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           size: 30,
//                           color: AppColors.topTextColor,
//                         ),
//                         SizedBox(width: 5),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 print("hellllllloooooo");
//                               },
//                               child: Text(
//                                 "JJ Public High School",
//                                 style: AppText.titleLarge.copyWith(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.topTextColor,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               "Karachi",
//                               style: AppText.bodyMedium.copyWith(
//                                 color: AppColors.topTextColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Spacer(),
//                         IconButton(
//                           onPressed: () {},
//                           icon: Icon(
//                             Icons.favorite_border_outlined,
//                             size: 30,
//                             color: AppColors.topTextColor,
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 20),

//                     // SEARCH BAR (hidden when sticky)
//                     if (!isSearchBarSticky) CustomSearchbar(),

//                     SizedBox(height: 15),

//                     // Welcome text & image
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Welcome back! Enjoy",
//                                 style: AppText.titleLarge.copyWith(
//                                   fontSize: 18,
//                                   color: AppColors.topTextColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 "50% off & free delivery",
//                                 style: AppText.titleLarge.copyWith(
//                                   fontSize: 18,
//                                   color: AppColors.topTextColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 20),
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       "order now",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: AppColors.topTextColor,
//                                       ),
//                                     ),
//                                     SizedBox(width: 5),
//                                     Icon(
//                                       Icons.arrow_circle_right,
//                                       size: 20,
//                                       color: AppColors.topTextColor,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Padding( // yaha kuch nhi karna 
//                           padding: const EdgeInsets.only(top: 10),
//                           child: Image.network(
//                             "https://cdn.pixabay.com/photo/2022/06/26/09/41/chicken-bucket-7284948_1280.png",
//                             height: 130,
//                             width: 130,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               /// SCROLLABLE CONTENT + WHITE CONTAINER
//               isLoading ? 
//               Container(
//                       margin: EdgeInsets.only(top: 150),
//                       padding: EdgeInsets.symmetric(vertical: 20), // adjust based on header
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius:
//                             BorderRadius.vertical(top: Radius.circular(20)),
//                       ),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               height: 86,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 shrinkWrap: true,
//                                 physics: NeverScrollableScrollPhysics(),
//                                 itemCount: 5,
//                                 itemBuilder: (c, i) => TopItemShimmer(),
//                               ),
//                             ),
//                             SizedBox(height: 20),
//                             SizedBox(
//                               height: 105,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 shrinkWrap: true,
//                                 physics: NeverScrollableScrollPhysics(),
//                                 itemCount: 5,
//                                 itemBuilder: (c, i) => CategoryItemShimmer(),
//                               ),
//                             ),
//                             SizedBox(height: 20),
//                             shimmerContainer(), // big shimmer slider
//                             SizedBox(height: 20),
//                             SizedBox(
//                               height: 235,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 shrinkWrap: true,
//                                 physics: NeverScrollableScrollPhysics(),
//                                 itemCount: 2,
//                                 itemBuilder: (c, i) => RestaurantCardShimmer(),
//                               ),
//                             ),
                            
//                             SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ) :
//               SingleChildScrollView(
//                 controller: scroll,
//                 child: Column(
//                   children: [
//                     /// Animated space above container
//                     AnimatedContainer(
//                       duration: Duration(milliseconds: 800),
//                       curve: Curves.easeOut,
//                       height: topSpace,
//                     ),

//                     /// WHITE CONTAINER sliding
//                     AnimatedContainer(
//                       duration: Duration(milliseconds: 800),
//                       curve: Curves.easeOut,
//                       transform: Matrix4.translationValues(
//                         0,
//                         containerOffset,
//                         0,
//                       ),
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(20),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 30),

//                             SizedBox(
//                               height: 86,
//                               child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: items.length,
//                                       itemBuilder: (c, i) {
//                                         final item = items[i];
//                                         // images kyu show nhi ho rahe
//                                         return TopItem(
//                                           title: item["title"].toString(), // yaha kuch nhi karna
//                                           image: item["image"].toString(),
//                                         );
//                                       },
//                                     ),
//                             ),
//                             Divider(color: Colors.grey.shade300),
//                             SizedBox(height: 20),
//                             // first line
//                             SizedBox(
//                               height: 105,
//                               child:  ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: 20,
//                                       itemBuilder: (c, i) {
//                                         return CategoryItem( // yaha kuch nhi karna
//                                           imageUrl:
//                                               "https://cdn.pixabay.com/photo/2017/02/15/10/57/pizza-2068272_1280.jpg",
//                                           title: "Pizza",
//                                         );
//                                       },
//                                     ),
//                             ),
//                             SizedBox(height: 20),
//                             // third line
//                              SizedBox(
//                                     height: 200,
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                       ),
//                                       child: Container(
//                                         height: 230,
//                                         width: double.infinity,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                             16,
//                                           ),
//                                           color: Colors.grey[300],
//                                         ),

//                                         child: Stack(
//                                           children: [
//                                             /// 🔥 IMAGE SLIDER
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(16),
//                                               child: CarouselSlider(
//                                                 items: images
//                                                     .map(
//                                                       (img) => Image.network(
//                                                         img,
//                                                         fit: BoxFit.cover,
//                                                         width: double.infinity, // yaha kuch nhi karna
//                                                       ),
//                                                     )
//                                                     .toList(),
//                                                 options: CarouselOptions(
//                                                   height: 230,
//                                                   autoPlay: true,
//                                                   autoPlayInterval: Duration(
//                                                     seconds: 3,
//                                                   ),
//                                                   viewportFraction: 1,
//                                                   onPageChanged:
//                                                       (index, reason) {
//                                                         setState(
//                                                           () => current = index,
//                                                         );
//                                                       },
//                                                 ),
//                                               ),
//                                             ),

//                                             /// ⭐ DOTS OVERLAY ON IMAGE
//                                             Positioned(
//                                               bottom: 15,
//                                               left: 0,
//                                               right: 0,
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: List.generate(
//                                                   images.length,
//                                                   (index) {
//                                                     bool active =
//                                                         index == current;

//                                                     return AnimatedContainer(
//                                                       duration: Duration(
//                                                         milliseconds: 300,
//                                                       ),
//                                                       margin:
//                                                           EdgeInsets.symmetric(
//                                                             horizontal: 4,
//                                                           ),

//                                                       // ⭐ ACTIVE DOT EXPAND
//                                                       width: active ? 30 : 10,
//                                                       height: 10,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.white
//                                                             .withOpacity(
//                                                               active ? 1 : 0.6,
//                                                             ),
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                               20,
//                                                             ),
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                              SizedBox(height: 25),


//                              Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "Popular Restaurants",
//                                             style: AppText.bodyLarge.copyWith(
//                                               color: Colors.black,
//                                               fontSize: 20,
//                                             ),
//                                           ),
//                                         ),

//                                         Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.white,
//                                             border: Border.all(
//                                               color: Colors.grey.shade400,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           child: Icon(Icons.chevron_right_outlined,size: 35,)
                                         
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                             SizedBox(height: 10),
//                             SizedBox(
//                               height: 235,
//                               child:  
//                               ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: 20,
//                                       itemBuilder: (c, i) {
//                                         return RestaurantCard( // yaha ya hardcoded data htao aur database say data lo waha 10 restarants aye gay ok unki image, title, ratting, time, prize, isfav ok randon 10 rest yaha show kar wana ok  
//                                           imageUrl:
//                                               "https://cdn.pixabay.com/photo/2023/06/02/19/12/ai-generated-8036255_1280.jpg",
//                                           title:
//                                               "AL MADINA FAST FOOD & BBQ TIKKA KARACHI",
//                                           rating: "4.8 (5000+)",
//                                           time: "15-30 min •\$\$• Fast Food",
//                                           price: 149,
//                                           controller: _controller,
//                                           isFavorite: favorite,
//                                           onFavoriteTap: () {
//                                             HapticFeedback.lightImpact();
//                                             if (favorite == false) {
//                                               favorite = true;
//                                               _controller.forward();
//                                             } else {
//                                               favorite = false;
//                                               _controller.reverse();
//                                             }
//                                           },
//                                         );
//                                       },
//                                     ),
//                             ), // is sized box kai neche extra gap kyu hai

//                             SizedBox(height: 25),
//                              Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "Same Taste, Same Prize",
//                                             style: AppText.bodyLarge.copyWith(
//                                               color: Colors.black,
//                                               fontSize: 20,
//                                             ),
//                                           ),
//                                         ),

//                                         Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.white,
//                                             border: Border.all(
//                                               color: Colors.grey.shade400,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           child: Icon(
//                                             Icons.chevron_right_outlined,
//                                             size: 35,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                             SizedBox(height: 10),
//                             SizedBox(
//                               height: 235,
//                               child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: 20,
//                                       itemBuilder: (c, i) {
//                                         return RestaurantCard( // yaha ya hardcoded data htao aur database say data lo waha 10 restarants aye gay ok unki image, title, ratting, time, prize, isfav ok randon 10 rest yaha show kar wana ok 
//                                           imageUrl:
//                                               "https://cdn.pixabay.com/photo/2018/05/30/19/18/burger-3442227_1280.jpg",
//                                           title:
//                                               "AL MADINA FAST FOOD & BBQ TIKKA KARACHI",
//                                           rating: "4.8 (5000+)",
//                                           time: "15-30 min •\$\$• Fast Food",
//                                           price: 149,
//                                           controller: _controller,
//                                           isFavorite: favorite,
//                                           onFavoriteTap: () {
//                                             if (favorite == false) {
//                                               favorite = true;
//                                               _controller.forward();
//                                             } else {
//                                               favorite = false;
//                                               _controller.reverse();
//                                             }
//                                           },
//                                         );
//                                       },
//                                     ),
//                             ),
//                             SizedBox(height: 25),

//                             // fivth line
//                             SizedBox(
//                               height: 366,
//                               child: Container(
//                                       height: 60,
//                                       width: double.infinity,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             Color.fromARGB(255, 249, 235, 243), // light pink shade
//                                             Color.fromARGB(
//                                               255,
//                                               255,
//                                               250,
//                                               253,
//                                             ), // very light pink to white
//                                             Colors.white,
//                                           ],
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomCenter,
//                                         ),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           SizedBox(height: 10,),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 12,
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.local_offer,
//                                                   color: Colors.pink,
//                                                   size: 25,
//                                                 ),
//                                                 SizedBox(width: 5),
//                                                 Text(
//                                                   "Dishes up to 40% off",
//                                                   style: AppText.bodyLarge
//                                                       .copyWith(
//                                                         color: Colors.black,
//                                                       ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),

//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 12,
//                                             ),
//                                             child: Text(
//                                               "Minimum spend applies",
//                                               style: AppText.bodyMedium
//                                                   .copyWith(
//                                                     color: Colors.black,
//                                                   ),
//                                             ),
//                                           ),
//                                           SizedBox(height: 10),

//                                           SizedBox(
//                                             height: 280,
//                                             child: ListView.builder(
//                                               scrollDirection: Axis.horizontal,
//                                               itemCount: 10,
//                                               itemBuilder: (c, i) {
//                                                 return DisscountRestaurantCard(  // yaha ya hardcoded data htao aur database say data lo waha 10 restarants aye gay ok unki image, title, ratting, time, prize, isfav ok randon 10 rest yaha show kar wana ok 
//                                                   imageUrl:
//                                                       "https://cdn.pixabay.com/photo/2023/01/01/22/02/burger-7690927_1280.jpg",
//                                                   title: "burger lab",
//                                                   price: 400,
//                                                   Resttitle:
//                                                       "Optp in the town os karachi",
//                                                   oldprize: 800,
//                                                   disscount: "10",
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                             ),
//                            SizedBox(height: 25),
//                             Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "Top Brands",
//                                             style: AppText.bodyLarge.copyWith(
//                                               color: Colors.black,
//                                               fontSize: 20,
//                                             ),
//                                           ),
//                                         ),

//                                         Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.white,
//                                             border: Border.all(
//                                               color: Colors.grey.shade400,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           child: Icon(
//                                             Icons.arrow_right,
//                                             size: 20,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                             SizedBox(height: 10),
//                             SizedBox(
//                               height: 120,
//                               child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: 4,
//                                       itemBuilder: (c, i) {
//                                         return TopBrandCard( // serif jis rest kai mai logo image ho uske logo  aur rest ka name title show karna ok city time ko hard coded chor do maine database mai 30 restaurant add kiya hai unme sai kuch mai logo hai tou jin mai logo hai unka logo aur title yaha show kar karna ok
//                                           image:
//                                               "https://images.deliveryhero.io/image/fd-pk/pk-logos/ck1as-logo.jpg",
//                                           name: "Pizza Max",
//                                           city: "Karachi",
//                                           time: "10-20 min",
//                                         );
//                                       },
//                                     ),
//                             ),

//                              Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 20,
//                                     ),
//                                     child: Container(
//                                       height: 15,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: const Color.fromARGB(
//                                             66,
//                                             88,
//                                             88,
//                                             88,
//                                           ),
//                                         ),
//                                         color: Colors.grey.shade100,
//                                       ),
//                                     ),
//                                   ),

//                             // SizedBox(height: 25,),
//                              Padding(
//                                     padding: const EdgeInsets.only(left: 12),
//                                     child: Text(
//                                       "Explore",
//                                       style: AppText.bodyLarge.copyWith(
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),

//                              ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: 20,
//                                     itemBuilder: (c, i) {
//                                       return RestaurantCardExplore( // yaha par purai 30 restaurant show karwa do data base sai  ok jitne hi sarai ok
//                                         imageUrl:
//                                             "https://cdn.pixabay.com/photo/2017/01/03/11/33/pizza-1949183_1280.jpg",
//                                         title:
//                                             "Pizza lab north karachi pakistan",
//                                         rating: "4.8 (5000+)",
//                                         time: "15-30 min •\$\$• Fast Food",
//                                         price: 149,
//                                         controller: _controller,
//                                         isFavorite: favorite,
//                                         onFavoriteTap: () {
//                                           if (favorite == false) {
//                                             favorite = true;
//                                             _controller.forward();
//                                           } else {
//                                             favorite = false;
//                                             _controller.reverse();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               /// STICKY SEARCH BAR when scrolling (smooth animation)
//               AnimatedPositioned(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeOut,
//                 top: isSearchBarSticky
//                     ? 0
//                     : -80, // adjust -80 to match search bar height
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.only(
//                     top: 10,
//                     left: 10,
//                     right: 10,
//                     bottom: 5,
//                   ),
//                   color: AppColors.appColor,
//                   child: CustomSearchbar(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








































