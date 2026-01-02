class CreateEventRequest {
  final String name;
  final String description;
  final DateTime date;
  final int categoryId;
  final int imageId; // <--- ADDED: ID of the uploaded image

  CreateEventRequest({
    required this.name,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.imageId, // <--- ADDED
  });

  Map<String, dynamic> toJson() {
    return {
      "data": {
        "Name": name,
        "Description": description,
        "Date": date.toIso8601String(),
        "event_category": categoryId,
        "Image": imageId, // <--- Link the image ID here (Field name must match Strapi)
      }
    };
  }

  // --- VALIDATIONS ---

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Event name is required';
    if (value.length < 5) return 'Name must be at least 5 characters';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Description is required';
    if (value.length < 20) return 'Description must be at least 20 characters';
    return null;
  }

  static String? validateDate(DateTime? date) {
    if (date == null) return 'Please select a date';
    if (date.isBefore(DateTime.now())) return 'Event date must be in the future';
    return null;
  }

  static String? validateCategory(int? id) {
    if (id == null || id <= 0) return 'Please select a category';
    return null;
  }

  static String? validateImage(int? id) {
    if (id == null || id <= 0) return 'Please upload an image';
    return null;
  }
}