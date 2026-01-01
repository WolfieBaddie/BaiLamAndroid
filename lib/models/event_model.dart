import '../config/constants.dart';

class Event {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String categoryName;
  final String documentId;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.categoryName,
    required this.documentId
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;

    // --- 1. SỬA TÊN SỰ KIỆN (Title vs Name) ---
    String evtName = attributes['Name'] ?? "Sự kiện không tên";
    String documentId = attributes['documentId'];

    // --- 2. Xử lý Ảnh (Logic cũ giữ nguyên) ---
    String imgUrl = "https://via.placeholder.com/300"; // Ảnh mặc định
    try {
      final imageObj = json['Image']; // Lấy object Image

      if (imageObj != null) {
        // Lấy đường dẫn: /uploads/27_5_VP_2_3a4b940d82.jpg
        String? path = imageObj['url'];

        if (path != null) {
          // Kiểm tra xem có cần nối domain không
          if (path.startsWith('http')) {
            imgUrl = path;
          } else {
            // Nối: http://10.0.2.2:1338 + /uploads/...
            imgUrl = "${ApiConstants.baseUrl}$path";
          }
        }
      }
    } catch (e) {
      print("Lỗi parse ảnh: $e");
    }

    // --- 3. Xử lý Category (Title vs Name) ---
    String categoryName = "Chưa phân loại";
    try {
      final catObj = json['event_category'];

      if (catObj != null) {
        categoryName = catObj['Title'] ?? "Chưa phân loại";
      }
    } catch (e) {
      print("Lỗi parse category: $e");
    }

    DateTime parsedDate = DateTime.now();
    parsedDate = DateTime.tryParse(attributes['Date']) ?? DateTime.now();

    return Event(
      id: json['id'] ?? 0,
      name: evtName,
      description: attributes['description'] ?? attributes['Description'] ?? '',
      imageUrl: imgUrl,
      date: parsedDate,
      categoryName: categoryName,
      documentId: documentId
    );
  }
}