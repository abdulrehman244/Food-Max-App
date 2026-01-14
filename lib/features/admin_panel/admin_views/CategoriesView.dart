import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/CategoryViewModel.dart';
import 'package:food_delivery_app/features/admin_panel/admin_views/CategoryItemsView.dart';
import 'package:provider/provider.dart';

class AddCategoryNameView extends StatelessWidget {
  final String restaurantId;
  const AddCategoryNameView({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddCategoryNameViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Categories")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              vm.categoryName.clear();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Add Category"),
                  content: TextField(
                    controller: vm.categoryName,
                    decoration: const InputDecoration(labelText: "Category Name"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        vm.addCategory(restaurantId);
                        Navigator.pop(context);
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder(
            stream: vm.getCategories(restaurantId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    
              final categories = snapshot.data!;
              if (categories.isEmpty) return const Center(child: Text("No categories"));
    
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  return ListTile(
                    title: Text(cat.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            vm.categoryName.text = cat.name;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Edit Category"),
                                content: TextField(
                                  controller: vm.categoryName,
                                  decoration: const InputDecoration(labelText: "Category Name"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      vm.updateCategory(restaurantId, cat.id, vm.categoryName.text);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Update"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            vm.deleteCategory(restaurantId, cat.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddCategoryItemView(
                            restaurantId: restaurantId,
                            categoryId: cat.id,
                            categoryName: cat.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
