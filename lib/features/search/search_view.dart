import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final controller = TextEditingController();


  final hiveService = HiveService();
List<Map<String, dynamic>> restaurants = HiveService().getRestaurants();



  final List<String> popularSearches = const [
    "pizza",
    "kababjees bakers",
    "california",
    "ice cream",
    "burger king",
    "burger",
    "pizza hut",
    "kababjees",
  ];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        title: 
            SearchBarWidget(controller),
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: 
          controller.text.isNotEmpty ? 
          ListView.builder(
  itemCount: restaurants.length,
  itemBuilder: (context, index) {
    final restaurant = restaurants[index];
    return ListTile(
      title: Text(restaurant['name'] ?? 'No Name'),
      subtitle: Text(restaurant['location'] ?? 'No Location'),
      leading: Image.network(restaurant['image'] ?? ''),
    );
  },
)

          :
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Show recent searches if search bar is empty
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent searches",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 20),
                  const Text(
                    "Popular searches",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: popularSearches.map((item) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            item,
                            style: AppText.bodyMedium.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Show search results
              SizedBox(height: 30),

              Text(
                "Top Brands",
                style: AppText.bodyLarge.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 15),

              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: model.restaurantsWithLogo.length,
                  itemBuilder: (context, index) {
                    final r = model.restaurantsWithLogo[index];
                    return TopBrandCard(
                      restaurant: r,
                      image: r.logo, // Firebase se logo
                      name: r.name, // restaurant ka name
                      city: "Karachi", // ya r.location
                      time: "${r.deliveryTime} min",
                    );
                  },
                ),
              ),

              // _SearchTile(title: "burder", subtitle: "in restaurant", icon: Icons.restaurant),
            ],
          ),
        ),
      ),
    );
  }
}



Widget SearchBarWidget(TextEditingController controller, [bool isLoading = false]) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                enabled: true,
                controller: controller,
                onChanged: (val) {},
                decoration: InputDecoration(
                  suffixIcon:  isLoading ? null : Lottie.asset(
                    "assets/lottie/search_load.json",
                    height: 50,
                    width: 50,
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  hintText: "search",
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: AppText.bodyMedium.copyWith(color: Colors.grey.shade800),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}




class _SearchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? boldPart;

  const _SearchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.boldPart,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      onTap: () {},
    );
  }
}
