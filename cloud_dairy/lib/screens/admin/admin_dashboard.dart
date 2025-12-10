import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'manage_farmers.dart';
import 'add_collection.dart';
import 'add_collection.dart';
import 'rate_chart_screen.dart';
import 'send_feed_screen.dart';
import 'banking_screen.dart';
import 'generate_bill_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Manage Farmers',
                    Icons.people,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageFarmersScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    'Milk Collection',
                    Icons.add_circle,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCollectionScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    'Feed Updates',
                    Icons.message,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendFeedScreen())),
                  ),
                  _buildMenuCard(
                    context, 
                    'Rate Chart', 
                    Icons.table_chart, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RateChartScreen()))
                  ),
                  _buildMenuCard(
                    context,
                    'Banking',
                    Icons.account_balance,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankingScreen())),
                  ),
                  _buildMenuCard(
                    context, 
                    'Cycle Billing', 
                    Icons.receipt_long, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerateBillScreen()))
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(76), // 0.3 * 255 ~= 76
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Collection',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                '0.00 L',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(Icons.water_drop, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
