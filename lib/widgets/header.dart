import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart'; // Adjust path if needed
import 'filter_button.dart';
import 'category_filter_modal.dart';

class HeaderWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelect;

  final List<Category> availableCategories;
  final List<int> selectedCategoryIds;
  final ValueChanged<List<int>> onCategoriesChanged;

  final String searchTerm;
  final ValueChanged<String> onSearchChange;

  const HeaderWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelect,
    required this.availableCategories,
    required this.selectedCategoryIds,
    required this.onCategoriesChanged,
    required this.searchTerm,
    required this.onSearchChange,
  });

  // --- ACTIONS ---

  void _showDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1F2937),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1F2937),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelect(picked);
    }
  }

  void _showCategoryFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFilterModal(
        categories: availableCategories,
        selectedIds: selectedCategoryIds,
        onApply: onCategoriesChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color surfaceLight = Color(0xFF1F2937);
    const Color backgroundColor = Color(0xFF111827);

    String dateText = "Select Date";
    if (selectedDate != null) {
      dateText = DateFormat('EEE, MMM d, yyyy').format(selectedDate!);
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Discover\nEvents",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  image: const DecorationImage(
                    image: NetworkImage("https://picsum.photos/id/64/200/200"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Search Bar ---
          Container(
            decoration: BoxDecoration(
              color: surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              onChanged: onSearchChange,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search events...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Filter Buttons ---
          Row(
            children: [
              // Date Button
              Expanded(
                flex: 3,
                child: FilterButton(
                  icon: Icons.calendar_today_outlined,
                  label: dateText,
                  isActive: selectedDate != null,
                  onTap: () => _showDatePicker(context),
                  onClear: selectedDate != null
                      ? () => onDateSelect(null)
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Category Filter Button
              Expanded(
                flex: 2,
                child: FilterButton(
                  icon: Icons.tune,
                  label: "Filters ${selectedCategoryIds.isNotEmpty ? '(${selectedCategoryIds.length})' : ''}",
                  isActive: selectedCategoryIds.isNotEmpty,
                  onTap: () => _showCategoryFilterModal(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}