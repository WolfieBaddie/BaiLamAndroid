import 'package:flutter/material.dart';
import '../../models/category_model.dart'; // Adjust path if needed

class CategoryFilterModal extends StatefulWidget {
  final List<Category> categories;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onApply;

  const CategoryFilterModal({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<CategoryFilterModal> createState() => _CategoryFilterModalState();
}

class _CategoryFilterModalState extends State<CategoryFilterModal> {
  late List<int> _tempSelectedIds;
  String _localSearch = "";

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter categories by local search
    final filteredCategories = widget.categories.where((c) {
      return c.name.toLowerCase().contains(_localSearch.toLowerCase());
    }).toList();

    // 2. Logic for "Select All" checkbox state
    // It is true only if ALL currently visible categories are selected
    final bool isAllSelected = filteredCategories.isNotEmpty &&
        filteredCategories.every((c) => _tempSelectedIds.contains(c.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => setState(() => _localSearch = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
                hintText: "Search categories...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- "Select All" Option ---
          if (filteredCategories.isNotEmpty)
            CheckboxListTile(
              value: isAllSelected,
              activeColor: const Color(0xFF6366F1),
              checkColor: Colors.white,
              title: const Text(
                "Select All",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    // Select all VISIBLE categories
                    for (var cat in filteredCategories) {
                      if (!_tempSelectedIds.contains(cat.id)) {
                        _tempSelectedIds.add(cat.id);
                      }
                    }
                  } else {
                    // Deselect all VISIBLE categories
                    for (var cat in filteredCategories) {
                      _tempSelectedIds.remove(cat.id);
                    }
                  }
                });
              },
            ),

          if (filteredCategories.isNotEmpty)
            Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // --- Category List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                final isSelected = _tempSelectedIds.contains(cat.id);

                return CheckboxListTile(
                  value: isSelected,
                  activeColor: const Color(0xFF6366F1),
                  checkColor: Colors.white,
                  title: Text(
                    cat.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelectedIds.add(cat.id);
                      } else {
                        _tempSelectedIds.remove(cat.id);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // --- Footer Actions ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _tempSelectedIds.clear());
                  },
                  child: const Text("Reset", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelectedIds);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}