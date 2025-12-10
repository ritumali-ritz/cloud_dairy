import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import 'package:intl/intl.dart';

class ViewFeedScreen extends StatefulWidget {
  const ViewFeedScreen({super.key});

  @override
  State<ViewFeedScreen> createState() => _ViewFeedScreenState();
}

class _ViewFeedScreenState extends State<ViewFeedScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<FarmerProvider>().fetchFeeds(user['_id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages & Updates')),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, _) {
          if (provider.feeds.isEmpty) {
             return const Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.feeds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final feed = provider.feeds[index];
              final date = DateTime.tryParse(feed['date']) ?? DateTime.now();
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.green, size: 20),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(date),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feed['message'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
