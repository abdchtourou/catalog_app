import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';

class ImagePickerSection extends StatefulWidget {
  final File? initialImageFile;
  final String? initialImageUrl;
  final Function(File?) onImageChanged;
  final String? placeholderText;
  final double height;

  const ImagePickerSection({
    super.key,
    this.initialImageFile,
    this.initialImageUrl,
    required this.onImageChanged,
    this.placeholderText,
    this.height = 150,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.initialImageFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        final newImageFile = File(pickedFile.path);
        setState(() {
          _imageFile = newImageFile;
        });
        widget.onImageChanged(newImageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}'.tr())),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Image Options'.tr()),
        actions: [
          if (_imageFile != null || 
              (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _imageFile = null;
                });
                widget.onImageChanged(null);
              },
              child: Text(
                'Remove Image'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Text('Camera'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          widget.placeholderText ?? 
          ((_imageFile != null || (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty))
              ? 'Change Image'.tr()
              : 'Add Image'.tr()),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.baseImageUrl + widget.initialImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
      ),
    );
  }
}
