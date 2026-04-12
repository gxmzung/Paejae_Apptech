import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_user.dart';

class ProfileStoreService {
  ProfileStoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AuthUser?> fetchProfile(String email) async {
    final doc = await _users.doc(email.trim().toLowerCase()).get();
    final data = doc.data();
    if (data == null) return null;
    return AuthUser.fromMap(data);
  }

  Future<void> saveProfile({
    required String email,
    required String nickname,
    required String department,
    required int? entranceYear,
  }) async {
    await _users.doc(email.trim().toLowerCase()).set({
      'email': email.trim().toLowerCase(),
      'nickname': nickname.trim(),
      'department': department.trim(),
      'entranceYear': entranceYear,
      'isVerifiedStudent': true,
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}