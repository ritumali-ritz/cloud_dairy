import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Authentication ---

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password (Admin)
  Future<UserCredential> signInAdmin(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Register Admin (First time setup)
  Future<UserCredential> registerAdmin(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Firestore Data ---

  // Check if UID exists in a collection
  Future<bool> checkUserRole(String uid, String collection) async {
    final doc = await _firestore.collection(collection).doc(uid).get();
    return doc.exists;
  }

  // --- Farmer Data ---

  // Get Wallet (Real-time stream preferred check, but future for now)
  Future<DocumentSnapshot> getFarmerWallet(String uid) {
    return _firestore.collection('farmers').doc(uid).get();
  }

  Future<QuerySnapshot> getFarmerByPhone(String phone) {
    return _firestore.collection('farmers').where('phone', isEqualTo: phone).get();
  }

  // Get Collections
  Future<QuerySnapshot> getFarmerCollections(String uid, {int limit = 10}) {
    return _firestore.collection('collections')
        .where('farmerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
  }

  // Get Transactions
  Future<QuerySnapshot> getFarmerTransactions(String uid) {
    return _firestore.collection('transactions')
        .where('farmerId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
  }

  // Get Feeds (Broadcast + Personal)
  Future<QuerySnapshot> getFarmerFeeds(String uid) {
    // Logic: feeds where farmerId == uid OR farmerId == null (broadcast)
    // Firestore doesn't support OR queries easily across fields like that in v1 unless using 'in'.
    // Better to fetch broadcast separately or structure differently.
    // For now, let's fetch broadcast and personal separately or just all for MVP?
    // Let's assume we fetch all and filter client side or 2 queries.
    return _firestore.collection('feeds')
         .orderBy('date', descending: true)
         .get(); 
  }

  // Get Bills
  Future<QuerySnapshot> getFarmerBills(String uid) {
    return _firestore.collection('bills')
        .where('farmerId', isEqualTo: uid)
        .orderBy('generatedAt', descending: true)
        .get();
  }

  // --- Admin Features ---

  // Get All Farmers
  Future<QuerySnapshot> getAllFarmers() {
    return _firestore.collection('farmers').get();
  }

  // Create Farmer (Firestore doc only. Auth should be handled separately or via Cloud Function)
  Future<void> createFarmerDoc(String farmerId, Map<String, dynamic> data) {
    return _firestore.collection('farmers').doc(farmerId).set(data);
  }

  // Add Collection
  Future<void> addCollection(Map<String, dynamic> data) async {
    // Add to main collections
    await _firestore.collection('collections').add(data);
    // Optional: Update Aggregates (e.g. daily total) if needed
  }

  // --- Rate Chart ---
  Future<QuerySnapshot> getRates(String type) {
    return _firestore.collection('rates').where('type', isEqualTo: type).get();
  }

  Future<void> updateRate(String id, Map<String, dynamic> data) {
    return _firestore.collection('rates').doc(id).set(data, SetOptions(merge: true));
  }
  
  // Upsert Rate
  Future<void> upsertRate(String type, double fat, double snf, double rate) async {
    final query = await _firestore.collection('rates')
        .where('type', isEqualTo: type)
        .where('fat', isEqualTo: fat)
        .where('snf', isEqualTo: snf)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'rate': rate});
    } else {
      await _firestore.collection('rates').add({
        'type': type,
        'fat': fat,
        'snf': snf,
        'rate': rate,
        'updatedAt': DateTime.now().toIso8601String()
      });
    }
  }

  // --- Feeds ---
  Future<void> sendFeed(Map<String, dynamic> data) {
    return _firestore.collection('feeds').add(data);
  }

  // --- Banking ---
  Future<void> addTransaction(Map<String, dynamic> data) async {
    // Start batch
    WriteBatch batch = _firestore.batch();
    
    // Add Transaction Ref
    DocumentReference txRef = _firestore.collection('transactions').doc();
    batch.set(txRef, data);

    // Update Farmer Balance
    DocumentReference farmerRef = _firestore.collection('farmers').doc(data['farmerId']);
    
    double amountStr = (data['amount'] as num).toDouble();
    String type = data['type']; // 'credit', 'debit', 'payment', 'advance'

    if (type == 'payment') {
       // Payment means we PAY them, so their balance (Money WE Owe THEM) decreases.
       batch.update(farmerRef, {'balance': FieldValue.increment(-amountStr)});
    } else if (type == 'advance') {
       batch.update(farmerRef, {'advance': FieldValue.increment(amountStr)});
    } else if (type == 'collection') {
       // Milk collected -> We owe them more.
       batch.update(farmerRef, {'balance': FieldValue.increment(amountStr)});
    }

    await batch.commit();
  }
  
  Future<void> saveBill(Map<String, dynamic> data) {
     return _firestore.collection('bills').add(data);
  }

  // --- User Profiles ---

  // Get Admin Profile
  Future<DocumentSnapshot> getAdminProfile(String uid) {
    return _firestore.collection('admins').doc(uid).get();
  }

  // Get Farmer Profile
  Future<DocumentSnapshot> getFarmerProfile(String uid) {
    return _firestore.collection('farmers').doc(uid).get();
  }

  // Create/Update Admin Profile
  Future<void> saveAdminProfile(String uid, Map<String, dynamic> data) {
    return _firestore.collection('admins').doc(uid).set(data, SetOptions(merge: true));
  }
}
