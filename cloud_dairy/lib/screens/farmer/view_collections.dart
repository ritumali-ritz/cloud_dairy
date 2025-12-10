import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farmer_provider.dart';

class ViewCollectionsScreen extends StatelessWidget {
  const ViewCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Collections')),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, _) {
          if (provider.collections.isEmpty) {
             return const Center(child: Text('No collections found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.collections.length,
            itemBuilder: (context, index) {
              final col = provider.collections[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${col.date.day}/${col.date.month}/${col.date.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: col.shift == 'Morning' ? Colors.orange[100] : Colors.blue[100],
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(col.shift, style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn('Qty', '${col.qty} L'),
                          _buildInfoColumn('Fat', '${col.fat}'),
                          _buildInfoColumn('SNF', '${col.snf}'),
                          _buildInfoColumn('Rate', '\u20B9${col.rate}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(color: Colors.green)),
                            Text(
                              '\u20B9${col.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                            ),
                          ],
                        ),
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

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
