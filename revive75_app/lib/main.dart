import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'app_router.dart';

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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const UserDataWrapper();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class UserDataWrapper extends StatelessWidget {
  const UserDataWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        String name = "Warrior";
        if (snapshot.hasData && snapshot.data!.exists) {
          name = snapshot.data!['name'] ?? "Warrior";
        }

        return MyHomePage(userName: name);
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _verificationId = "";

  // --- DATABASE SYNC HELPER ---
  // Ensures user data is stored in Firestore without overwriting existing accounts.
 Future<void> _syncUserToFirestore(User user, {String? customName}) async {
  try {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'uid': user.uid,
      'email': user.email ?? "",
      'phoneNumber': user.phoneNumber ?? "",
      'name': customName ?? user.displayName ?? "Warrior",
      'photoUrl': user.photoURL ?? "",
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // ✅ KEY FIX: updates existing users too

  } catch (e) {
    debugPrint("Firestore Sync Error: $e");
  }
}

  // --- PHONE SIGN IN LOGIC ---
  Future<void> _signInWithPhone() async {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Phone Login", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Include your country code (e.g., +1 for USA)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "+1 650 555 1234"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              String phoneNumber = phoneController.text.trim();
              if (phoneNumber.isEmpty) return;

              Navigator.pop(context);

              try {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: phoneNumber,
                  verificationCompleted: (PhoneAuthCredential credential) async {
                    UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
                    if (userCred.user != null) await _syncUserToFirestore(userCred.user!);
                  },
                  verificationFailed: (e) => _showError("Phone Error: ${e.message}"),
                  codeSent: (String verId, int? resendToken) {
                    setState(() => _verificationId = verId);
                    _showCodeDialog();
                  },
                  codeAutoRetrievalTimeout: (String verId) {
                    _verificationId = verId;
                  },
                );
              } catch (e) {
                _showError("Failed to verify: $e");
              }
            },
            child: const Text("Send Code"),
          )
        ],
      ),
    );
  }

  void _showCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Enter SMS Code", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: codeController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "123456"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: codeController.text.trim(),
                );
                UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
                if (userCred.user != null) await _syncUserToFirestore(userCred.user!);
                Navigator.pop(context);
              } catch (e) {
                _showError("Invalid or expired code");
              }
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }

  // --- GOOGLE SIGN IN LOGIC ---
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '819122231420-ra8kivmpjvlsr571pgpv6f9eav9gbtlc.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCred.user != null) await _syncUserToFirestore(userCred.user!);
      }
    } catch (e) {
      _showError("Google Error: ${e.toString()}");
    }
  }

  // --- EMAIL/PASSWORD AUTH LOGIC ---
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Login doesn't need sync because user already exists, 
        // but adding it ensures old users without docs get one.
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) await _syncUserToFirestore(user);
      } else {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          await _syncUserToFirestore(
            userCredential.user!,
            customName: _nameController.text.trim(),
          );
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded, size: 100, color: Colors.blueAccent),
                const Text(
                  "REVIVE 75",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person)),
                    validator: (val) => val!.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 15),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                  validator: (val) => val!.isEmpty ? "Enter your email" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  onFieldSubmitted: (_) => _handleAuth(),
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
                  validator: (val) => val!.length < 6 ? "Password too short" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleAuth,
                    child: Text(isLogin ? "LOGIN" : "SIGN UP"),
                  ),
                ),
                const SizedBox(height: 25),
                const Text("OR CONTINUE WITH", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.phone_android, _signInWithPhone),
                    const SizedBox(width: 20),
                    _socialButton(Icons.g_mobiledata_rounded, _signInWithGoogle),
                  ],
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? "Create an account" : "Have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}