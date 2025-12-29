import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/habit_provider.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../utils/habit_categories.dart';
import 'habit_details_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _selectedDay = DateTime.now();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    Provider.of<HabitProvider>(context, listen: false).loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("COMMAND CENTER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // --- THE FIX: CustomScrollView (Slivers) ---
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          
          // 1. Prepare Habit Data
          final visibleHabits = _selectedFilter == 'All'
              ? provider.habits
              : provider.habits.where((h) => h.category == _selectedFilter).toList();

          // 2. Prepare Task Data
          final tasks = provider.tasks;

          return CustomScrollView(
            slivers: [
              
              // --- SECTION 1: GREETING ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Here is your agenda for today.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ),
              ),

              // --- SECTION 2: HABITS HEADER & FILTER ---
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("MY HABITS"),
                    _buildCategoryFilter(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // --- SECTION 3: HABITS LIST (SliverList) ---
              if (visibleHabits.isEmpty)
                SliverToBoxAdapter(
                   child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No habits found.", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = visibleHabits[index];
                      return _buildHabitCard(habit, provider);
                    },
                    childCount: visibleHabits.length,
                  ),
                ),

              // --- SECTION 4: TASKS HEADER ---
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildSectionHeader("PRIORITY TASKS"),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // --- SECTION 5: TASKS LIST (SliverList) ---
              if (tasks.isEmpty)
                SliverToBoxAdapter(
                   child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No tasks pending.", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(task, provider);
                    },
                    childCount: tasks.length,
                  ),
                ),

              // --- BOTTOM PADDING ---
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMultiAddDialog(context),
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)
      ),
    );
  }

  Widget _buildCategoryFilter() {
    List<String> filters = ['All', ...HabitCategories.list];
    // Horizontal lists are fine inside Slivers if wrapped in BoxAdapter
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final category = filters[index];
          final isSelected = _selectedFilter == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: category == 'All' ? Colors.white : HabitCategories.getColor(category),
              backgroundColor: const Color(0xFF1E1E1E),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3)),
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = category);
              },
            ),
          );
        },
      ),
    );
  }

  // --- CARD BUILDERS (Moved out of ListView for cleaner code) ---

  Widget _buildHabitCard(Habit habit, HabitProvider provider) {
    bool isDone = habit.isCompleted(_selectedDay);
    Color color = HabitCategories.getColor(habit.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Keep the Safe Navigation Logic
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => HabitDetailsScreen(habit: habit)),
            );
          },
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(
                HabitCategories.getIcon(habit.category), 
                color: habit.category == 'Other' ? Colors.white : color,
                size: 24
              ),
            ),
            title: Text(habit.title, style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.grey : Colors.white)),
            subtitle: Text(habit.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: Checkbox(
              value: isDone,
              activeColor: color,
              shape: const CircleBorder(),
              onChanged: (val) => provider.toggleHabit(habit.id, _selectedDay),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, HabitProvider provider) {
    Color priorityColor;
    switch (task.priority) {
      case 'High': priorityColor = Colors.redAccent; break;
      case 'Medium': priorityColor = Colors.orangeAccent; break;
      default: priorityColor = Colors.greenAccent;
    }

    IconData catIcon = HabitCategories.getIcon(task.category);
    Color catColor = HabitCategories.getColor(task.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(catIcon, color: catColor, size: 20),
          ),
          
          title: Text(
            task.title, 
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null, 
              color: task.isCompleted ? Colors.grey : Colors.white
            )
          ),
          
          subtitle: Text(
            "${task.priority} Priority • ${task.category}", 
            style: TextStyle(color: Colors.grey[500], fontSize: 11)
          ),
          
          trailing: Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: task.isCompleted,
              activeColor: priorityColor, 
              shape: const CircleBorder(),
              side: BorderSide(color: priorityColor),
              onChanged: (val) => provider.toggleTask(task.id),
            ),
          ),
        ),
      ),
    );
  }

  // --- DIALOG LOGIC ---
  // (This remains unchanged but included for completeness)

  void _showMultiAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("What do you want to add?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAddOption(context, "New Habit", Icons.loop, Colors.indigoAccent, () {
                    Navigator.pop(context);
                    _showAddHabitDialog(context);
                  }),
                  _buildAddOption(context, "New Task", Icons.check_circle, Colors.orangeAccent, () {
                    Navigator.pop(context);
                    _showAddTaskDialog(context);
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String selectedCategory = 'Health'; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text("New Habit"),
              content: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: controller, decoration: const InputDecoration(hintText: "e.g., Drink Water", hintStyle: TextStyle(color: Colors.grey), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigoAccent))), style: const TextStyle(color: Colors.white), autofocus: true),
                    const SizedBox(height: 20),
                    const Align(alignment: Alignment.centerLeft, child: Text("Category", style: TextStyle(color: Colors.grey, fontSize: 12))),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: HabitCategories.list.map((category) {
                      final isSelected = selectedCategory == category;
                      return ChoiceChip(
                        avatar: Icon(HabitCategories.getIcon(category), color: isSelected ? Colors.black : HabitCategories.getColor(category), size: 18),
                        label: Text(category), selected: isSelected, selectedColor: HabitCategories.getColor(category), backgroundColor: Colors.grey[800], labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                        onSelected: (bool selected) { if (selected) setDialogState(() => selectedCategory = category); },
                      );
                    }).toList()),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: () { if (controller.text.isNotEmpty) { Provider.of<HabitProvider>(context, listen: false).addHabit(controller.text, selectedCategory); Navigator.pop(context); } }, child: const Text("Save", style: TextStyle(color: Colors.indigoAccent))),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String selectedPriority = 'Medium';
    String selectedCategory = 'Work';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            scrollable: true,
            title: const Text("New Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "What needs to be done?",
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigoAccent)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                const Text("Priority", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ['Low', 'Medium', 'High'].map((priority) {
                    final isSelected = selectedPriority == priority;
                    Color color = priority == 'High' ? Colors.redAccent : (priority == 'Medium' ? Colors.orangeAccent : Colors.greenAccent);
                    return ChoiceChip(
                      label: Text(priority),
                      selected: isSelected,
                      selectedColor: color,
                      backgroundColor: Colors.grey[800],
                      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                      onSelected: (selected) { if (selected) setDialogState(() => selectedPriority = priority); },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text("Category", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitCategories.list.map((category) {
                    final isSelected = selectedCategory == category;
                    return ChoiceChip(
                      avatar: Icon(HabitCategories.getIcon(category), color: isSelected ? Colors.black : HabitCategories.getColor(category), size: 16),
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: HabitCategories.getColor(category),
                      backgroundColor: Colors.grey[800],
                      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                      onSelected: (selected) { if (selected) setDialogState(() => selectedCategory = category); },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Provider.of<HabitProvider>(context, listen: false)
                        .addTask(controller.text, selectedPriority, selectedCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add", style: TextStyle(color: Colors.indigoAccent)),
              ),
            ],
          );
        },
      ),
    );
  }
}