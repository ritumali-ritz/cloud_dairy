import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class RateChartScreen extends StatefulWidget {
  const RateChartScreen({super.key});

  @override
  State<RateChartScreen> createState() => _RateChartScreenState();
}

class _RateChartScreenState extends State<RateChartScreen> {
  String _selectedType = 'Cow';
  bool _isEditing = false; // Toggle to show manual entry form

  final _fatCtrl = TextEditingController();
  final _snfCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

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
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Chart'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.add),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          )
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          // Prepare Data for Matrix
          final rates = provider.rates;
          
          // Extract unique Fats and SNFs sorted
          final Set<double> fatsSet = {};
          final Set<double> snfsSet = {};
          final Map<String, double> rateMap = {}; // key: "fat_snf" -> rate

          for (var r in rates) {
            double f = (r['fat'] as num).toDouble();
            double s = (r['snf'] as num).toDouble();
            fatsSet.add(f);
            snfsSet.add(s);
            rateMap['${f}_$s'] = (r['rate'] as num).toDouble();
          }

          final fats = fatsSet.toList()..sort();
          final snfs = snfsSet.toList()..sort();

          return Column(
            children: [
              // Type Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                     Expanded(
                       child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Cow', label: Text('Cow'), icon: Icon(Icons.grass)),
                          ButtonSegment(value: 'Buffalo', label: Text('Buffalo'), icon: Icon(Icons.water_drop)), // Buffalo icon proxy
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _selectedType = newSelection.first);
                          provider.fetchRates(_selectedType);
                        },
                      ),
                     ),
                  ],
                ),
              ),

              if (_isEditing)
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Add / Update Single Rate", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _fatCtrl, decoration: const InputDecoration(labelText: 'Fat'), keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(child: TextFormField(controller: _snfCtrl, decoration: const InputDecoration(labelText: 'SNF'), keyboardType: TextInputType.number)),
                            const SizedBox(width: 8),
                            Expanded(child: TextFormField(controller: _rateCtrl, decoration: const InputDecoration(labelText: 'Rate'), keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: provider.isLoading ? null : _submit, child: const Text("Save Rate"))
                      ],
                    ),
                  ),
                ),

              // Matrix View
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rates.isEmpty
                        ? const Center(child: Text("No rates found. Add one to start."))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: TableBorder.all(color: Colors.grey[300]!),
                                headingRowColor: MaterialStateProperty.all(Colors.green[100]),
                                columns: [
                                  const DataColumn(label: Text('Fat / SNF', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ...snfs.map((s) => DataColumn(label: Text(s.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)))),
                                ],
                                rows: fats.map((fat) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(fat.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                                      ...snfs.map((snf) {
                                        final r = rateMap['${fat}_${snf}'];
                                        return DataCell(
                                          Text(r != null ? r.toStringAsFixed(2) : '-'),
                                          onTap: () {
                                            // Pre-fill edit form
                                            setState(() {
                                              _isEditing = true;
                                              _fatCtrl.text = fat.toString();
                                              _snfCtrl.text = snf.toString();
                                              _rateCtrl.text = r?.toString() ?? '';
                                            });
                                          },
                                        );
                                      }),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
