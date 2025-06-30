import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../category/domain/entities/category.dart';

class CategoryDropdownField extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category?) onChanged;
  final String? Function(Category?)? validator;
  final String labelText;
  final String? hintText;
  final bool enabled;

  const CategoryDropdownField({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    this.validator,
    this.labelText = 'Category',
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: labelText.tr(),
        hintText: hintText?.tr() ?? 'Select a category'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        prefixIcon: const Icon(Icons.category),
      ),
      items: categories.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category.parentId != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Sub',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 8,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      dropdownColor: Colors.white,
    );
  }
}

// Predefined validators for category dropdown
class CategoryDropdownValidators {
  static String? Function(Category?) required() {
    return (value) => value == null
        ? 'Please select a category'.tr()
        : null;
  }

  static String? Function(Category?) requiredWithMessage(String message) {
    return (value) => value == null ? message.tr() : null;
  }
}

// Helper widget for hierarchical category display
class HierarchicalCategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category?) onChanged;
  final String? Function(Category?)? validator;
  final String labelText;
  final bool enabled;

  const HierarchicalCategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    this.validator,
    this.labelText = 'Category',
    this.enabled = true,
  });

  List<Category> get _sortedCategories {
    final List<Category> sorted = [];
    final Map<int?, List<Category>> categoryMap = {};

    // Group categories by parent
    for (final category in categories) {
      categoryMap.putIfAbsent(category.parentId, () => []).add(category);
    }

    // Add root categories first
    final rootCategories = categoryMap[null] ?? [];
    rootCategories.sort((a, b) => a.name.compareTo(b.name));

    for (final rootCategory in rootCategories) {
      sorted.add(rootCategory);
      
      // Add subcategories
      final subcategories = categoryMap[rootCategory.id] ?? [];
      subcategories.sort((a, b) => a.name.compareTo(b.name));
      sorted.addAll(subcategories);
    }

    return sorted;
  }

  String _getCategoryDisplayName(Category category) {
    if (category.parentId == null) {
      return category.name;
    } else {
      // Find parent category name
      final parent = categories.firstWhere(
        (c) => c.id == category.parentId,
        orElse: () => Category(
          id: 0,
          name: 'Unknown',
          imagePath: '',
          parentId: null,
        ),
      );
      return '  └ ${category.name}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = _sortedCategories;

    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: labelText.tr(),
        hintText: 'Select a category'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        prefixIcon: const Icon(Icons.category),
      ),
      items: sortedCategories.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(
            _getCategoryDisplayName(category),
            style: TextStyle(
              fontWeight: category.parentId == null 
                  ? FontWeight.w600 
                  : FontWeight.normal,
              color: category.parentId == null 
                  ? Colors.black87 
                  : Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 8,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      dropdownColor: Colors.white,
    );
  }
}
