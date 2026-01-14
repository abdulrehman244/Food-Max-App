import 'package:flutter/material.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/widgets/custom_restaurantcard.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/features/search/search_viewmodel.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final List<String> popularSearches = const [
    "pizza",
    "kababjees",
    "burger",
    "pizza hut",
    "ice cream",
    "California pizza",
    "Kababjees Bakers",
    "Burger Lab",
  ];

  @override
  void initState() {
    super.initState();

    /// 🔥 load Hive data ONLY ONCE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadFromHive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchVM = context.watch<SearchViewModel>();
    final homeVM = context.watch<HomeViewModel>();

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: searchVM.controller.text.isNotEmpty
                    ? GestureDetector(
                        key: const ValueKey("back"),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          searchVM.backButton();
                        },
                        child: const Icon(Icons.arrow_back),
                      )
                    : const SizedBox(key: ValueKey("empty"), width: 0),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: searchVM.controller.text.isNotEmpty ? 12 : 0,
              ),

              /// 🔍 SEARCH FIELD
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      controller: searchVM.controller,
                      onSubmitted: (_) => searchVM.openFilteredScreen(context),
                      decoration: InputDecoration(
                        hintText: 'Search by restaurant or item...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        suffixIcon: searchVM.isLoading
                            ? Lottie.asset(
                                "assets/lottie/search_load.json",
                                height: 50,
                                width: 50,
                              )
                            : GestureDetector(
                                onTap: () => searchVM.backButton(),
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  size: 22,
                                ),
                              ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: searchVM.controller.text.isEmpty
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (searchVM.recentSearches.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 15),
                      child: Text(
                        "Recent searches",
                        style: AppText.bodyLarge.copyWith(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchVM.recentSearches.length,
                      itemBuilder: (context, index) {
                        final item = searchVM.recentSearches[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(item),
                          trailing: IconButton(
                            onPressed: () {
                              searchVM.removeRecentItem(item);
                            },
                            icon: Icon(Icons.close),
                          ),
                          onTap: () {
                            searchVM.selectRestaurantSuggestion(context, item,searchVM.filtered);
                          },
                        );
                      },
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 15),
                    child: Text(
                      "Popular searches",
                      style: AppText.bodyLarge.copyWith(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: popularSearches.map((item) {
                        return GestureDetector(
                          onTap: () {
                            searchVM.onPopularTap(item, context);
                          },
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
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Top Brands",
                      style: AppText.bodyLarge.copyWith(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: homeVM.restaurantsWithLogo.length,
                      itemBuilder: (context, index) {
                        final r = homeVM.restaurantsWithLogo[index];
                        return TopBrandCard(
                          restaurant: r,
                          image: r.logo,
                          name: r.name,
                          city: "Karachi",
                          time: "${r.deliveryTime} min",
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: searchVM.filtered.length,
              itemBuilder: (context, index) {
                final restaurant = searchVM.filtered[index];

                return _SearchTile(
                  title: restaurant['name'] ?? 'Unknown',
                  subtitle: Text(
                    restaurant['categories'] != null
                        ? (restaurant['categories'] as List)
                              .map((c) => c['title'])
                              .join(', ')
                        : '',
                  ),
                  icon: Icons.restaurant,
                  searchQuery: searchVM.query,
                  onPressed: () {
                    searchVM.selectRestaurantSuggestion(
                      context,
                      restaurant['name'] ?? '',
                      searchVM.filtered, // 🔹 current suggestions pass karo
                    );
                  },
                );
              },
            ),
    );
  }
}




class _SearchTile extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final String? searchQuery; // 🔥 yahan query bhejenge

  const _SearchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.searchQuery,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final lowerTitle = title.toLowerCase();
    final lowerQuery = searchQuery?.toLowerCase() ?? '';

    List<TextSpan> spans = [];

    if (lowerQuery.isNotEmpty && lowerTitle.contains(lowerQuery)) {
      int start = lowerTitle.indexOf(lowerQuery);
      int end = start + lowerQuery.length;

      // Before match
      if (start > 0) {
        spans.add(TextSpan(text: title.substring(0, start)));
      }
      // Match (bold)
      spans.add(TextSpan(text: title.substring(start, end)));
      // After match
      if (end < title.length) {
        spans.add(
          TextSpan(
            text: title.substring(end),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
    } else {
      spans.add(TextSpan(text: title));
    }

    return ListTile(
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey.shade600),
      ),
      title: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: spans,
        ),
      ),
      subtitle: subtitle,
      onTap: onPressed,
    );
  }
}
