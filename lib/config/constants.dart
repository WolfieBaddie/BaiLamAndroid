// lib/config/constants.dart

class ApiConstants {
  // Dành cho Android Emulator
  static const String baseUrl = "http://10.0.2.2:1338";

  // Endpoint API
  static const String registration = "$baseUrl/api/registations";
  static const String events = "$baseUrl/api/events";
  static const String categories = "$baseUrl/api/event-categories";

  // Hàm tiện ích để lấy full URL ảnh từ Strapi
  // Vì Strapi trả về link dạng "/uploads/abc.jpg" nên cần nối thêm domain
  static String getImageUrl(String? path) {
    if (path == null) return "https://via.placeholder.com/150"; // Ảnh lỗi
    if (path.startsWith("http")) return path;
    return "$baseUrl$path";
  }
}