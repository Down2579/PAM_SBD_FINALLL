import 'package:flutter/material.dart';
import '../notification_provider.dart';
import 'package:provider/provider.dart';

Future<void> showNotificationsModal(BuildContext context, {List<String>? notifications}) {
  final provider = Provider.of<NotificationProvider>(context, listen: false);
  final items = notifications ?? provider.notifications;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Consumer<NotificationProvider>(
        builder: (context, notifProvider, _) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (notifProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(t),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    // When the modal closes, reset unread count
    provider.reset();
  });
}
