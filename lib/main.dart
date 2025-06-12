import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/login.dart';
import 'package:ahtshopdongho/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routes: {
        '/': (context) => AuthGate(),
        '/home': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return HomeScreen(
            categoryName: args['categoryName'] ?? 'Smart Watches',
            user: args['user'],
          );
        },
      },
      initialRoute: '/',
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final PageController _pageController = PageController();

  Future<AppUser?> fetchUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(uid, doc.data()!);
      } else {
        print('❗ User document not found');
        return null;
      }
    } catch (e) {
      print('❗ Error fetching user data: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<AppUser?>(
            future: fetchUserData(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                // Đã có AppUser -> chuyển trang
                Future.microtask(() {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {
                      'user': userSnapshot.data!,
                      'categoryName': 'Smart Watches',
                    },
                  );
                });

                return Container(); // Tránh UI nháy
              } else {
                return Scaffold(
                  body: Center(
                    child: Text('Không thể tải thông tin người dùng'),
                  ),
                );
              }
            },
          );
        }

        // Nếu chưa đăng nhập
        return LoginPage(pageController: _pageController);
      },
    );
  }
}

// import 'package:ahtshopdongho/screens/home_screen.dart';
// import 'package:ahtshopdongho/screens/login.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:ahtshopdongho/models/user_model.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await FirebaseAuth.instance.signOut();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       routes: {
//         '/': (context) => AuthGate(),
//         '/home': (context) {
//           final args =
//               ModalRoute.of(context)!.settings.arguments
//                   as Map<String, dynamic>;
//           return HomeScreen(
//             categoryName: args['categoryName'] ?? 'Smart Watches',
//             user: args['user'],
//           );
//         },
//       },
//       initialRoute: '/',
//     );
//   }
// }

// class AuthGate extends StatefulWidget {
//   @override
//   _AuthGateState createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   final PageController _pageController = PageController();

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(body: Center(child: CircularProgressIndicator()));
//         }

//         if (snapshot.hasData) {
//           final user = snapshot.data;
//           if (user != null) {
//             final appUser = AppUser(
//               userId: user.uid,
//               userName: user.displayName ?? '',
//               userEmail: user.email ?? '',
//               fullName: '',
//             );

//             Navigator.pushNamed(
//               context,
//               '/home',
//               arguments: {'user': appUser, 'categoryName': 'Smart Watches'},
//             );

//             return Container(); // Chờ chuyển trang
//           }
//         }

//         return LoginPage(pageController: _pageController);
//       },
//     );
//   }
// }
