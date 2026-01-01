class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    // 1. Lấy attributes (Hỗ trợ cả v4 và v5/flatten)
    final attributes = json['attributes'] ?? json;

    // 2. Tìm trường tên đúng.
    // Ưu tiên 'name', nếu không có thì tìm 'Title' (như log của bạn), hoặc 'Name'
    String parsedName = "Không tên";

    if (attributes['name'] != null) {
      parsedName = attributes['name'];
    } else if (attributes['Title'] != null) { // <--- SỬA TẠI ĐÂY: Khớp với Strapi của bạn
      parsedName = attributes['Title'];
    } else if (attributes['Name'] != null) {
      parsedName = attributes['Name'];
    }

    return Category(
      id: json['id'] ?? 0,
      name: parsedName,
    );
  }
}