import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workouts_page.dart';

class MyHomePage extends StatelessWidget {
  final String userName;
  const MyHomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'REVIVE 75',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildTodayProgress(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildWorkoutSection(context),
            const SizedBox(height: 20),
            _buildHealthStats(),
          ],
        ),
      ),

      // 🔥 FIXED NAVIGATION BAR
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WorkoutPage(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center, color: Colors.white),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu, color: Colors.white),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // 🔹 Greeting
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${userName.toUpperCase()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stay consistent. You are closer than you think.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // 🔹 Progress
  Widget _buildTodayProgress() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today’s Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProgressItem(label: 'Steps', value: '8,420'),
                _ProgressItem(label: 'Calories', value: '560'),
                _ProgressItem(label: 'Water', value: '1.8L'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.72,
              backgroundColor: Colors.white10,
              color: Colors.blueAccent,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.play_circle_fill,
            title: 'Start',
            subtitle: 'Workout',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutPage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.local_drink,
            title: 'Log',
            subtitle: 'Water',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // 🔹 Workout Tile
  Widget _buildWorkoutSection(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkoutPage(),
          ),
        );
      },
      tileColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
      title: const Text(
        'Full Body Strength',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        '45 min • Intermediate',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 14,
      ),
    );
  }

  // 🔹 Stats
  Widget _buildHealthStats() {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            title: 'Heart Rate',
            value: '78 bpm',
            icon: Icons.favorite,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Sleep',
            value: '7h 40m',
            icon: Icons.nightlight_round,
          ),
        ),
      ],
    );
  }
}

// --- SUB WIDGETS ---
class _ProgressItem extends StatelessWidget {
  final String label, value;
  const _ProgressItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]);
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.grey[900],
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Icon(icon, color: Colors.blueAccent),
              Text(title, style: const TextStyle(color: Colors.white)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ]),
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.redAccent, size: 20),
          Text(title,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      );
}