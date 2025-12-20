import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/widgets/custom_textFiled.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/CategoryItemViewModel.dart';
import 'package:provider/provider.dart';

class AddCategoryItemView extends StatelessWidget {
  final String restaurantId;
  final String categoryId;
  final String categoryName;

  const AddCategoryItemView({
    super.key,
    required this.restaurantId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AddCategoryItemViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: Text(categoryName)),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Add Item"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: vm.itemImage.text.isNotEmpty
                              ? Image.network(vm.itemImage.text, fit: BoxFit.cover)
                              : const Center(child: Text("Image Preview")),
                        ),
                        CustomTextField(controller: vm.itemImage, labelText: "Image URL"),
                        CustomTextField(controller: vm.itemName, labelText: "Item Name"),
                        CustomTextField(controller: vm.itemPrice, labelText: "Price"),
                        CustomTextField(controller: vm.itemDescription, labelText: "Description"),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        vm.addItem(restaurantId, categoryId);
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
          body: StreamBuilder<List>(
            stream: vm.getItemsStream(restaurantId, categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data!;
              if (items.isEmpty) return const Center(child: Text("No items added"));
    
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item.name),
                    subtitle: Text("${item.price} PKR\n${item.description}"),
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
