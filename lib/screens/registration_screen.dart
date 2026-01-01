import 'package:flutter/material.dart';
import 'package:hello_world/dto/registration_request.dart';
import 'package:hello_world/services/registration_service.dart';
import '../models/event_model.dart';

class RegistrationScreen extends StatefulWidget {
  final Event event;

  const RegistrationScreen({super.key, required this.event});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Theme Constants
  final Color _primaryColor = const Color(0xFF6366F1); // Indigo
  final Color _backgroundColor = const Color(0xFF111827); // Dark Background
  final Color _surfaceColor = const Color(0xFF1F2937); // Dark Surface

  final RegistrationService _service = RegistrationService();
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = RegistrationRequest(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        eventId: widget.event.id,
      );

      await _service.register(request);

      if (mounted) _showSuccessDialog();

    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red[900], // Darker red for dark mode
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor, // Dark dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        content: const Text(
          "Registration Successful!\nWe will contact you shortly.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(fontSize: 18, color: _primaryColor)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Event", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- EVENT INFO CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_note, color: _primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Event:",
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Your Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // --- FORM INPUTS ---
                _buildTextField(
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                  controller: _nameCtrl,
                  validator: RegistrationRequest.validateFullName,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: "Email",
                  hint: "example@email.com",
                  icon: Icons.email_outlined,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: RegistrationRequest.validateEmail,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: "Phone Number",
                  hint: "09xxx...",
                  icon: Icons.phone_outlined,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: RegistrationRequest.validatePhone,
                ),

                const SizedBox(height: 40),

                // --- SUBMIT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: _primaryColor.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      "CONFIRM REGISTRATION",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // Dark Theme Input Decoration
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white), // Input text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}