import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/custom_text_form_field.dart';
import '../../../../core/shared_widgets/form_submit_button.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/image_picker_section.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  final int? parentId; // ✅ NEW: Support for hierarchical categories

  const CategoryFormScreen({super.key, this.category, this.parentId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _colorController = TextEditingController();
  File? _imageFile;
  Category? _parentCategory;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation
    _animationController.forward();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _nameArabicController.text = widget.category!.nameArabic ?? '';
      _colorController.text = widget.category!.color ?? '#FFFFFF';
    } else {
      _colorController.text = '#FFFFFF'; // Default color for new categories
    }

    // Load parent category if parentId is provided
    if (widget.parentId != null) {
      _loadParentCategory();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArabicController.dispose();
    _colorController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onImageChanged(File? imageFile) {
    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _loadParentCategory() async {
    if (widget.parentId == null) return;

    try {
      final cubit = context.read<CategoriesCubit>();
      await cubit.getSingleCategory(widget.parentId!);

      // Listen for the category result
      final state = context.read<CategoriesCubit>().state;
      if (state is CategoryLoaded) {
        setState(() {
          _parentCategory = state.category;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.category == null && _imageFile == null) {
      _showSnackBar('Please select an image'.tr(), isError: true);
      return;
    }

    final cubit = context.read<CategoriesCubit>();
    final name = _nameController.text.trim();
    final nameArabic = _nameArabicController.text.trim();
    final color = _colorController.text.trim();

    if (widget.category == null) {
      cubit.createCategory(
        name,
        _imageFile!,
        parentId: widget.parentId,
        nameArabic: nameArabic.isEmpty ? null : nameArabic,
        color: color.isEmpty ? null : color,
      );
    } else {
      cubit.updateCategory(
        widget.category!.id,
        name,
        _imageFile!, // Can be null to keep existing image
        parentId: widget.parentId ?? widget.category!.parentId,
        nameArabic: nameArabic.isEmpty ? null : nameArabic,
        color: color.isEmpty ? null : color,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesFormSuccess) {
          _showSnackBar('Success!'.tr());
          Navigator.pop(context, true);
        } else if (state is CategoriesFormError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context, isEditing),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8FAFC),
                const Color(0xFFE2E8F0).withOpacity(0.3),
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(
                    context,
                  ).copyWith(
                    top: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                    bottom: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                      ),
                      child: _buildFormCard(context, isEditing),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isEditing) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B)),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing
                ? 'Edit Category'.tr()
                : widget.parentId != null
                ? 'Add Subcategory'.tr()
                : 'Add Category'.tr(),
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildFormHeader(context, isEditing),

              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
              ),

              // Image picker section
              _buildImageSection(context),

              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              ),

              // Form fields section
              _buildFormFields(context),

              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
              ),

              // Submit button section
              _buildSubmitSection(context, isEditing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context, bool isEditing) {
    final isSubcategory = widget.parentId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 6.0),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF8A95).withOpacity(0.1),
                const Color(0xFFFF6B7A).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
            ),
          ),
          child: Text(
            isEditing
                ? 'UPDATE CATEGORY'.tr()
                : isSubcategory
                ? 'NEW SUBCATEGORY'.tr()
                : 'NEW CATEGORY'.tr(),
            style: TextStyle(
              fontSize: 12.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF8A95),
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
        Text(
          isEditing
              ? 'Update category information'.tr()
              : isSubcategory
              ? 'Create a new subcategory'.tr()
              : 'Create a new category for your products'.tr(),
          style: TextStyle(
            fontSize: 16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        if (isSubcategory && !isEditing) ...[
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          _buildParentCategoryInfo(context),
        ],
      ],
    );
  }

  Widget _buildParentCategoryInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_tree,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creating subcategory under:'.tr(),
                  style: TextStyle(
                    fontSize:
                        12.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _parentCategory?.name ??
                      '${'Parent Category (ID:'.tr()} ${widget.parentId})',
                  style: TextStyle(
                    fontSize:
                        14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Category Image'.tr(),
              style: TextStyle(
                fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 14.0),
            ),
            child: ImagePickerSection(
              initialImageFile: _imageFile,
              initialImageUrl: widget.category?.imagePath,
              onImageChanged: _onImageChanged,
              height: ResponsiveUtils.isMobile(context) ? 200 : 250,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.text_fields_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Category Details'.tr(),
              style: TextStyle(
                fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

        // Name field
        _buildFormField(
          context,
          controller: _nameController,
          label: 'Category Name'.tr(),
          hint: 'Enter category name'.tr(),
          icon: Icons.label_outline_rounded,
          validator: FormValidators.required('name'),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

        // Arabic Name field
        _buildFormField(
          context,
          controller: _nameArabicController,
          label: 'Arabic Name (Optional)'.tr(),
          hint: 'Enter Arabic name'.tr(),
          icon: Icons.language_outlined,
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

        // Color field
        _buildColorField(context),
      ],
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
            ),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A95).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFFF8A95), size: 20),
              ),
              Expanded(
                child: CustomTextFormField(
                  controller: controller,
                  labelText: hint,
                  maxLines: maxLines,
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorField(BuildContext context) {
    final List<String> predefinedColors = [
      '#9ED9D5', // Teal
      '#FEC78F', // Orange
      '#FFE38F', // Yellow
      '#FDB9A7', // Peach
      '#E7DDCB', // Beige
      '#AED6C1', // Green
      '#D7BDE2', // Purple
      '#AED6F1', // Blue
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color'.tr(),
          style: TextStyle(
            fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
            ),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            children: [
              // Header with icon and selected color preview
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A95).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: Color(0xFFFF8A95),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Selected Color:'.tr(),
                      style: TextStyle(
                        fontSize:
                            14.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseColorFromString(_colorController.text),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _colorController.text.toUpperCase(),
                      style: TextStyle(
                        fontSize:
                            12.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Color grid
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.isMobile(context) ? 4 : 8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: predefinedColors.length,
                  itemBuilder: (context, index) {
                    final colorHex = predefinedColors[index];
                    final isSelected =
                        _colorController.text.toUpperCase() ==
                        colorHex.toUpperCase();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _colorController.text = colorHex;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _parseColorFromString(colorHex),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE2E8F0),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: _parseColorFromString(
                                        colorHex,
                                      ).withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _parseColorFromString(String colorString) {
    try {
      if (colorString.isEmpty) return const Color(0xFFFFFFFF);
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
    } catch (e) {
      // If parsing fails, return white
    }
    return const Color(0xFFFFFFFF);
  }

  Widget _buildSubmitSection(BuildContext context, bool isEditing) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final isLoading = state is CategoriesFormSubmitting;

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A95).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
                    ),
                  ),
                ),
                child:
                    isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEditing
                                  ? 'Updating...'.tr()
                                  : 'Creating...'.tr(),
                              style: TextStyle(
                                fontSize:
                                    16.0 *
                                    ResponsiveUtils.getFontSizeMultiplier(
                                      context,
                                    ),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing
                                  ? Icons.update_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing
                                  ? 'Update Category'.tr()
                                  : widget.parentId != null
                                  ? 'Create Subcategory'.tr()
                                  : 'Create Category'.tr(),
                              style: TextStyle(
                                fontSize:
                                    16.0 *
                                    ResponsiveUtils.getFontSizeMultiplier(
                                      context,
                                    ),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            if (!isEditing) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              ),
              Text(
                'Make sure to add a clear image and descriptive name'.tr(),
                style: TextStyle(
                  fontSize:
                      14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}
