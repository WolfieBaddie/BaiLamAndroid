import 'package:flutter/material.dart';
import 'package:hello_world/entities/Task.dart';
import 'package:hello_world/services/task_service.dart';
import 'package:hello_world/widgets/bottom_nav_bar.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> _taskList = [];
  bool _isLoading = true; // Biến để hiển thị loading indicator
  int _selectedIndex = 2; // Selected index cho bottom nav bar

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    try {
      final taskService = TaskService();
      final tasks = await taskService.getTaskList();
      setState(() {
        _taskList = tasks;
        _isLoading = false; // Kết thúc loading
      });
    } catch (error) {
      // Xử lý lỗi nếu có lỗi xảy ra khi load tasks
      print('Error loading tasks: $error');
      setState(() {
        _isLoading = false; // Kết thúc loading, ngay cả khi có lỗi
      });
      // Có thể hiển thị thông báo lỗi cho người dùng ở đây
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to other screens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading indicator
          : _taskList.isEmpty
          ? Center(child: Text('No tasks available.')) // No data
          : ListView.builder(
        itemCount: _taskList.length,
        itemBuilder: (context, index) {
          final task = _taskList[index];
          return ListTile(
            title: Text(task.title??''),
            subtitle: Text(task.status??''),
            // Add other task details here
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}