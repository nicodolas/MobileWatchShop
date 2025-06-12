import 'package:firebase_auth/firebase_auth.dart';
import 'package:ahtshopdongho/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> signIn(String userEmail, String passWord) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: passWord,
      );

      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        return user;
      } else {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: "Vui lòng xác thực email để đăng nhập.",
        );
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.message}");
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    return await _userService.getUserData(userId);
  }
}
