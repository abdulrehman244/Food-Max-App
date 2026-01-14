import 'package:flutter/material.dart';
import 'package:food_delivery_app/core/widgets/custom_textFiled.dart';
import 'package:food_delivery_app/data/models/CategoryItemModel.dart';
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
              vm.itemName.clear();
              vm.itemPrice.clear();
              vm.itemDescription.clear();
              vm.itemImage.clear();
              vm.itemOldPrice.clear();
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
                              ? Image.network(
                                  vm.itemImage.text,
                                  fit: BoxFit.cover,
                                )
                              : const Center(child: Text("Image Preview")),
                        ),
                        CustomTextField(
                          controller: vm.itemImage,
                          labelText: "Image URL",
                        ),
                        CustomTextField(
                          controller: vm.itemName,
                          labelText: "Item Name",
                        ),
                        CustomTextField(
                          controller: vm.itemPrice,
                          labelText: "Price",
                        ),
                        CustomTextField(
                          controller: vm.itemOldPrice,
                          labelText: "Old Price (optional)",
                        ),
                        CustomTextField(
                          controller: vm.itemDescription,
                          labelText: "Description",
                        ),
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
          body: StreamBuilder<List<CategoryItemModel>>(
            stream: vm.getItemsStream(restaurantId, categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;
              if (items.isEmpty) {
                return const Center(child: Text("No items added"));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.oldPrice != null)
                          Text(
                            "${item.oldPrice} PKR",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        Text("${item.price} PKR"),
                        Text(item.description),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            vm.itemName.text = item.name;
                            vm.itemPrice.text = item.price.toString();
                            vm.itemDescription.text = item.description;
                            vm.itemImage.text = item.image;
                            vm.itemOldPrice.text =
                                item.oldPrice?.toString() ?? '';
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Edit Item"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: double.infinity,
                                        color: Colors.grey.shade300,
                                        child: vm.itemImage.text.isNotEmpty
                                            ? Image.network(
                                                vm.itemImage.text,
                                                fit: BoxFit.cover,
                                              )
                                            : const Center(
                                                child: Text("Image Preview"),
                                              ),
                                      ),
                                      CustomTextField(
                                        controller: vm.itemImage,
                                        labelText: "Image URL",
                                      ),
                                      CustomTextField(
                                        controller: vm.itemName,
                                        labelText: "Item Name",
                                      ),
                                      CustomTextField(
                                        controller: vm.itemPrice,
                                        labelText: "Price",
                                      ),
                                      CustomTextField(
                                        controller: vm.itemOldPrice,
                                        labelText: "Old Price (optional)",
                                      ),
                                      CustomTextField(
                                        controller: vm.itemDescription,
                                        labelText: "Description",
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      vm.updateItem(
                                        restaurantId,
                                        categoryId,
                                        item.id,
                                        {
                                          'name': vm.itemName.text,
                                          'price':
                                              double.tryParse(
                                                vm.itemPrice.text,
                                              ) ??
                                              0,
                                          if (vm.itemOldPrice.text.isNotEmpty)
                                            'oldPrice': double.tryParse(
                                              vm.itemOldPrice.text,
                                            ),
                                          'description':
                                              vm.itemDescription.text,
                                          'image': vm.itemImage.text,
                                          'restaurantId': restaurantId,
                                          'categoryId': categoryId,
                                        },
                                      );
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
                            vm.deleteItem(restaurantId, categoryId, item.id);
                          },
                        ),
                      ],
                    ),
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
