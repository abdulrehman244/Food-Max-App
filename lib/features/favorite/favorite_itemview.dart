import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FavoriteItemview extends StatefulWidget {
  const FavoriteItemview({super.key});

  @override
  State<FavoriteItemview> createState() => _FavoriteItemviewState();

  
}



class _FavoriteItemviewState extends State<FavoriteItemview> {

  @override
  void initState() {
    super.initState();

    
    Future.microtask(() {
      context.read<HomeViewModel>().syncFavoritesWithFirestore();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child:Divider(thickness: 0.7,height: 0,color: Colors.grey.shade400,endIndent: 0,indent: 0,)
          ),
        titleSpacing: 0,
        title: Text(
          "Favorite Restaurant",
          style: AppText.bodyLarge.copyWith(color: Colors.black, fontSize: 20),
        ),
      ),
     
     
     
     
     
     
      body: Consumer<HomeViewModel>(
        builder: (context, model, child) {
          final favRestaurants = model.restaurants
              .where((r) => model.favoriteIds.contains(r.id))
              .toList();

          if (favRestaurants.isEmpty) {
            // Material widget add karna Center ke liye
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.grey, size: 100),
                    SizedBox(height: 20),
                    Text(
                      "No Favorites saved",
                      style: AppText.titleLarge.copyWith(color: Colors.black),
                    ),
                    Text(
                      "To make ordering even faster, you'll find all your faves here. Just look for the heart icon!",
                      textAlign: TextAlign.center,
                      style: AppText.bodyMedium.copyWith(color: Colors.black,fontSize: 13),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: MyButton(
                        title: "Let's find some favorites",
                        ontap: () {
                          Nav.back(context);
                        },
                        textStyle: AppText.bodyLarge.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ListView ke liye bhi Material wrapper
          return  
          model.favSyncLoading ? 
          Center(child: Lottie.asset("assets/lottie/search_load.json"))
          :
          ListView.builder(
            itemCount: favRestaurants.length,
            itemBuilder: (context, index) {
              final r = favRestaurants[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: RestaurantCard(
                  key: ValueKey("${r.id}_favorite"),
                  width: double.infinity,
                  restaurant: r,
                  imageUrl: r.image,
                  title: r.name,
                  rating: ("${r.rating} (5000+)"),
                  time: ("${r.deliveryTime} min • \$\$ • ${r.type}"),
                  price: ("From ${r.deliveryFee} With Saver"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
