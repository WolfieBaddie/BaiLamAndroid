import 'dart:convert';
import 'package:hello_world/entities/Task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String apiUrl = 'https://xxx.com/api/tasks';

  Future<List<Task>> getTaskList() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Chuyển đổi JSON sang List<Task>
        final jsonData = jsonDecode(response.body)['data'] as List;
        List<Task> taskList = jsonData.map((item) => Task.fromJson(item)).toList();
        return taskList;
      } else {
        // Xử lý lỗi nếu API trả về mã trạng thái khác 200
        print('Failed to load tasks. Status code: ${response.statusCode}');
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      // Xử lý lỗi nếu có lỗi xảy ra trong quá trình gọi API
      print('Error fetching tasks: $error');
      throw Exception('Error fetching tasks: $error');
    }
  }
}