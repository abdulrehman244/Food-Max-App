import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/admin_panel/admin_viewmodels/NotificationAdminViewModel.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';

class NotificationAdminView extends StatelessWidget {
  const NotificationAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NotificationAdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Global Notification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: model.titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: model.bodyController,
              decoration: const InputDecoration(
                labelText: "Body",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            model.loading
                ? const CircularProgressIndicator()
                : MyButton(
                    title: "Send",
                    ontap: () async {
                      await model.sendNotificationToAllUsers();
                      if (!model.loading) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Notification sent!")),
                        );
                        model.clearFields();
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
