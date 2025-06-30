import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/cache/image_cache_service.dart';
import '../../domain/entities/attachment.dart';
import 'image_source_dialog.dart';

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

class MultiImagePicker extends StatefulWidget {
  final List<Attachment> initialAttachments;
  final Function(List<File> newImages, List<int> deletedAttachmentIds)
  onImagesChanged;
  final int maxImages;
  final int maxImageSizeMB;

  const MultiImagePicker({
    super.key,
    this.initialAttachments = const [],
    required this.onImagesChanged,
    this.maxImages = 10,
    this.maxImageSizeMB = 5,
  });

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final List<ImageItem> _images = [];
  final List<File> _newImages = [];
  final List<int> _deletedAttachmentIds = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with existing images from attachments
    _images.addAll(
      widget.initialAttachments.map(
        (attachment) => ImageItem.network(attachment),
      ),
    );
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final normalizedPath = imagePath.replaceAll('\\', '/');
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;
    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  bool _canAddMoreImages() {
    return _images.length < widget.maxImages;
  }

  Future<bool> _validateImageSize(File imageFile) async {
    try {
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      return fileSizeInMB <= widget.maxImageSizeMB;
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
            '${'You can only add up to'.tr()} ${widget.maxImages} ${'images per product.'.tr()}',
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
            '${'Please select an image smaller than'.tr()} ${widget.maxImageSizeMB}${'MB.'.tr()}',
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

        if (!await _validateImageSize(imageFile)) {
          _showImageSizeDialog();
          return;
        }

        setState(() {
          _images.add(ImageItem.local(imageFile));
          _newImages.add(imageFile);
        });

        _notifyChanges();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image captured successfully'.tr()),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
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

        final remainingSlots = widget.maxImages - _images.length;
        final imagesToProcess = pickedFiles.take(remainingSlots).toList();

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

          _notifyChanges();
        }

        if (mounted) {
          if (validImages.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${validImages.length} image(s) added successfully',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (invalidImages.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${invalidImages.length} image(s) were too large (max ${widget.maxImageSizeMB}MB)',
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
                  '${'Only'.tr()} $remainingSlots ${'image(s) could be added (max'.tr()} ${widget.maxImages} ${'total)'.tr()}',
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

  void _removeImage(int index) {
    final imageItem = _images[index];

    setState(() {
      if (imageItem.isLocal) {
        _newImages.removeWhere((file) => file.path == imageItem.localPath);
      } else {
        _deletedAttachmentIds.add(imageItem.attachmentId!);
      }
      _images.removeAt(index);
    });

    _notifyChanges();

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

  void _notifyChanges() {
    widget.onImagesChanged(_newImages, _deletedAttachmentIds);
  }

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 12),
        // Image grid/list will be implemented in the next part
        _buildImagePreview(),
      ],
    );
  }

  Widget _buildImagePreview() {
    final imageSize = ResponsiveUtils.getResponsiveSpacing(context, 100.0);

    return SizedBox(
      height: ResponsiveUtils.getResponsiveSpacing(context, 120.0),
      child: Row(
        children: [
          // Add image button
          if (_canAddMoreImages())
            GestureDetector(
              onTap:
                  () => ImageSourceDialog.show(
                    context: context,
                    onCameraSelected: _pickImageFromCamera,
                    onGallerySelected: _pickImagesFromGallery,
                  ),
              child: Container(
                width: imageSize,
                height: imageSize,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add'.tr(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize:
                            12 * ResponsiveUtils.getFontSizeMultiplier(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Image list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imageItem = _images[index];
                return Container(
                  width: imageSize,
                  height: imageSize,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            imageItem.isLocal
                                ? Image.file(
                                  File(imageItem.localPath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                : ImageCacheService.getCachedImage(
                                  imageUrl: imageItem.attachment!.path,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (!imageItem.isLocal)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Existing'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    10 *
                                    ResponsiveUtils.getFontSizeMultiplier(
                                      context,
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
