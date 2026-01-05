import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../dto/create_event_request.dart';
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

      if (selectedDate != null) {
        // Tạo range ngày theo giờ UTC trực tiếp (Không dùng toUtc() từ giờ Local)
        // Ví dụ: Chọn 21/1 -> Tìm từ 21/1 00:00Z đến 22/1 00:00Z
        final startUTC = DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day);
        final endUTC = startUTC.add(const Duration(days: 1)); // Sang đầu ngày hôm sau

        // Query: Lớn hơn bằng 00:00 ngày đó VÀ Nhỏ hơn 00:00 ngày hôm sau
        queryString += "&filters[Date][\$gte]=${startUTC.toIso8601String()}";
        queryString += "&filters[Date][\$lt]=${endUTC.toIso8601String()}";
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

  Future<bool> createEvent(CreateEventRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.events);
      print("Creating Event at: $url");
      print("Payload: ${request.toJson()}");

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      print("Create Status: ${response.statusCode}");
      print("Create Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Handle Strapi Error format
        final errorData = json.decode(response.body);
        final msg = errorData['error']?['message'] ?? "Unknown error";
        throw Exception(msg);
      }
    } catch (e) {
      print("Error createEvent: $e");
      rethrow;
    }
  }

// 5. Upload Image
  Future<int?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/api/upload");
      print("Uploading Image to: $url");

      // Create Multipart Request
      final request = http.MultipartRequest('POST', url);

      // Attach File
      final file = await http.MultipartFile.fromPath('files', imageFile.path);
      request.files.add(file);

      // Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Upload Status: ${response.statusCode}");

      // --- SỬA DÒNG NÀY: Chấp nhận cả 200 và 201 ---
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Strapi returns an array of uploaded files
        final List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          // Trả về ID của ảnh để dùng cho bước tạo sự kiện
          return jsonResponse[0]['id'];
        }
      } else {
        print("Upload Error: ${response.body}");
      }
    } catch (e) {
      print("Error uploadImage: $e");
    }
    return null;
  }
}