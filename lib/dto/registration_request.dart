class RegistrationRequest {
  final String fullName;
  final String email;
  final String phone;
  final int eventId; // ID của sự kiện muốn đăng ký

  RegistrationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.eventId,
  });

  // Chuyển Object thành JSON để gửi lên Strapi
  Map<String, dynamic> toJson() {
    return {
      "data": { // Strapi yêu cầu dữ liệu phải nằm trong object "data"
        "FullName": fullName,
        "Email": email,
        "Phone": phone,
        "event": eventId, // Relation field
      }
    };
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập Email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  // Validate Phone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'SĐT chỉ được chứa số';
    }
    if (value.length < 10 || value.length > 11) {
      return 'SĐT phải từ 10-11 số';
    }
    return null;
  }

  // Validate Name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.trim().length < 2) {
      return 'Tên quá ngắn (tối thiểu 2 ký tự)';
    }
    return null;
  }
}