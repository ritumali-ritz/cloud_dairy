import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import 'view_collections.dart';
import 'view_feed_screen.dart';
import 'view_passbook.dart';
import 'view_bills_screen.dart';
import '../auth/login_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<FarmerProvider>().fetchDashboardData(user['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?['name'] ?? 'Farmer'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               if (user != null) {
                  context.read<FarmerProvider>().fetchDashboardData(user['id']);
               }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                await provider.fetchDashboardData(user['id']);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   _buildBalanceCard(provider.balance, provider.advance),
                   const SizedBox(height: 24),
                   _buildSectionTitle(context, 'Recent Collections', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewCollectionsScreen()));
                   }),
                   const SizedBox(height: 8),
                   _buildRecentCollections(provider.collections),
                   const SizedBox(height: 24),
                   _buildMenuCard(
                    context, 
                    'Messages', 
                    Icons.message, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewFeedScreen())),
                   ),
                   const SizedBox(height: 16),
                   _buildMenuCard(
                    context, 
                    'My Bills', 
                    Icons.receipt, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewBillsScreen())),
                   ),
                   const SizedBox(height: 16),
                   _buildMenuCard(
                    context, 
                    'View Passbook', 
                    Icons.account_balance_wallet, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewPassbookScreen())),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance, double advance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.green.withAlpha(100), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '\u20B9 ${balance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Advance: \u20B9 ${advance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onViewAll, child: const Text('View All')),
      ],
    );
  }

  Widget _buildRecentCollections(List<dynamic> collections) {
    if (collections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent collections found.'),
        ),
      );
    }
    return Column(
      children: collections.map((col) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.water_drop, color: Colors.green),
            ),
            title: Text('${col.qty} Ltr @ \u20B9${col.rate}'),
            subtitle: Text('${col.date.day}/${col.date.month}/${col.date.year} (${col.shift})'),
            trailing: Text(
              '\u20B9${col.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
