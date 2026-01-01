import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';

class EventService {
  final http.Client client;

  EventService({http.Client? client}) : client = client ?? http.Client();

  // 1. Get Categories
  Future<List<Category>> getCategories() async {
    try {
      final url = Uri.parse(ApiConstants.categories);
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        return data.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      print("Lỗi getCategories: $e");
    }
    return [];
  }

  // 2. Get Events (Hỗ trợ Search & Date)
  Future<List<Event>> getEvents({
    int page = 1,
    int pageSize = 10,
    List<int>? categoryIds,
    String? searchQuery,    // <--- Tham số tìm kiếm
    DateTime? selectedDate, // <--- Tham số lọc ngày
  }) async {
    try {
      // FIX LỖI 400: Đổi 'sort=date:desc' thành 'sort=Date:desc' (Viết hoa chữ D)
      String queryString = "populate=*&pagination[page]=$page&pagination[pageSize]=$pageSize&sort=Date:desc";

      // 1. Filter Category
      if (categoryIds != null && categoryIds.isNotEmpty) {
        for (int i = 0; i < categoryIds.length; i++) {
          queryString += "&filters[event_category][id][\$in][$i]=${categoryIds[i]}";
        }
      }

      // 2. Filter Search (Tìm theo Title hoặc Name - tùy database của bạn)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Dùng $containsi để tìm không phân biệt hoa thường
        // Nếu database bạn dùng trường 'Title' thì đổi 'name' thành 'Title'
        queryString += "&filters[Name][\$containsi]=$searchQuery";
      }

      // 3. Filter Date
      if (selectedDate != null) {
        // Tạo khoảng thời gian từ đầu ngày đến cuối ngày
        final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
        final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

        // FIX LỖI 400: Dùng 'Date' viết hoa
        queryString += "&filters[Date][\$gte]=${startOfDay.toIso8601String()}";
        queryString += "&filters[Date][\$lte]=${endOfDay.toIso8601String()}";
      }

      final url = Uri.parse("${ApiConstants.events}?$queryString");
      print("Calling Events API: $url");

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        print("Lỗi API (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Lỗi getEvents: $e");
    }
    return [];
  }

  Future<Event?> getEventDetails(String documentId) async {
    try {
      final url = Uri.parse("${ApiConstants.events}/$documentId?populate=*");
      print("Calling Detail API: $url");

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final dynamic data = jsonBody['data'];
        return Event.fromJson(data);
      } else {
        print("Detail API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getEventDetails: $e");
    }
    return null;
  }
}