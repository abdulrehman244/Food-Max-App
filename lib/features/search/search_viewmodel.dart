import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/core/services/hive_service.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:provider/provider.dart';

class SearchViewModel extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> filtered = [];

  /// 🆕 ADDED: recent searches list
  List<String> recentSearches = [];

  String query = "";
  bool isLoading = false;
  late String t;

  SearchViewModel() {
    controller.addListener(_search);
  }

  void removeRecentItem(String item) async {
    await _hiveService.removeRecentSearch(item); // HiveService method
    loadRecentSearches(); // UI update
  }

  /// 🆕 ADDED: load recent searches from Hive
  void loadRecentSearches() {
    recentSearches = _hiveService.getRecentSearches();
    notifyListeners();
  }

  void onPopularTap(String text, BuildContext context) {
    controller.text = text; // 1️⃣ text fill
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    ); // cursor end par

    query = text;

    /// 🆕 ADDED: save to recent searches
    _hiveService.addRecentSearch(text);
    loadRecentSearches();

    FocusManager.instance.primaryFocus?.unfocus(); // keyboard close (optional)

    _search(); // 2️⃣ search logic trigger
    openFilteredScreen(context); // 3️⃣ enter / navigate
  }

  void loadFromHive() {
    _all = _hiveService.getRestaurants();

    /// 🆕 ADDED
    loadRecentSearches();

    notifyListeners();
  }

  void selectRestaurantSuggestion(
    BuildContext context,
    String restaurantName,
    List<Map<String, dynamic>> currentSuggestions, // 🔥 pass karo
  ) {
    // 1️⃣ TextField update
    controller.text = restaurantName;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    // 2️⃣ Save recent search
    _hiveService.addRecentSearch(restaurantName);
    loadRecentSearches();

    // 3️⃣ Use current suggestions as filtered list
    filtered = currentSuggestions;
    _search();

    // 4️⃣ Navigate
    openFilteredScreen(context);
  }

  void _search() {
    query = controller.text.trim().toLowerCase();

    if (query.isEmpty) {
      filtered = [];
      notifyListeners();
      return;
    } else {
      filtered = _all.where((restaurant) {
        final name = (restaurant['name'] ?? '').toString().toLowerCase();
        if (name.contains(query)) return true;

        final categories =
            restaurant['categories'] ?? restaurant['categoryList'] ?? [];
        if (categories is! List) return false;

        for (var cat in categories) {
          final items = cat['items'] ?? cat['categoryItemList'] ?? [];
          if (items is! List) continue;

          for (var item in items) {
            final itemName = (item['name'] ?? item['itemName'] ?? '')
                .toString()
                .toLowerCase();
            if (itemName.contains(query)) return true;
          }
        }

        return false;
      }).toList();
    }

    notifyListeners();
  }

  void backButton() {
    controller.clear();
    filtered = [];
    notifyListeners();
  }

  void clearSearch() {
    controller.clear();
    filtered = _all;
    notifyListeners();
  }

  void openFilteredScreen(BuildContext context) {
    /// 🆕 ADDED: save typed search when navigating
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      _hiveService.addRecentSearch(text);
      loadRecentSearches();
    }

    final filteredList = filtered
        .map((e) => RestaurantModel.fromMap(e, e['id'] ?? ''))
        .toList();

    Nav.toAnimated(
      context,
      FilteredRestaurantsScreen(filteredRestaurants: filteredList),
    );
  
  }
}

class FilteredRestaurantsScreen extends StatelessWidget {
  final List<RestaurantModel> filteredRestaurants;

  const FilteredRestaurantsScreen({
    super.key,
    required this.filteredRestaurants,
  });

  @override
  Widget build(BuildContext context) {
    final searchVM = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              /// 🔙 BACK ARROW
              InkWell(
                onTap: () {
                  Nav.back(context);
                  searchVM.controller.clear();
                },
                child: Icon(Icons.arrow_back),
              ),
              SizedBox(width: 10),

              /// 🔍 SEARCH FIELD
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    onTap: () {
                      Nav.back(context);
                    },
                    controller: searchVM.controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Divider(
            color: Colors.grey.shade400,
            height: 0,
            thickness: 0.7,
            endIndent: 0,
            indent: 0,
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          // 🔹 Header Text
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
              child: Text(
                "\"${searchVM.controller.text.trim()}\" Search result",
                style: AppText.titleLarge.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // 🔹 List of Restaurants
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final r = filteredRestaurants[index];
              return RestaurantCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                width: double.infinity,
                imageUrl: r.image,
                title: r.name,
                rating: "${r.rating} (5000+)",
                time: "${r.deliveryTime} min • \$\$ • ${r.type}",
                price: "From ${r.deliveryFee} With Saver",
                restaurant: r,
              );
            }, childCount: filteredRestaurants.length),
          ),
        ],
      ),
    );
  }
}
