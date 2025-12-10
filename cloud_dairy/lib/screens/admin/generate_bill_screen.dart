import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'package:intl/intl.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({super.key});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  String? _selectedFarmerId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _cycle = 1;
  bool _customDates = false;

  @override
  void initState() {
    super.initState();
    if (context.read<AdminProvider>().farmers.isEmpty) {
      context.read<AdminProvider>().fetchFarmers();
    }
    _updateCycleDates(1);
  }

  void _updateCycleDates(int cycle) {
    setState(() {
      _cycle = cycle;
      _customDates = false;
      final now = DateTime.now();
      if (cycle == 1) {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month, 10);
      } else if (cycle == 2) {
        _startDate = DateTime(now.year, now.month, 11);
        _endDate = DateTime(now.year, now.month, 20);
      } else {
        _startDate = DateTime(now.year, now.month, 21);
        // Last day of month
        _endDate = DateTime(now.year, now.month + 1, 0);
      }
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked; else _endDate = picked;
        _customDates = true;
      });
    }
  }

  void _generate() async {
    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a farmer')));
      return;
    }
    
    try {
      await context.read<AdminProvider>().generateBill(
        _selectedFarmerId!,
        _startDate,
        _endDate,
        _cycle,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Generated Successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: const Text('Generate 10-Day Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Select Cycle', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('1-10'), 
                          selected: _cycle == 1 && !_customDates,
                          onSelected: (v) => _updateCycleDates(1),
                        ),
                        ChoiceChip(
                          label: const Text('11-20'), 
                          selected: _cycle == 2 && !_customDates,
                          onSelected: (v) => _updateCycleDates(2),
                        ),
                        ChoiceChip(
                          label: const Text('21-End'), 
                          selected: _cycle == 3 && !_customDates,
                          onSelected: (v) => _updateCycleDates(3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd MMM').format(_startDate)),
                    onPressed: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd MMM').format(_endDate)),
                    onPressed: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<AdminProvider>(builder: (context, provider, _) {
              return DropdownButtonFormField<String>(
                value: _selectedFarmerId,
                decoration: const InputDecoration(labelText: 'Select Farmer', border: OutlineInputBorder()),
                items: provider.farmers.map((f) => DropdownMenuItem(
                  value: f.id, 
                  child: Text(f.name)
                )).toList(),
                onChanged: (v) => setState(() => _selectedFarmerId = v),
              );
            }),
            const SizedBox(height: 32),
            Consumer<AdminProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue,
                  ),
                  child: provider.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate Bill', style: TextStyle(color: Colors.white, fontSize: 18)),
                );
              }
            ),
          ],
        ),
      ),
     );
  }
}
