import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Meal {
  final String name;
  final int calories;
  final List<String> ingredients;
  final String instructions;

  const Meal({
    required this.name,
    required this.calories,
    required this.ingredients,
    required this.instructions,
  });
}

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  final List<Meal> suggestedMeals = const [
    Meal(
      name: 'Chicken & Rice Bowl',
      calories: 500,
      ingredients: ['1 cup cooked rice', '150g grilled chicken', '1/2 cup broccoli'],
      instructions: 'Cook rice, grill chicken, steam broccoli, and combine everything.',
    ),
    Meal(
      name: 'Avocado Toast',
      calories: 350,
      ingredients: ['2 slices bread', '1 avocado', 'Salt & pepper'],
      instructions: 'Toast bread, mash avocado, spread, and season.',
    ),
  ];

  Future<void> saveMeal(Map<String, dynamic> mealData, String? uid) async {
    await FirebaseFirestore.instance.collection('planned_meals').add({
      'name': mealData['name'],
      'calories': mealData['calories'],
      'ingredients': mealData['ingredients'],
      'instructions': mealData['instructions'],
      'userId': uid,
      'isPublic': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black, // Matching Home & Workout background
      appBar: AppBar(
        title: const Text('Meal Tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Section matching the Workout Page icon style
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: const Icon(Icons.restaurant_menu, size: 45, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fuel Your Progress',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Main Action Button matching Workout Generator
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMealDialog(),
                  );
                },
                child: const Text('Create Custom Meal', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Suggested Meals', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Suggested Meals Section
            ...suggestedMeals.map((meal) => _buildMealCard(
              context, 
              {
                'name': meal.name,
                'calories': meal.calories,
                'ingredients': meal.ingredients,
                'instructions': meal.instructions,
              }, 
              currentUid, 
              isMine: false, 
              isSuggested: true
            )),

            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Meal Feed', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Live Firebase Meal Feed
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('planned_meals')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['userId'] == currentUid || data['isPublic'] == true;
                }).toList();

                return Column(
                  children: docs.map((doc) {
                    final mealData = doc.data() as Map<String, dynamic>;
                    return _buildMealCard(context, mealData, currentUid, isMine: mealData['userId'] == currentUid);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 100), // Space for bottom navigation bar
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.white10,
        selectedIndex: 2, // Highlight "Meals" tab
        onDestinationSelected: (index) {
          if (index == 0) Navigator.popUntil(context, (route) => route.isFirst);
          else if (index == 1) Navigator.pushReplacementNamed(context, '/workout'); // Use your app's route names
          else if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
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

  // Reusable Card Widget matching Home/Workout aesthetic
  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal, String? currentUid, {required bool isMine, bool isSuggested = false}) {
    return Card(
      color: Colors.grey[900], // Dark card style
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        iconColor: Colors.blueAccent,
        collapsedIconColor: Colors.grey,
        leading: Icon(
          meal['isPublic'] == true ? Icons.public : Icons.lock_outline,
          size: 20,
          color: isMine ? Colors.blueAccent : Colors.grey,
        ),
        title: Text(meal['name'] ?? 'Unnamed Meal', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('${meal['calories']} kcal ${isMine ? "(You)" : "(Community)"}', 
          style: const TextStyle(color: Colors.grey)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingredients:', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ...(meal['ingredients'] as List).map((i) => Text('• $i', style: const TextStyle(color: Colors.white70))),
                const SizedBox(height: 12),
                const Text('Instructions:', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Text(meal['instructions'] ?? 'No instructions.', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                if (!isMine || isSuggested)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blueAccent)),
                      icon: const Icon(Icons.add, color: Colors.blueAccent),
                      label: const Text('Add to My Plan', style: TextStyle(color: Colors.blueAccent)),
                      onPressed: () async {
                        await saveMeal(meal, currentUid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Meal added to your plan!')),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddMealDialog extends StatefulWidget {
  const AddMealDialog({super.key});
  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();
  final ingredientsController = TextEditingController();
  final instructionsController = TextEditingController();
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Create New Meal', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameController, 'Meal Name'),
            _buildField(caloriesController, 'Calories', isNumber: true),
            _buildField(ingredientsController, 'Ingredients (comma separated)'),
            _buildField(instructionsController, 'Instructions'),
            SwitchListTile(
              title: const Text("Share with Community", style: TextStyle(color: Colors.white, fontSize: 14)),
              value: isPublic,
              activeColor: Colors.blueAccent,
              onChanged: (val) => setState(() => isPublic = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            await FirebaseFirestore.instance.collection('planned_meals').add({
              'name': nameController.text,
              'calories': int.tryParse(caloriesController.text) ?? 0,
              'ingredients': ingredientsController.text.split(','),
              'instructions': instructionsController.text,
              'isPublic': isPublic,
              'userId': user?.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (mounted) Navigator.pop(context);
          }, 
          child: const Text('Save Meal', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        ),
      ),
    );
  }
}