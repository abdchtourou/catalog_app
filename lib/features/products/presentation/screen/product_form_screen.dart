import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/attachment.dart';
import '../cubit/products_cubit.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/screen_size.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/cache/image_cache_service.dart';

// Image item class to handle both network and local images
class ImageItem {
  final String? localPath; // For new images (File path)
  final Attachment? attachment; // For existing images (from server)
  final bool isLocal;

  ImageItem.local(File file)
    : localPath = file.path,
      attachment = null,
      isLocal = true;

  ImageItem.network(Attachment attachment)
    : localPath = null,
      attachment = attachment,
      isLocal = false;

  String get displayPath => isLocal ? localPath! : attachment!.path;
  int? get attachmentId => isLocal ? null : attachment!.id;
}

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final String? categoryId;

  const ProductFormScreen({super.key, this.product, this.categoryId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final List<ImageItem> _images = [];
  final List<File> _newImages = []; // Only new images for submission
  final List<int> _deletedAttachmentIds = []; // Track deleted existing images
  final ImagePicker _picker = ImagePicker();

  // Image constraints
  static const int maxImages = 10;
  static const int maxImageSizeMB = 5;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();

      // Initialize with existing images from attachments
      _images.addAll(
        widget.product!.attachments.map(
          (attachment) => ImageItem.network(attachment),
        ),
      );
    }
  }

  // Helper method to get full image URL for network images
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    // Convert backslashes to forward slashes for URL
    final normalizedPath = imagePath.replaceAll('\\', '/');
    // Remove leading slash if present to avoid double slashes
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;
    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  // Download existing server image and convert to File object
  Future<File?> _downloadImageAsFile(String imagePath) async {
    try {
      final imageUrl = _getImageUrl(imagePath);
      debugPrint('Downloading image from: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();

        // Create a unique filename
        final fileName =
            'temp_image_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
        final filePath = path.join(tempDir.path, fileName);

        // Write the image data to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        debugPrint('Image downloaded successfully to: $filePath');
        return file;
      } else {
        debugPrint(
          'Failed to download image. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  // Get responsive image grid count
  int _getImageGridCount(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return 3;
    } else if (ResponsiveUtils.isTablet(context)) {
      return 4;
    } else {
      return 6;
    }
  }

  // Get responsive image size
  double _getImageSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = ResponsiveUtils.getResponsivePadding(context).horizontal;
    final containerPadding = ResponsiveUtils.getResponsiveSpacing(
      context,
      20.0,
    );
    final gridCount = _getImageGridCount(context);
    final spacing = 12.0;

    final availableWidth =
        screenWidth -
        padding -
        (containerPadding * 2) -
        (spacing * (gridCount - 1));
    return (availableWidth / gridCount).clamp(80.0, 120.0);
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                ),
                Text(
                  'Select Image Source'.tr(),
                  style: TextStyle(
                    fontSize:
                        18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                ),
                _buildResponsiveSourceOptions(context),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveSourceOptions(BuildContext context) {
    final isWideScreen =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    if (isWideScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSourceOption(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          _buildSourceOption(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () {
              Navigator.pop(context);
              _pickImagesFromGallery();
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSourceOption(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          _buildSourceOption(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () {
              Navigator.pop(context);
              _pickImagesFromGallery();
            },
            isFullWidth: true,
          ),
        ],
      );
    }
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    final buttonWidth =
        isFullWidth
            ? double.infinity
            : ResponsiveUtils.getAdCardWidth(context) * 0.8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child:
            isFullWidth
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        24.0,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:
                            16.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Icon(
                      icon,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        40.0,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:
                            16.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  bool _canAddMoreImages() {
    return _images.length < maxImages;
  }

  Future<bool> _validateImageSize(File imageFile) async {
    try {
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return fileSizeInMB <= maxImageSizeMB;
    } catch (e) {
      return false;
    }
  }

  void _showImageLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Limit Reached'.tr()),
          content: Text(
            '${'You can only add up to'.tr()} $maxImages ${'images per product.'.tr()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showImageSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Too Large'.tr()),
          content: Text(
            '${'Please select an image smaller than'.tr()} $maxImageSizeMB${'MB.'.tr()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    if (!_canAddMoreImages()) {
      _showImageLimitDialog();
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Validate image size
        if (!await _validateImageSize(imageFile)) {
          _showImageSizeDialog();
          return;
        }

        setState(() {
          _images.add(ImageItem.local(imageFile));
          _newImages.add(imageFile);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image captured successfully'.tr()),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'Failed to capture image: '.tr()}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImagesFromGallery() async {
    if (!_canAddMoreImages()) {
      _showImageLimitDialog();
      return;
    }

    try {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFiles.isNotEmpty) {
        final List<File> validImages = [];
        final List<String> invalidImages = [];

        // Calculate how many images we can still add
        final remainingSlots = maxImages - _images.length;
        final imagesToProcess = pickedFiles.take(remainingSlots).toList();

        // Validate each image
        for (final pickedFile in imagesToProcess) {
          final imageFile = File(pickedFile.path);
          if (await _validateImageSize(imageFile)) {
            validImages.add(imageFile);
          } else {
            invalidImages.add(pickedFile.name);
          }
        }

        if (validImages.isNotEmpty) {
          setState(() {
            for (final imageFile in validImages) {
              _images.add(ImageItem.local(imageFile));
              _newImages.add(imageFile);
            }
          });
        }

        if (mounted) {
          // Show success message
          if (validImages.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${validImages.length} ${'image(s) added successfully'.tr()}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Show warnings if needed
          if (invalidImages.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${invalidImages.length} ${'image(s) were too large (max'.tr()} $maxImageSizeMB${'MB)'.tr()}',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          if (pickedFiles.length > remainingSlots) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${'Only'.tr()} $remainingSlots ${'image(s) could be added (max'.tr()} $maxImages ${'total)'.tr()}',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'Failed to pick images: '.tr()}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Validate categoryId
    final categoryId =
        widget.categoryId ?? widget.product?.categoryId.toString();
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category ID is required. Please select a category first.'.tr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // For new products, require at least one image
    if (widget.product == null && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one image for the product'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;

    final cubit = context.read<ProductsCubit>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final categoryId =
        widget.categoryId ?? widget.product?.categoryId.toString();

    // This should not happen due to validation, but adding safety check
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Category ID is missing'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.product == null) {
      // Create new product with images
      cubit.createProductWithImages(
        name,
        description,
        price.toString(),
        categoryId,
        _newImages,
      );
    } else {
      // Update existing product with images and handle deletions
      // First delete any removed attachments
      if (_deletedAttachmentIds.isNotEmpty) {
        cubit.removeMultipleAttachments(_deletedAttachmentIds);
      }

      // Collect ALL images as File objects
      final allImages = <File>[];

      // Process all images in the _images list
      for (final imageItem in _images) {
        if (imageItem.isLocal && imageItem.localPath != null) {
          // Add local images (new images picked from camera/gallery)
          allImages.add(File(imageItem.localPath!));
        } else if (!imageItem.isLocal && imageItem.attachment != null) {
          // For existing server images, we need to download them first
          // and convert to File objects to send them back to the server
          try {
            final downloadedFile = await _downloadImageAsFile(
              imageItem.attachment!.path,
            );
            if (downloadedFile != null) {
              allImages.add(downloadedFile);
            }
          } catch (e) {
            debugPrint('Error downloading existing image: $e');
            // Continue with other images even if one fails
          }
        }
      }

      debugPrint(
        '${'Sending'.tr()} ${allImages.length} ${'images to backend for product update'.tr()}',
      );

      cubit.updateProductWithImages(
        id: widget.product!.id,
        name: name,
        description: description,
        price: price.toString(),
        categoryId: int.tryParse(categoryId),
        images: allImages,
      );
    }
  }

  Widget _buildImagePreview() {
    final imageSize = _getImageSize(context);
    final isWideScreen =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Product Images'.tr(),
              style: TextStyle(
                fontSize: 16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_images.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),

        // Responsive image grid
        if (isWideScreen && _images.isNotEmpty)
          _buildImageGrid(imageSize)
        else
          _buildImageList(imageSize),
      ],
    );
  }

  Widget _buildImageGrid(double imageSize) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._images.asMap().entries.map((entry) {
          return _buildImageItem(entry.key, imageSize);
        }),
        if (_canAddMoreImages()) _buildAddImageButton(imageSize),
      ],
    );
  }

  Widget _buildImageList(double imageSize) {
    return SizedBox(
      height: imageSize + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return _buildAddImageButton(imageSize);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildImageItem(index, imageSize),
          );
        },
      ),
    );
  }

  Widget _buildAddImageButton(double size) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
              color:
                  _canAddMoreImages()
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              _canAddMoreImages() ? 'Add Images'.tr() : 'Limit Reached'.tr(),
              style: TextStyle(
                fontSize: 10.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w500,
                color:
                    _canAddMoreImages()
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_images.isNotEmpty)
              Text(
                '${_images.length}/$maxImages',
                style: TextStyle(
                  fontSize:
                      9.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(int index, double size) {
    final imageItem = _images[index];

    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              child:
                  imageItem.isLocal
                      ? Image.file(
                        File(imageItem.localPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      )
                      : ImageCacheService.getCachedImage(
                        imageUrl: imageItem.attachment!.path,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // Image index indicator
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Network/Local indicator
          if (!imageItem.isLocal)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.cloud, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    final imageItem = _images[index];

    setState(() {
      if (imageItem.isLocal) {
        // Remove from new images list
        _newImages.removeWhere((file) => file.path == imageItem.localPath);
      } else {
        // Add to deleted attachments list for server deletion
        _deletedAttachmentIds.add(imageItem.attachmentId!);
      }
      _images.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imageItem.isLocal
                ? 'New image removed'.tr()
                : 'Existing image will be deleted'.tr(),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenSize
    ScreenSize.init(context);

    final isWideScreen =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Product saved successfully'.tr()),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.pop(true);
        } else if (state is ProductFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            widget.product == null ? 'Add Product'.tr() : 'Edit Product'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(height: 1, color: Colors.grey[200]),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth.toDouble()),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: ResponsiveUtils.getResponsivePadding(context).add(
                  EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      16.0,
                    ),
                  ),
                ),
                child: isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeaderSection(),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

        // Two-column layout for tablet/desktop
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Images
            Expanded(flex: 1, child: _buildImagesSection()),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            ),

            // Right column - Form fields
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildFormFieldsSection(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                  ),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeaderSection(),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

        // Images Section
        _buildImagesSection(),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

        // Form Fields Section
        _buildFormFieldsSection(),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32.0)),

        // Submit Button
        _buildSubmitButton(),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFC1D4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                  ),
                ),
                child: Icon(
                  widget.product == null ? Icons.add_box : Icons.edit,
                  color: Color(0xFFFF8A95),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product == null
                          ? 'Create New Product'.tr()
                          : 'Edit Product'.tr(),
                      style: TextStyle(
                        fontSize:
                            20.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.product == null
                          ? 'Fill in the details to create a new product'.tr()
                          : 'Update the product information'.tr(),
                      style: TextStyle(
                        fontSize:
                            14.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildImagePreview(),
    );
  }

  Widget _buildFormFieldsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Information'.tr(),
            style: TextStyle(
              fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

          // Product Name Field
          _buildFormField(
            controller: _nameController,
            label: 'Product Name'.tr(),
            hint: 'Enter product name'.tr(),
            icon: Icons.inventory_2_outlined,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter a product name'.tr()
                        : null,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

          // Description Field
          _buildFormField(
            controller: _descriptionController,
            label: 'Description'.tr(),
            hint: 'Enter product description'.tr(),
            icon: Icons.description_outlined,
            maxLines: ResponsiveUtils.isMobile(context) ? 3 : 4,
            validator:
                (value) =>
                    value?.isEmpty ?? true
                        ? 'Please enter a description'.tr()
                        : null,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0)),

          // Price Field
          _buildFormField(
            controller: _priceController,
            label: 'Price'.tr(),
            hint: 'Enter price (e.g., 29.99)'.tr(),
            icon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a price'.tr();
              }
              final price = double.tryParse(value!);
              if (price == null || price <= 0) {
                return 'Please enter a valid price'.tr();
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final isLoading = state is ProductFormSubmitting;
        return Container(
          width: double.infinity,
          height: ResponsiveUtils.getResponsiveSpacing(context, 56.0),
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8A95),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
                ),
              ),
              elevation: 4,
              shadowColor: Color(0xFFFF8A95).withValues(alpha: 0.3),
              disabledBackgroundColor: Colors.grey[300],
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
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          widget.product == null
                              ? 'Creating...'.tr()
                              : 'Updating...'.tr(),
                          style: TextStyle(
                            fontSize:
                                16.0 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.product == null ? Icons.add : Icons.save,
                          size: ResponsiveUtils.getResponsiveIconSize(
                            context,
                            20.0,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.product == null
                              ? 'Create Product'.tr()
                              : 'Update Product'.tr(),
                          style: TextStyle(
                            fontSize:
                                16.0 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
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
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Color(0xFFFF8A95),
              size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              borderSide: BorderSide(color: Color(0xFFFF8A95), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
              ),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            ),
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            ),
          ),
          style: TextStyle(
            fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
