import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.dart';

class MyHomePage extends StatefulWidget {
  final String userName;
  const MyHomePage({super.key, required this.userName});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // --- DYNAMIC DATA ---
  int steps = 8420;
  int calories = 560;
  double waterDrank = 1.8;
  double waterGoal = 3.7; 
  String? currentWorkout = "Full Body Strength"; 

  // --- LOGIC METHODS ---
  void _logWater(double amount) {
    setState(() {
      waterDrank += amount;
      if (waterDrank < 0) waterDrank = 0.0;
    });
  }

  void _showWaterPicker() {
    final TextEditingController amountController = TextEditingController();
    bool isRemoving = false; // Internal toggle state

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows keyboard to push the sheet up
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder( // Allows the toggle to update UI inside the sheet
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRemoving ? 'Remove Water Intake' : 'Add Water Intake',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  
                  // Professional Numeric Input
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(color: Colors.white24),
                      suffixText: 'ml',
                      suffixStyle: const TextStyle(color: Colors.blueAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Professional Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Add', style: TextStyle(color: Colors.grey)),
                      Switch(
                        value: isRemoving,
                        activeColor: Colors.redAccent,
                        inactiveTrackColor: Colors.blueAccent.withOpacity(0.3),
                        onChanged: (val) => setModalState(() => isRemoving = val),
                      ),
                      const Text('Remove', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Submit Action
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRemoving ? Colors.redAccent : Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        double enteredVal = double.tryParse(amountController.text) ?? 0;
                        if (enteredVal > 0) {
                          // Convert ml to Liters for the logic
                          double liters = enteredVal / 1000;
                          _logWater(isRemoving ? -liters : liters);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        isRemoving ? 'CONFIRM REMOVAL' : 'SAVE LOG',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('REVIVE 75', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
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
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildWorkoutSection(),
            const SizedBox(height: 20),
            _buildHealthStats(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, AppRoutes.workout);
          if (index == 2) Navigator.pushNamed(context, AppRoutes.meal);
          if (index == 3) Navigator.pushNamed(context, AppRoutes.profile);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center, color: Colors.white), label: 'Workouts'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu, color: Colors.white), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.person, color: Colors.white), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${widget.userName.toUpperCase()}',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stay consistent. You are closer than you think.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTodayProgress() {
    double progressValue = (waterDrank / waterGoal).clamp(0.0, 1.0);

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today’s Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProgressItem(label: 'Steps', value: steps.toString()),
                _ProgressItem(label: 'Calories', value: calories.toString()),
                _ProgressItem(label: 'Water', value: '${waterDrank.toStringAsFixed(2)}L'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white10,
              color: Colors.blueAccent,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.play_circle_fill, 
            title: 'Start', 
            subtitle: 'Workout', 
            onTap: () => Navigator.pushNamed(context, AppRoutes.workout),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.local_drink, 
            title: 'Log', 
            subtitle: 'Water', 
            onTap: _showWaterPicker,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    bool hasWorkout = currentWorkout != null;
    return ListTile(
      onTap: () => Navigator.pushNamed(context, AppRoutes.workout),
      tileColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
      title: Text(
        hasWorkout ? currentWorkout! : 'Current Workout - None',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        hasWorkout ? '45 min • Intermediate' : 'Ready to start your journey?',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
    );
  }

  Widget _buildHealthStats() {
    return Row(
      children: const [
        Expanded(child: _StatCard(title: 'Heart Rate', value: '78 bpm', icon: Icons.favorite)),
        SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Sleep', value: '7h 40m', icon: Icons.nightlight_round)),
      ],
    );
  }
}

// --- SUB-WIDGETS ---
class _ProgressItem extends StatelessWidget {
  final String label, value;
  const _ProgressItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
  ]);
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.grey[900],
    child: InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Icon(icon, color: Colors.blueAccent),
      Text(title, style: const TextStyle(color: Colors.white)),
      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
    ]))),
  );
}

class _StatCard extends StatelessWidget {
  final String title, value; final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
    child: Column(children: [
      Icon(icon, color: Colors.redAccent, size: 20),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );
}