import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/helpers/navigation_helper.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/restaurant_view_model.dart';
import 'package:food_delivery_app/features/admin_panel/admin_views/CategoriesView.dart';
import 'package:food_delivery_app/features/admin_panel/admin_views/NotificationView.dart';
import 'package:food_delivery_app/features/admin_panel/admin_views/restaurantView.dart';
import 'package:provider/provider.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Nav.to(context, NotificationAdminView());
              },
              icon: Icon(Icons.notifications),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRestaurantView()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Consumer<RestaurantViewModel>(
          builder: (context, vm, _) {
            return StreamBuilder<List>(
              stream: vm.getRestaurants(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final restaurants = snapshot.data!;
                if (restaurants.isEmpty)
                  return const Center(child: Text("No restaurants added"));

                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (_, i) {
                    final r = restaurants[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(r.image),
                        ),
                        title: Text(r.name),
                        subtitle: Text(r.type),
                        trailing: IconButton(
                          icon: const Icon(Icons.category, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddCategoryNameView(restaurantId: r.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
