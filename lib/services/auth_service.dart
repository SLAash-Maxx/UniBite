import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      final doc  = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        final user = UserModel(id: cred.user!.uid, fullName: email.split('@').first, email: email.trim(), studentId: '', createdAt: DateTime.now());
        await _db.collection('users').doc(user.id).set(user.toJson());
        return user;
      }
      return UserModel.fromJson({'id': cred.user!.uid, ...doc.data()!});
    } on FirebaseAuthException catch (e) { throw Exception(_friendlyError(e.code)); }
  }

  Future<UserModel> register({required String fullName, required String studentId, required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await cred.user!.updateDisplayName(fullName);
      final user = UserModel(id: cred.user!.uid, fullName: fullName, studentId: studentId, email: email.trim(), createdAt: DateTime.now());
      await _db.collection('users').doc(user.id).set(user.toJson());
      return user;
    } on FirebaseAuthException catch (e) { throw Exception(_friendlyError(e.code)); }
  }

  Future<UserModel?> getStoredUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson({'id': firebaseUser.uid, ...doc.data()!});
    } catch (_) { return null; }
  }

  // FIX #12 - Forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) { throw Exception(_friendlyError(e.code)); }
  }

  Future<void> logout() async { await _auth.signOut(); }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':      return 'No account found with this email.';
      case 'wrong-password':      return 'Incorrect password. Please try again.';
      case 'email-already-in-use':return 'An account with this email already exists.';
      case 'weak-password':       return 'Password must be at least 6 characters.';
      case 'invalid-email':       return 'Please enter a valid email address.';
      case 'too-many-requests':   return 'Too many attempts. Please try again later.';
      default:                    return 'Something went wrong. Please try again.';
    }
  }
}
