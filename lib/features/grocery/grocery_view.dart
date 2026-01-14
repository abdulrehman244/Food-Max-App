import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/widgets/custom_searchbar.dart';
import 'package:food_delivery_app/features/favorite/favorite_itemview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class GroceryView extends StatelessWidget {
  const GroceryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        // ignore: deprecated_member_use
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Consumer<HomeViewModel>(
            builder: (context, homeVm, child) => 
             Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 130,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Location + Favorite Icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
         
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 250,
                                    child: Text(
                                       homeVm.userAddress.isEmpty ? "loading address....":homeVm.userAddress,
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
                                    "${homeVm.userCity}, Pakistan",
                                    style: AppText.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              Nav.to(context, FavoriteItemview());
                            },
                            icon: Icon(
                              Icons.favorite_border_outlined,
                              size: 30,
                              color:Colors.white,
                            ),
                          ),
                        ],
                      ),
            
                      SizedBox(height: 20),
            
                      // SEARCH BAR (hidden when sticky)
                      CustomSearchbar(),
                    ],
                  ),
                ),
            
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: SingleChildScrollView(
                        // physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 11,left: 11, top: 25),
                              child: Image.asset("assets/png_images/grocery_1.png"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "Popular Shops",
                                style: AppText.bodyLarge.copyWith(
                                  color: Colors.black,
                                  fontSize: 25,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11),
                              child: Image.asset(
                                "assets/png_images/grocery_2.png",
                                height: 200,
                                width: 200,
                              ),
                            ),
                            Text(
                              "Explore Grocery",
                              style: AppText.bodyLarge.copyWith(
                                color: Colors.black,
                                fontSize: 25,
                              ),
                            ),
                            SizedBox(height: 20),
                        
                            grocerycard("https://nazarjanssupermarket.com/cdn/shop/files/OLPER_SFULLCREAMMILK1LTR.png?v=1730118136", 
                            "Rs. 340.40", 
                            "Olper's full cream milk 1000ml"),
                            grocerycard("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRj-cSwNz9NzC3OiovMynNg5mZsc7UvwCsmew&s", 
                            "200.30", 
                            "brightfarms Fresh Eggs 6 Pieces"),
                            grocerycard("https://nazarjanssupermarket.com/cdn/shop/files/MezanCanolaCookingOil4.5Ltr.png?v=1722945482", 
                            "1400.10", 
                            "Meezan Cooking Oil"),
                            grocerycard("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq6eIYQMYYQXsV3W3-_8cG2MGnhetMiDS_Bg&s", 
                            "634.80", 
                            "brightfarms Fresh Chicken 50kg"),
                            grocerycard("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3lh0yNDsnxbGZO3bpPiwYpC7DrqqUANcSyQ&s", 
                            "80.00", 
                            "brightfarms Fresh Potatoes"),
                        
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget grocerycard(String image,String prize, String description) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, bottom: 20),
    child: Row(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300,width: 1),
            image: DecorationImage(
              image: NetworkImage(
                image,
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rs. $prize",
              style: AppText.titleLarge.copyWith(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            Text(
              description,
              style: AppText.bodyMedium.copyWith(color: Colors.black),
            ),
          ],
        ),
      ],
    ),
  );
}
