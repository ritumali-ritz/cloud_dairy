import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/farmer.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  Farmer? _selectedFarmer;
  final _qtyCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _snfCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  
  String _shift = 'Morning';
  String _milkType = 'Cow';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load farmers if not already loaded
    if (context.read<AdminProvider>().farmers.isEmpty) {
      context.read<AdminProvider>().fetchFarmers();
    }
    // Load rates
    context.read<AdminProvider>().fetchRates(_milkType);
    
    // Listeners for auto-calculation
    _qtyCtrl.addListener(_calculateAmount);
    _rateCtrl.addListener(_calculateAmount);
    
    // Auto-fetch rate on Fat/SNF change
    _fatCtrl.addListener(_updateRateFromChart);
    _snfCtrl.addListener(_updateRateFromChart);
  }

  void _updateRateFromChart() {
    double fat = double.tryParse(_fatCtrl.text) ?? 0;
    double snf = double.tryParse(_snfCtrl.text) ?? 0;
    if (fat > 0 && snf > 0) {
      final rate = context.read<AdminProvider>().getRateFor(_milkType, fat, snf);
      if (rate > 0) {
        _rateCtrl.text = rate.toString();
        // Rate listener will trigger amount calc
      }
    }
  }

  void _calculateAmount() {
    double qty = double.tryParse(_qtyCtrl.text) ?? 0;
    double rate = double.tryParse(_rateCtrl.text) ?? 0;
    double amount = qty * rate;
    _amountCtrl.text = amount.toStringAsFixed(2);
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedFarmer != null) {
      try {
        await context.read<AdminProvider>().addCollection(
          _selectedFarmer!.id,
          _selectedDate,
          _shift,
          double.parse(_qtyCtrl.text),
          double.parse(_fatCtrl.text),
          double.parse(_snfCtrl.text),
          double.parse(_rateCtrl.text),
          double.parse(_amountCtrl.text),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection Added')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Milk Collection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<AdminProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<Farmer>(
                    // value: _selectedFarmer, // removed to avoid deprecation warning if possible, but actually we need it. 
                    // If the analyzer says value is deprecated in DropdownButtonFormField, it might be a very new flutter change or a mistake. 
                    // However, for now I will keep 'value' because removing it breaks the logic of showing selected item. 
                    // I'll try to use the 'value' property if it's the standard way. 
                    // Actually, let's look at the warning: "lib\screens\admin\add_collection.dart:99:23 - 'value' is deprecated". 
                    value: _selectedFarmer,
                    hint: const Text('Select Farmer'),
                    items: provider.farmers.map((f) {
                      return DropdownMenuItem(value: f, child: Text('${f.name} (${f.phone})'));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFarmer = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _shift,
                      items: const [
                        DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                        DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                      ],
                      onChanged: (v) => setState(() => _shift = v!),
                      decoration: const InputDecoration(labelText: 'Shift'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _milkType,
                      items: const [
                        DropdownMenuItem(value: 'Cow', child: Text('Cow')),
                        DropdownMenuItem(value: 'Buffalo', child: Text('Buffalo')),
                      ],
                      onChanged: (v) {
                        setState(() => _milkType = v!);
                        context.read<AdminProvider>().fetchRates(_milkType);
                        _updateRateFromChart();
                      },
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      decoration: const InputDecoration(labelText: 'Qty (L)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _fatCtrl,
                      decoration: const InputDecoration(labelText: 'Fat'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _snfCtrl,
                      decoration: const InputDecoration(labelText: 'SNF'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rateCtrl,
                      decoration: const InputDecoration(labelText: 'Rate/L'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Total Amount', filled: true, fillColor: Colors.greenAccent),
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Collection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
