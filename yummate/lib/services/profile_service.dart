import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user profile exists in Firestore
  static Future<bool> profileExists(String uid) async {
    try {
      final doc = await _firestore.collection('user_profiles').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('user_profiles').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
