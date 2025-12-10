import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/farmer.dart';

class ManageFarmersScreen extends StatefulWidget {
  const ManageFarmersScreen({super.key});

  @override
  State<ManageFarmersScreen> createState() => _ManageFarmersScreenState();
}

class _ManageFarmersScreenState extends State<ManageFarmersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchFarmers();
    });
  }

  void _showAddFarmerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Farmer'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await context.read<AdminProvider>().addFarmer(
                  nameCtrl.text,
                  phoneCtrl.text,
                  passCtrl.text,
                  addressCtrl.text,
                );
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Farmers')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFarmerDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.farmers.isEmpty) {
            return const Center(child: Text('No farmers found.'));
          }
          return ListView.builder(
            itemCount: provider.farmers.length,
            itemBuilder: (context, index) {
              final farmer = provider.farmers[index];
              return ListTile(
                leading: CircleAvatar(child: Text(farmer.name[0])),
                title: Text(farmer.name),
                subtitle: Text(farmer.phone),
                trailing: Text('\u20B9${farmer.balance}'), // Rupee symbol
              );
            },
          );
        },
      ),
    );
  }
}
