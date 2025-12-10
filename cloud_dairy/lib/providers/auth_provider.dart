import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser; // Internal user data cache
  bool _needsSetup = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseService.currentUser != null && _currentUser != null;
  bool get needsSetup => _needsSetup;
  String? get role => _currentUser?['role'];
  Map<String, dynamic>? get user => _currentUser?['profile'];
  String? get errorMessage => _errorMessage;

  // Called on app start
  Future<void> checkAppStartup() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        await _fetchUserProfile(user.uid);
      } else {
        // No user logged in.
        // Optional: Check if any admin exists in system to set _needsSetup
        // For now, assume setup is needed if no user is logged in? No, that's wrong.
        // We can skip 'needsSetup' logic for now or implement a check 'do any admins exist'
        // But Firestore requires a read.
      }
    } catch (e) {
      print('Startup check error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    // Check Admin
    final adminDoc = await _firebaseService.getAdminProfile(uid);
    if (adminDoc.exists) {
      _currentUser = {
        'role': 'admin',
        'profile': adminDoc.data(),
      };
      notifyListeners();
      return;
    }

    // Check Farmer
    final farmerDoc = await _firebaseService.getFarmerProfile(uid);
    if (farmerDoc.exists) {
      _currentUser = {
        'role': 'farmer',
        'profile': farmerDoc.data(),
      };
      notifyListeners();
      return;
    }

    // User authenticated but no profile found (Edge case)
    await _firebaseService.signOut();
    _errorMessage = "User profile not found.";
    _currentUser = null;
  }

  Future<void> registerAndSetup(String dairyName, String adminName, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Use email-like format for simplicity: phone@admin.dairy
      final email = '$phone@admin.dairy';
      final cred = await _firebaseService.registerAdmin(email, password);
      
      final profile = {
        'username': adminName,
        'phone': phone,
        'dairyName': dairyName,
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firebaseService.saveAdminProfile(cred.user!.uid, profile);

      _currentUser = {
        'role': 'admin',
        'profile': profile,
      };
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAdmin(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Logic: Is username a phone or email? Or actual username?
      // Since registration used `phone@admin.dairy`, we should infer.
      // If user types 'admin', we have a problem unless we stored it.
      // Let's assume username input is the phone number for now as per previous schema.
      
      String email = username;
      if (!username.contains('@')) {
        email = '$username@admin.dairy';
      }

      final cred = await _firebaseService.signInAdmin(email, password);
      await _fetchUserProfile(cred.user!.uid);
      
      if (_currentUser == null || _currentUser!['role'] != 'admin') {
         await _firebaseService.signOut();
         throw "Not an admin account";
      }

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Temporary using Email/Pass for Farmer too (phone@farmer.dairy)
  Future<void> loginFarmer(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final email = '$phone@farmer.dairy';
      final cred = await _firebaseService.signInAdmin(email, password); // Reusing signIn method
       await _fetchUserProfile(cred.user!.uid);

      if (_currentUser == null || _currentUser!['role'] != 'farmer') {
         await _firebaseService.signOut();
         throw "Not a farmer account";
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
