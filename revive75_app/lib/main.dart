import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Revive75App());
}

class Revive75App extends StatelessWidget {
  const Revive75App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revive 75',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        fontFamily: 'Roboto', // Clean, modern font
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // AnimatedSwitcher creates a smooth fade transition between Login and Dashboard
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: snapshot.hasData 
                ? const DashboardScreen(key: ValueKey('Dashboard')) 
                : const AuthScreen(key: ValueKey('Auth')),
          );
        },
      ),
    );
  }
}

// --- AUTH SCREEN (LOGIN & SIGNUP) ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _handleAuth() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'createdAt': DateTime.now(),
          'currentDay': 1,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- APP LOGO & NAME ---
              const Icon(Icons.bolt_rounded, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              const Text(
                "REVIVE 75",
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 4,
                  color: Colors.white
                ),
              ),
              const Text(
                "HARD CHALLENGE",
                style: TextStyle(fontSize: 12, color: Colors.blueAccent, letterSpacing: 2),
              ),
              const SizedBox(height: 60),

              if (!isLogin) ...[
                _buildTextField(_nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 20),
              ],
              _buildTextField(_emailController, "Email Address", Icons.email_outlined),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, "Password", Icons.lock_outline, obscure: true),
              
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _handleAuth,
                child: Text(
                  isLogin ? "LOGIN" : "SIGN UP",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => setState(() => isLogin = !isLogin),
                child: RichText(
                  text: TextSpan(
                    text: isLogin ? "Don't have an account? " : "Already a member? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: isLogin ? "Sign Up" : "Login",
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        filled: true,
        fillColor: Colors.grey[900],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
        ),
      ),
    );
  }
}

// --- DASHBOARD ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "WARRIOR"; // Default if name isn't found
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            userName = doc['name'] ?? "WARRIOR";
            isLoading = false;
          });
        } else {
          // This handles your old account that has no Firestore document
          setState(() => isLoading = false);
        }
      } catch (e) {
        print("Error fetching user: $e");
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("DASHBOARD", style: TextStyle(fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text(
                  userName.toUpperCase(), 
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
                const SizedBox(height: 30),
                
                // Main Progress Card
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("CURRENT DAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          Icon(Icons.trending_up, color: Colors.black.withOpacity(0.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("01", style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.black)),
                      const Text("Total Progress: 1.3%", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.013,
                          minHeight: 12,
                          backgroundColor: Colors.black12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 35),
                const Text("DAILY STATS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    _buildSmallTile("Workouts", "0/2", Icons.fitness_center_rounded),
                    const SizedBox(width: 15),
                    _buildSmallTile("Water", "0%", Icons.local_drink_rounded),
                  ],
                ),
                const SizedBox(height: 15),
                _buildWideTile("Next Task: 10 Pages Reading", Colors.grey[900]!),
              ],
            ),
          ),
    );
  }

  // ... (Keep your _buildSmallTile and _buildWideTile methods the same as before)
  Widget _buildSmallTile(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideTile(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}