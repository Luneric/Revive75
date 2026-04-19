import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED: access current signed-in user
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: read user data from Firestore

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // ADDED: get current Firebase user

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No user is signed in.'), // ADDED: signed-out fallback
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(), // ADDED: fetch this user's Firestore document
      builder: (context, snapshot) {
        String displayName = user.displayName ?? 'Warrior'; // ADDED: fallback from Firebase Auth
        String email = user.email ?? 'No email'; // ADDED: fallback from Firebase Auth
        String? photoUrl = user.photoURL; // ADDED: fallback photo from Firebase Auth

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>; // ADDED: read Firestore map
          displayName = (data['name'] ?? displayName).toString(); // ADDED: prefer Firestore name
          email = (data['email'] ?? email).toString(); // ADDED: prefer Firestore email
          photoUrl = (data['photoUrl'] ?? photoUrl)?.toString(); // ADDED: prefer Firestore photo
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null, // ADDED: show profile image if available
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 50,
                        )
                      : null, // ADDED: fallback icon if no image exists
                ),
                const SizedBox(height: 16),
                Text(
                  displayName, // CHANGED: dynamic name instead of hardcoded Username
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email, // CHANGED: dynamic email instead of hardcoded user@email.com
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add functionality later
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}