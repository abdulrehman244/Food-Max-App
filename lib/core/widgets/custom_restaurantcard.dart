// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_delivery_app/config/theme/app_text.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/data/models/restaurant_model.dart';
import 'package:food_delivery_app/features/favorite/favorite_itemview.dart';
import 'package:food_delivery_app/features/home/home_viewmodel.dart';
import 'package:food_delivery_app/features/rest_detail_view/restaurant_detail_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// top line widget

class TopItem extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const TopItem({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(image)),
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              width: 60, // ⭐ wrapping ke liye fixed width zaroori hai
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool hasSpace = title.contains(" ");

                  return Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: hasSpace ? 2 : 1,
                    softWrap: hasSpace, // sirf words wale wrap honge
                    overflow: TextOverflow.visible, // koi dots nahi
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),

            // Text(
            //   title,
            //   textAlign: TextAlign.center,

            //   // ⭐ logic
            //   maxLines: title.contains(" ") ? 2 : 1,

            //   softWrap: title.contains(" "),       // sirf spaced text wrap hoga
            //   overflow: TextOverflow.visible,      // koi dots nahi

            //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            // )
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: AppText.bodyMedium.copyWith(color: Colors.black)),
        ],
      ),
    );
  }
}

// TopBrandCard widget
class TopBrandCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final String? image;
  final String name;
  final String city;
  final String time;

  const TopBrandCard({
    super.key,
    this.image,
    required this.name,
    required this.time,
    required this.city,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Nav.to(context, RestaurantDetailView(restaurant: restaurant));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    offset: const Offset(0, 6), // ↓ shadow bottom side
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ⭐ TEXT WIDTH FIXED TO IMAGE WIDTH
            SizedBox(
              width: 70, // <-- EXACT image width!
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // optional (better UI)
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}



class RestaurantCard extends StatefulWidget {
  final RestaurantModel restaurant;
  final String imageUrl;
  final String title;
  final String rating;
  final String time;
  final String price;
  final double? width;
  final EdgeInsets? padding;
  final Widget? container;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.time,
    required this.price,
    this.width,
    this.padding,
    this.container,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      reverseDuration: const Duration(milliseconds: 100),
    );

    /// 🔥 sync animation with Provider state
    final isFav = context.read<HomeViewModel>().isFavorite(
      widget.restaurant.id,
    );

    if (isFav) {
      _controller.value = 1.0; // already filled
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFavoriteTap() {
    HapticFeedback.vibrate();

    final viewModel = context.read<HomeViewModel>();
    final isFav = viewModel.isFavorite(widget.restaurant.id);

    if (isFav) {
      _controller.reverse();
      _showFavouriteSnackBar(context, "Removed from Favourites");
    } else {
      _controller.forward();

      _showFavouriteSnackBar(context, "Added to Favorites", "View all", () {
        Nav.toAnimated(context, FavoriteItemview());
      });
    }

    viewModel.toggleFavorite(widget.restaurant.id);
  }




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Nav.to(context, RestaurantDetailView(restaurant: widget.restaurant));
      },
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Container(
              height: 160,
              width: widget.width ?? 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _onFavoriteTap,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: Lottie.asset(
                          "assets/lottie/favorite.json",
                          controller: _controller,
                          repeat: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            /// TITLE + RATING
            SizedBox(
              width: widget.width ?? 270,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.titleLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.star, color: Color(0xFFFDCC0D), size: 20),
                  Text(widget.rating),
                ],
              ),
            ),

            const SizedBox(height: 5),
            Text(widget.time),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(FontAwesomeIcons.motorcycle, size: 16),
                const SizedBox(width: 10),
                Text(widget.price),
              ],
            ),

            const SizedBox(height: 15),
            if (widget.container != null) widget.container!,
          ],
        ),
      ),
    );
  }
}

void _showFavouriteSnackBar(
  context,
  String title, [
  String? button,
  VoidCallback? onPressed,
]) {


  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E2E2E),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        content: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),

        action: SnackBarAction(
          label: button ?? "",
          textColor: Colors.white,
          onPressed: onPressed ?? () {},
        ),
      ),
    );
}
