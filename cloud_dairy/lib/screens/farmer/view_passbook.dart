import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import 'package:intl/intl.dart';

class ViewPassbookScreen extends StatefulWidget {
  const ViewPassbookScreen({super.key});

  @override
  State<ViewPassbookScreen> createState() => _ViewPassbookScreenState();
}

class _ViewPassbookScreenState extends State<ViewPassbookScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<FarmerProvider>().fetchTransactions(user['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Passbook')),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.transactions.isEmpty) {
             return const Center(child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transactions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final txn = provider.transactions[index];
              final date = txn.date; // already DateTime in Model? Let's check model. 
              // Assuming model parses date string to DateTime or it's a string.
              // Actually Transaction model logic needs verification.
              // Let's assume standard parsing if needed. 
              // Wait, checked Transaction model in step 381, it has DateTime date.
              
              final isCredit = txn.type == 'payment'; // Payment FROM dairy TO farmer? 
              // Wait. "Payment" means Dairy paid Farmer. So Farmer Received Money.
              // "Advance" means Dairy gave Advance. Farmer Received Money.
              // "Collection" adds to Farmer Balance (Credit).
              // Actually bankingController `makePayment` REDUCES balance (Debit from Dairy perspective, but "Payment" usually means cash out).
              // Let's look at controller logic: 
              // makePayment: farmer.balance -= amount. (So Balance reduces).
              // giveAdvance: farmer.advance += amount.
              
              // So for Passbook: 
              // Payment: You received money. Balance goes down.
              // Advance: You received money. Advance debt goes up.
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: txn.type == 'payment' ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    txn.type == 'payment' ? Icons.arrow_downward : Icons.warning_amber,
                    color: txn.type == 'payment' ? Colors.green : Colors.orange
                  ),
                ),
                title: Text(txn.description.isNotEmpty ? txn.description : (txn.type == 'payment' ? 'Payment Received' : 'Advance Taken')),
                subtitle: Text(DateFormat('dd MMM yyyy').format(txn.date)),
                trailing: Text(
                  '\u20B9 ${txn.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: txn.type == 'payment' ? Colors.green : Colors.orange,
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
