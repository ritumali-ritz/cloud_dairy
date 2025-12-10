import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class SendFeedScreen extends StatefulWidget {
  const SendFeedScreen({super.key});

  @override
  State<SendFeedScreen> createState() => _SendFeedScreenState();
}

class _SendFeedScreenState extends State<SendFeedScreen> {
  final _msgCtrl = TextEditingController();
  String? _selectedFarmerId; // Null means "All"

  @override
  void initState() {
    super.initState();
    // Ensure farmers are loaded
    if (context.read<AdminProvider>().farmers.isEmpty) {
      context.read<AdminProvider>().fetchFarmers();
    }
  }

  void _send() async {
    if (_msgCtrl.text.isEmpty) return;

    try {
      await context.read<AdminProvider>().sendFeed(
        _selectedFarmerId,
        _msgCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message Sent')));
      _msgCtrl.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feed Update')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<AdminProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<String?>(
                  value: _selectedFarmerId,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Farmers')),
                    ...provider.farmers.map((f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(f.name),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedFarmerId = val),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message', 
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AdminProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Message'),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
