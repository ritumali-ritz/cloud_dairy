import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class RateChartScreen extends StatefulWidget {
  const RateChartScreen({super.key});

  @override
  State<RateChartScreen> createState() => _RateChartScreenState();
}

class _RateChartScreenState extends State<RateChartScreen> {
  final _fatCtrl = TextEditingController();
  final _snfCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  String _selectedType = 'Cow';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchRates(_selectedType);
    });
  }

  void _submit() async {
    if (_fatCtrl.text.isEmpty || _snfCtrl.text.isEmpty || _rateCtrl.text.isEmpty) return;

    try {
      await context.read<AdminProvider>().updateRate(
        _selectedType,
        double.parse(_fatCtrl.text),
        double.parse(_snfCtrl.text),
        double.parse(_rateCtrl.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rate Updated')));
      _fatCtrl.clear();
      _snfCtrl.clear();
      _rateCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rate Chart')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Input Section
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: 'Cow', child: Text('Cow')),
                          DropdownMenuItem(value: 'Buffalo', child: Text('Buffalo')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedType = val!);
                          provider.fetchRates(_selectedType);
                        },
                        decoration: const InputDecoration(labelText: 'Milk Type'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _fatCtrl, decoration: const InputDecoration(labelText: 'Fat'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _snfCtrl, decoration: const InputDecoration(labelText: 'SNF'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _rateCtrl, decoration: const InputDecoration(labelText: 'Rate'), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        child: const Text('Set Rate'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              // List Section
              Expanded(
                child: provider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.rates.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final rate = provider.rates[index];
                        return ListTile(
                          title: Text('Fat: ${rate['fat']} | SNF: ${rate['snf']}'),
                          trailing: Text('\u20B9 ${rate['rate']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
