import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../dto/create_event_request.dart';
import '../models/category_model.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // --- Theme Colors ---
  final Color _backgroundColor = const Color(0xFF111827);
  final Color _surfaceColor = const Color(0xFF1F2937);
  final Color _primaryColor = const Color(0xFF6366F1);

  // --- State Variables ---
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final EventService _eventService = EventService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  File? _selectedImage;
  DateTime? _selectedDate;
  int? _selectedCategoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _eventService.getCategories();
    if (mounted) {
      setState(() => _categories = cats);
    }
  }

  // --- Actions ---

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  // UPDATED: Select Date AND Time
  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now.add(const Duration(days: 1));

    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _surfaceColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _surfaceColor,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    // 2. Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime(now.year, now.month, now.day, 9, 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _surfaceColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _surfaceColor,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: _surfaceColor,
              dialHandColor: _primaryColor,
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              entryModeIconColor: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Combine Date & Time
    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom Validations
    if (_selectedImage == null) {
      _showSnack("Please upload an event cover image", isError: true);
      return;
    }
    if (_selectedDate == null) {
      _showSnack("Please select an event date & time", isError: true);
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnack("Please select a category", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Upload Image
      final imageId = await _eventService.uploadImage(_selectedImage!);

      if (imageId == null) {
        throw Exception("Image upload failed");
      }

      // Step 2: Create Event
      final request = CreateEventRequest(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate!,
        categoryId: _selectedCategoryId!,
        imageId: imageId,
      );

      await _eventService.createEvent(request);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) _showSnack("Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red[900] : _primaryColor,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        content: const Text(
          "Event Created Successfully!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              // Reset Form
              _nameCtrl.clear();
              _descCtrl.clear();
              setState(() {
                _selectedImage = null;
                _selectedDate = null;
                _selectedCategoryId = null;
              });
              // Ideally navigate back to Home tab here
            },
            child: Text("OK", style: TextStyle(color: _primaryColor, fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Padding for BottomNav
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Event",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),

                // --- 1. IMAGE UPLOAD AREA ---
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedImage == null ? Colors.white.withOpacity(0.1) : _primaryColor,
                        width: 1,
                      ),
                      image: _selectedImage != null
                          ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey[500]),
                        const SizedBox(height: 8),
                        Text("Tap to upload cover image", style: TextStyle(color: Colors.grey[400])),
                      ],
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // --- 2. FORM FIELDS ---
                _buildLabel("Event Name"),
                _buildTextField(controller: _nameCtrl, hint: "e.g. Tech Summit 2024"),

                const SizedBox(height: 16),
                _buildLabel("Description"),
                _buildTextField(controller: _descCtrl, hint: "Event details...", maxLines: 4),

                const SizedBox(height: 16),

                // --- 3. DATE & CATEGORY ROW ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Date & Time"), // Updated Label
                          GestureDetector(
                            onTap: _selectDateTime, // Updated Handler
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _selectedDate == null
                                          ? "Select"
                                          : DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDate!), // Format includes time
                                      style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Category"),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedCategoryId,
                                hint: Text("Select", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                                dropdownColor: _surfaceColor,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                                items: _categories.map((cat) {
                                  return DropdownMenuItem<int>(
                                    value: cat.id,
                                    child: Text(cat.name, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedCategoryId = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- 4. SUBMIT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Create Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
      ),
    );
  }
}