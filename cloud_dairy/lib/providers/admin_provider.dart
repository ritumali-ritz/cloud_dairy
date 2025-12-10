import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../models/collection.dart';
import '../services/firebase_service.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Farmer> _farmers = [];
  bool _isLoading = false;

  List<Farmer> get farmers => _farmers;
  bool get isLoading => _isLoading;

  Future<void> fetchFarmers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getAllFarmers();
      _farmers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['_id'] = doc.id; // Map doc ID to model ID if needed
        return Farmer.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching farmers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFarmer(String name, String phone, String password, String address) async {
    _isLoading = true;
    notifyListeners();
    try {
      // In a real app, we'd create an Auth user here or trigger a cloud function.
      // For now, we manually create the Firestore doc. The farmer will "sign up" using this phone number
      // and we can link it then, or we use a pre-assigned UID logic if using phone auth.
      // For simplicity, we assume we just create a doc with a unique ID (e.g. phone number as ID or random)
      // Attempt to use phone as ID to enforce uniqueness easily?
      
      // Let's use a random ID but check phone uniqueness first (Firebase rules or query)
      // For MVP, just add doc.
      
      await _firebaseService.createFarmerDoc(phone, { // Using phone as ID for easier lookup? Or random?
        // Using Random ID is better for Auth. But we can query by phone.
        // Let's use Phone as ID for now for specific mapping if we can.
        // Actually, Auth UID is random. Best to let Auth create UID.
        // Fallback: Create arbitrary doc.
        
        'name': name,
        'phone': phone,
        'address': address,
        'password': password, // Storing plain text is BAD, but requested for migration parity.
        'balance': 0,
        'advance': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      // Refresh list
      await fetchFarmers();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCollection(String farmerId, DateTime date, String shift, double qty, double fat, double snf, double rate, double amount) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.addCollection({
        'farmerId': farmerId,
        'date': date.toIso8601String(),
        'shift': shift,
        'qty': qty,
        'fat': fat,
        'snf': snf,
        'rate': rate,
        'amount': amount,
      });

      // Also trigger a transaction update for Balance (Credit to farmer)
      await _firebaseService.addTransaction({
        'farmerId': farmerId,
        'amount': amount,
        'type': 'collection',
        'date': DateTime.now().toIso8601String(),
        'description': 'Milk Collection $date $shift',
      });

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rate Chart Logic
  List<dynamic> _rates = [];
  List<dynamic> get rates => _rates;

  Future<void> fetchRates(String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getRates(type);
      _rates = snapshot.docs.map((doc) {
         final data = doc.data() as Map<String, dynamic>;
         data['id'] = doc.id;
         return data;
      }).toList();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRate(String type, double fat, double snf, double rate) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.upsertRate(type, fat, snf, rate);
      // Refresh list
      await fetchRates(type);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to find rate locally if needed
  double getRateFor(String type, double fat, double snf) {
    try {
      final entry = _rates.firstWhere(
        (r) => r['type'] == type && r['fat'] == fat && r['snf'] == snf,
      );
      return (entry['rate'] ?? 0).toDouble();
    } catch (e) {
      return 0;
    }
  }

  // Feed Logic
  Future<void> sendFeed(String? farmerId, String message) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.sendFeed({
        'farmerId': farmerId,
        'message': message,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Banking Logic

  Future<void> makePayment(String farmerId, double amount, String mode, String description) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.addTransaction({
        'farmerId': farmerId,
        'amount': amount,
        'type': 'payment',
        'mode': mode,
        'description': description, // e.g. "Payment via Cash"
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> giveAdvance(String farmerId, double amount, String mode) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.addTransaction({
        'farmerId': farmerId,
        'amount': amount,
        'type': 'advance',
        'mode': mode,
        'description': 'Advance Given',
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Billing Logic (Client-Side Calculation)
  Future<void> generateBill(String farmerId, DateTime start, DateTime end, int cycle) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Fetch Collections for dates
      final snapshot = await _firebaseService.getFarmerCollections(farmerId, limit: 1000); // Fetch enough
      
      // Filter by range locally (since we fetched by date desc limit, checking range is safer)
      // Ideally use a range query in FirebaseService, but re-using getFarmerCollections for now
      // or implement range query. 
      // Let's implement range filter on client for MVP safety.
      
      final collections = snapshot.docs.map((d) => Collection.fromJson(d.data() as Map<String, dynamic>)).where((c) {
        return c.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
               c.date.isBefore(end.add(const Duration(days: 1))); 
      }).toList();

      if (collections.isEmpty) return; // No collections to bill

      double totalMilk = 0;
      double totalAmount = 0;
      
      for (var c in collections) {
         totalMilk += c.qty;
         totalAmount += c.amount;
      }
      
      double avgRate = totalMilk > 0 ? totalAmount / totalMilk : 0;
      double deductions = 0; // Logic for deductions if any?
      double netPayable = totalAmount - deductions;

      // 2. Save Bill
      await _firebaseService.saveBill({
        'farmerId': farmerId,
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'cycleNumber': cycle,
        'totalMilk': totalMilk,
        'avgRate': avgRate,
        'totalAmount': totalAmount,
        'deductions': deductions,
        'netPayable': netPayable,
        'generatedAt': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
