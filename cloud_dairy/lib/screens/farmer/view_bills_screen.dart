import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import 'package:intl/intl.dart';

class ViewBillsScreen extends StatefulWidget {
  const ViewBillsScreen({super.key});

  @override
  State<ViewBillsScreen> createState() => _ViewBillsScreenState();
}

class _ViewBillsScreenState extends State<ViewBillsScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<FarmerProvider>().fetchBills(user['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bills')),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, _) {
          if (provider.bills.isEmpty) {
             return const Center(child: Text('No bills generated yet', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.bills.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bill = provider.bills[index];
              final start = DateTime.parse(bill['startDate']);
              final end = DateTime.parse(bill['endDate']);
              final total = (bill['netPayable'] ?? 0).toDouble();
              
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cycle ${bill['cycleNumber']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '\u20B9 ${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}'),
                          Text('${(bill['totalMilk']??0).toStringAsFixed(1)} Ltr'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Avg Rate: \u20B9${(bill['avgRate']??0).toStringAsFixed(2)}'),
                          if (bill['deductions'] > 0)
                            Text('Ded: \u20B9${bill['deductions']}', style: const TextStyle(color: Colors.red)),
                        ],
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
