import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'package:hello_world/dto/registration_request.dart';

class RegistrationService {
  final http.Client client;

  RegistrationService({http.Client? client}) : client = client ?? http.Client();

  Future<bool> register(RegistrationRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.registration);
      print("Posting Registration to: $url");

      // Convert DTO to JSON
      final body = json.encode(request.toJson());
      print("Request Body: $body");

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Strapi returns 200 or 201 for successful creation
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Parse error message from Strapi if available
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['error']?['message'] ?? "Unknown error occurred";
        throw Exception("Failed to register: $errorMessage");
      }
    } catch (e) {
      print("Registration Error: $e");
      rethrow; // Re-throw to be caught by the UI
    }
  }
}