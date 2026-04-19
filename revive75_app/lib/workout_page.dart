import 'package:flutter/material.dart';
import 'app_router.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class Exercise {
  String name;
  String value;
  bool done;

  Exercise({
    required this.name,
    required this.value,
    this.done = false,
  });
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Exercise> exercises = [];
  String selectedCategory = "Full Body";

  double get progress {
    if (exercises.isEmpty) return 0;
    int done = exercises.where((e) => e.done).length;
    return done / exercises.length;
  }

  void generateWorkout() {
    Map<String, List<Exercise>> workouts = {
      "Full Body": [
        Exercise(name: "Push Ups", value: "10 x 3"),
        Exercise(name: "Squats", value: "15 x 3"),
        Exercise(name: "Jumping Jacks", value: "60 sec"),
      ],
      "Upper Body": [
        Exercise(name: "Push Ups", value: "12 x 3"),
        Exercise(name: "Pull Ups", value: "8 x 3"),
      ],
      "Legs": [
        Exercise(name: "Squats", value: "15 x 3"),
        Exercise(name: "Lunges", value: "12 x 3"),
      ],
      "Glutes": [
        Exercise(name: "Hip Thrusts", value: "12 x 3"),
        Exercise(name: "Glute Bridges", value: "15 x 3"),
      ],
    };

    setState(() {
      exercises = workouts[selectedCategory] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Workout Generator',
          style: TextStyle(color: Colors.blueAccent),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Progress
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Workout Progress",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: Colors.blueAccent,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toInt()}% completed",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Generator
            const Text(
              "Workout Generator",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.blueAccent),
                    decoration: const InputDecoration(
                      labelText: "Workout Type",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                    items: [
                      "Full Body",
                      "Upper Body",
                      "Lower Body",
                      "Arms",
                      "Legs",
                      "Glutes"
                    ]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(
                                      color: Colors.blueAccent)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: generateWorkout,
                    child: const Text(
                      "Generate Workout",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Workout List
            const Text(
              "Your Workout",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...exercises.map((ex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CheckboxListTile(
                  activeColor: Colors.blueAccent,
                  title: Text(
                    ex.name,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  subtitle: Text(
                    ex.value,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  value: ex.done,
                  onChanged: (val) {
                    setState(() {
                      ex.done = val!;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),

      // 🔥 FIXED NAVIGATION
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        selectedIndex: 1,
        onDestinationSelected: (index) {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 2) {
          Navigator.pushNamed(context, AppRoutes.meal);
        } else if (index == 3) {
          Navigator.pushNamed(context, AppRoutes.profile);
        }
      },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.blueAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center, color: Colors.blueAccent),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu, color: Colors.blueAccent),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.blueAccent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}