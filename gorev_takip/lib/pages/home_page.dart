import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_add_page.dart';
import 'login_page.dart';
import '../services/user_service.dart';
import 'profile_page.dart';
import 'calendar_page.dart';
import 'ai_assistant_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  String selectedCategory = 'Tümü';
  String userName = "";
  String dailyMotivation = "";

  final List<String> _motivations = [
    "Bugün harika işler başaracaksın!",
    "Planlı çalışırsan her şey mümkün.",
    "Küçük adımlarla büyük hedeflere ulaşılır.",
    "Odaklan, başarının anahtarı budur.",
    "Görevlerini sıraya koy, önceliklerini belirle.",
    "Sen bu işi yaparsın, eminim!",
    "Zor görünen işler bittiğinde keyif verir.",
    "Az kaldı, pes etme!",
    "Her gün biraz daha ilerlemek büyük fark yaratır."
  ];

  final List<String> _emojis = [
    "🔥",
    "💪",
    "🚀",
    "🌟",
    "✨",
    "🎯",
    "🎉",
    "✅",
    "🧠",
    "☀️",
    "💡",
    "👑"
  ];

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pickDailyMotivation();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _pickDailyMotivation() {
    final random = Random();
    String motivation = _motivations[random.nextInt(_motivations.length)];
    String emoji = _emojis[random.nextInt(_emojis.length)];
    dailyMotivation = "$motivation $emoji";
  }

  void _loadUserData() async {
    final userData = await UserService().getUserData();
    if (userData != null) {
      setState(() {
        userName =
            "${userData['name']} ${_emojis[Random().nextInt(_emojis.length)]}";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        title: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hoşgeldin,",
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                Text(
                  userName.isEmpty ? "..." : userName,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CalendarPage())),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AIAssistantPage())),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfilePage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(toggleTheme: widget.toggleTheme),
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha((0.15 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                dailyMotivation,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          _buildStatisticsSection(),
          _buildCategoryDropdown(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TaskAddPage())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final tasks = snapshot.data!;
        final filteredTasks = selectedCategory == 'Tümü'
            ? tasks
            : tasks.where((t) => t.category == selectedCategory).toList();
        final total = filteredTasks.length;
        final completed = filteredTasks.where((t) => t.isCompleted).length;
        final remaining = total - completed;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Toplam", total, Colors.blue),
              _buildStatCard("Tamamlanan", completed, Colors.green),
              _buildStatCard("Kalan", remaining, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedCategory,
        items: ['Tümü', 'Genel', 'İş', 'Okul', 'Kişisel']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedCategory = val!;
          });
        },
      ),
    );
  }

  Widget _buildTaskList() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allTasks = snapshot.data!;

        final filteredTasks = selectedCategory == 'Tümü'
            ? allTasks
            : allTasks.where((t) => t.category == selectedCategory).toList();

        if (filteredTasks.isEmpty) {
          return const Center(child: Text("Görev bulunamadı"));
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                );
              },
              child: Slidable(
                key: ValueKey(task.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _taskService.deleteTask(task.id),
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Sil',
                    ),
                  ],
                ),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(task.description),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (val) {
                        _taskService.updateTaskCompletion(task.id, val!);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      color: color.withAlpha(178),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text(count.toString(),
                style: const TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
