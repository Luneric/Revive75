import 'package:flutter/material.dart';
import 'dart:async';
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
  int? remainingSeconds;
  Timer? timer;
  bool isPaused = false;

  Exercise({
    required this.name,
    required this.value,
    this.done = false,
  });
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Exercise> exercises = [];
  String selectedOption = "Strength Training"; // Renamed
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _secController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  double get progress {
    if (exercises.isEmpty) return 0;
    int done = exercises.where((e) => e.done).length;
    return done / exercises.length;
  }

  int? _parseSeconds(String value) {
    if (value.contains(":")) {
      final parts = value.split(":");
      if (parts.length == 2) {
        return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      }
    }
    return null;
  }

  void _toggleTimer(Exercise ex) {
    if (ex.timer != null) {
      ex.timer?.cancel();
      setState(() {
        ex.timer = null;
        ex.isPaused = true;
      });
    } else {
      if (ex.remainingSeconds == null) {
        ex.remainingSeconds = _parseSeconds(ex.value) ?? 0;
      }
      if (ex.remainingSeconds! <= 0) return;

      setState(() => ex.isPaused = false);
      ex.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (ex.remainingSeconds! > 0) {
              ex.remainingSeconds = ex.remainingSeconds! - 1;
            } else {
              ex.timer?.cancel();
              ex.timer = null;
              ex.done = true;
            }
          });
        }
      });
    }
  }

  void addCustomExercise() {
    if (_nameController.text.isNotEmpty) {
      int m = int.tryParse(_minController.text) ?? 0;
      int s = int.tryParse(_secController.text) ?? 0;
      String sets = _setsController.text;
      String reps = _repsController.text;
      
      String displayValue = "";
      if (m > 0 || s > 0) {
        displayValue = "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
      } else if (sets.isNotEmpty || reps.isNotEmpty) {
        displayValue = "${sets.isEmpty ? '0' : sets} sets x ${reps.isEmpty ? '0' : reps} reps";
      } else {
        displayValue = "Custom Task";
      }
      
      setState(() {
        exercises.add(Exercise(name: _nameController.text, value: displayValue));
      });

      _nameController.clear();
      _minController.clear();
      _secController.clear();
      _setsController.clear();
      _repsController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void removeExercise(int index) {
    setState(() {
      exercises[index].timer?.cancel();
      exercises.removeAt(index);
    });
  }

  void generateWorkout() {
    // 45 Minute Structures
    Map<String, List<Exercise>> workouts = {
      "Strength Training": [
        Exercise(name: "Warm Up: Dynamic Stretch", value: "05:00"),
        Exercise(name: "Bench Press", value: "4 sets x 10 reps"),
        Exercise(name: "Deadlifts", value: "4 sets x 8 reps"),
        Exercise(name: "Overhead Press", value: "3 sets x 12 reps"),
        Exercise(name: "Barbell Rows", value: "3 sets x 12 reps"),
        Exercise(name: "Plank Hold", value: "02:00"),
        Exercise(name: "Cool Down: Static Stretch", value: "10:00"),
      ],
      "HIIT / Cardio": [
        Exercise(name: "Warm Up: Jog in Place", value: "05:00"),
        Exercise(name: "Burpees", value: "01:00"),
        Exercise(name: "Mountain Climbers", value: "01:00"),
        Exercise(name: "Jump Squats", value: "01:00"),
        Exercise(name: "High Knees", value: "01:00"),
        Exercise(name: "Circuit Repeat (4 Rounds)", value: "25:00"),
        Exercise(name: "Cool Down: Walk & Stretch", value: "10:00"),
      ],
      "Yoga / Mobility": [
        Exercise(name: "Child's Pose Intro", value: "05:00"),
        Exercise(name: "Sun Salutations", value: "10:00"),
        Exercise(name: "Warrior Sequence", value: "10:00"),
        Exercise(name: "Balance Poses (Tree/Eagle)", value: "05:00"),
        Exercise(name: "Deep Hip Openers", value: "05:00"),
        Exercise(name: "Savasana (Meditation)", value: "10:00"),
      ],
      "Bodyweight Blast": [
        Exercise(name: "Warm Up: Jumping Jacks", value: "05:00"),
        Exercise(name: "Push Ups", value: "4 sets x 15 reps"),
        Exercise(name: "Bodyweight Squats", value: "4 sets x 20 reps"),
        Exercise(name: "Lunges", value: "3 sets x 12 reps"),
        Exercise(name: "Dips (on chair/bench)", value: "3 sets x 15 reps"),
        Exercise(name: "Wall Sit", value: "02:00"),
        Exercise(name: "Cool Down: Full Body Stretch", value: "10:00"),
      ],
    };

    setState(() {
      for (var ex in exercises) { ex.timer?.cancel(); }
      exercises = List.from(workouts[selectedOption] ?? []);
    });
  }

  @override
  void dispose() {
    for (var ex in exercises) { ex.timer?.cancel(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Workout Generator', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Workout Progress", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: progress, minHeight: 8, color: Colors.blueAccent, backgroundColor: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Custom Input
            const Text("Create Custom Workout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Exercise Name", hintStyle: TextStyle(color: Colors.white38), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _minController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Min", hintStyle: TextStyle(color: Colors.white38)))),
                      const Text(" : ", style: TextStyle(color: Colors.white)),
                      Expanded(child: TextField(controller: _secController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Sec", hintStyle: TextStyle(color: Colors.white38)))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.repeat, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _setsController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Sets", hintStyle: TextStyle(color: Colors.white38)))),
                      const Text(" x ", style: TextStyle(color: Colors.white)),
                      Expanded(child: TextField(controller: _repsController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Reps", hintStyle: TextStyle(color: Colors.white38)))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: addCustomExercise,
                    child: const Text("Add Workout", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Quick Generator
            const Text("Quick Generator", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Workout Options", labelStyle: TextStyle(color: Colors.white70), border: InputBorder.none),
                    items: ["Strength Training", "HIIT / Cardio", "Yoga / Mobility", "Bodyweight Blast"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedOption = val!),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: generateWorkout,
                    child: const Text("Generate 45 Min Workout", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plan List
            const Text("Today's Plan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                bool isTimed = _parseSeconds(ex.value) != null;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              activeColor: Colors.blueAccent,
                              checkColor: Colors.white,
                              title: Text(ex.name, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                ex.remainingSeconds != null 
                                  ? "${(ex.remainingSeconds! ~/ 60)}:${(ex.remainingSeconds! % 60).toString().padLeft(2, '0')} remaining" 
                                  : ex.value,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              value: ex.done,
                              onChanged: (val) {
                                setState(() {
                                  ex.done = val!;
                                  if (val) { ex.timer?.cancel(); ex.timer = null; }
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54),
                            onPressed: () => removeExercise(index),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      if (isTimed && !ex.done)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextButton.icon(
                            onPressed: () => _toggleTimer(ex),
                            icon: Icon(ex.timer == null ? Icons.play_arrow : Icons.pause, color: Colors.blueAccent),
                            label: Text(ex.timer == null ? (ex.isPaused ? "Resume" : "Start") : "Pause", 
                              style: const TextStyle(color: Colors.blueAccent)),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.white10,
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) Navigator.pop(context);
          else if (index == 2) Navigator.pushNamed(context, AppRoutes.meal);
          else if (index == 3) Navigator.pushNamed(context, AppRoutes.profile);
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
}