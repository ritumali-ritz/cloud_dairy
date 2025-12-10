import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';

class FarmerProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Collection> _collections = [];
  List<Transaction> _transactions = [];
  double _balance = 0;
  double _advance = 0;
  bool _isLoading = false;

  List<dynamic> _feeds = [];
  List<dynamic> _bills = [];

  List<Collection> get collections => _collections;
  List<Transaction> get transactions => _transactions;
  double get balance => _balance;
  double get advance => _advance;
  bool get isLoading => _isLoading;
  List<dynamic> get feeds => _feeds;
  List<dynamic> get bills => _bills;

  Future<void> fetchDashboardData(String farmerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch Wallet Info
      final walletDoc = await _firebaseService.getFarmerWallet(farmerId);
      if (walletDoc.exists) {
        final data = walletDoc.data() as Map<String, dynamic>;
        _balance = (data['balance'] ?? 0).toDouble();
        _advance = (data['advance'] ?? 0).toDouble();
      }

      // Fetch Last 10 Collections
      final collectionSnapshot = await _firebaseService.getFarmerCollections(farmerId);
      _collections = collectionSnapshot.docs.map((doc) {
        // mapping Firestore doc to model. Need to ensure Model has fromJson/fromMap
        // and handles ObjectId/Timestamps if coming from Mongo logic.
        // We might need to adjust models to handle Firestore Timestamp to DateTime.
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Inject ID
        return Collection.fromJson(data);
      }).toList();
      
    } catch (e) {
      print('Error fetching farmer dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String farmerId) async {
    _isLoading = true; 
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getFarmerTransactions(farmerId);
      _transactions = snapshot.docs.map((doc) {
         final data = doc.data() as Map<String, dynamic>;
         data['id'] = doc.id;
         return Transaction.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeeds(String farmerId) async {
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getFarmerFeeds(farmerId);
      var allFeeds = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      // Filter: Broadcast (farmerId is null) OR Targeted (farmerId == this.farmerId)
      _feeds = allFeeds.where((feed) {
        final fid = feed['farmerId'];
        return fid == null || fid == farmerId;
      }).toList();

    } catch (e) {
      print('Error fetching feeds: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchBills(String farmerId) async {
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getFarmerBills(farmerId);
      _bills = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data; 
        // Note: keeping as generic map if Bill model isn't imported or used yet, 
        // but existing provider returned List<dynamic> for bills too.
      }).toList();
    } catch (e) {
      print('Error fetching bills: $e');
    } finally {
      notifyListeners();
    }
  }
}
