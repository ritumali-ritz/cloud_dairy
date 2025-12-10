import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class BankingScreen extends StatefulWidget {
  const BankingScreen({super.key});

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (context.read<AdminProvider>().farmers.isEmpty) {
      context.read<AdminProvider>().fetchFarmers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Payment'), Tab(text: 'Advance')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PaymentTab(),
          _AdvanceTab(),
        ],
      ),
    );
  }
}

class _PaymentTab extends StatefulWidget {
  const _PaymentTab();
  @override
  State<_PaymentTab> createState() => _PaymentTabState();
}

class _PaymentTabState extends State<_PaymentTab> {
  String? _selectedFarmerId;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _mode = 'Cash';

  void _submit() async {
    if (_selectedFarmerId == null || _amountCtrl.text.isEmpty) return;
    try {
      await context.read<AdminProvider>().makePayment(
        _selectedFarmerId!,
        double.parse(_amountCtrl.text),
        _mode,
        _descCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful')));
      _amountCtrl.clear();
      _descCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Consumer<AdminProvider>(builder: (context, provider, _) {
            return DropdownButtonFormField<String>(
              value: _selectedFarmerId,
              decoration: const InputDecoration(labelText: 'Select Farmer', border: OutlineInputBorder()),
              items: provider.farmers.map((f) => DropdownMenuItem(
                value: f.id, 
                child: Text('${f.name} (Bal: \u20B9${f.balance})')
              )).toList(),
              onChanged: (v) => setState(() => _selectedFarmerId = v),
            );
          }),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            decoration: const InputDecoration(labelText: 'Amount', prefixText: '\u20B9 ', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _mode,
            items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'Bank', child: Text('Bank Transfer'))],
            onChanged: (v) => setState(() => _mode = v!),
            decoration: const InputDecoration(labelText: 'Mode'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Make Payment'),
          )
        ],
      ),
    );
  }
}

class _AdvanceTab extends StatefulWidget {
  const _AdvanceTab();
  @override
  State<_AdvanceTab> createState() => _AdvanceTabState();
}

class _AdvanceTabState extends State<_AdvanceTab> {
  String? _selectedFarmerId;
  final _amountCtrl = TextEditingController();
  String _mode = 'Cash';

  void _submit() async {
    if (_selectedFarmerId == null || _amountCtrl.text.isEmpty) return;
    try {
      await context.read<AdminProvider>().giveAdvance(
        _selectedFarmerId!,
        double.parse(_amountCtrl.text),
        _mode,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Advance Given')));
      _amountCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Consumer<AdminProvider>(builder: (context, provider, _) {
            return DropdownButtonFormField<String>(
              value: _selectedFarmerId,
              decoration: const InputDecoration(labelText: 'Select Farmer', border: OutlineInputBorder()),
              items: provider.farmers.map((f) => DropdownMenuItem(
                value: f.id, 
                child: Text('${f.name} (Adv: \u20B9${f.advance})')
              )).toList(),
              onChanged: (v) => setState(() => _selectedFarmerId = v),
            );
          }),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            decoration: const InputDecoration(labelText: 'Advance Amount', prefixText: '\u20B9 ', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _mode,
            items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'Bank', child: Text('Bank Transfer'))],
            onChanged: (v) => setState(() => _mode = v!),
            decoration: const InputDecoration(labelText: 'Mode'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.orange),
            child: const Text('Give Advance', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
