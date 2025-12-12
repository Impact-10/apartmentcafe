import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/admin_menu_provider.dart';
import 'providers/connection_provider.dart';
import 'screens/admin/admin_login.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/customer/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with hardcoded config (from .env.local values)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCVGJkGudLVlzJHRE4JACqEcE--Qxonpe8',
      authDomain: 'apartment-fv.firebaseapp.com',
      projectId: 'apartment-fv',
      storageBucket: 'apartment-fv.firebasestorage.app',
      messagingSenderId: '176790456882',
      appId: '1:176790456882:web:531dec259ece9244e1ca2b',
      databaseURL: 'https://apartment-fv-default-rtdb.firebaseio.com',
    ),
  );

  // Enable offline persistence
  final db = FirebaseDatabase.instance;
  db.setPersistenceEnabled(true);
  db.setPersistenceCacheSizeBytes(10000000);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AdminMenuProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: MaterialApp(
        title: 'Apartment Café',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in (admin)
          return const AdminDashboard();
        }

        // Check if it's admin login screen or customer screen
        // For now, show a choice screen
        return const RoleSelectionScreen();
      },
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Apartment Café',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AdminLogin()));
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CustomerHome()));
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Customer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
