import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/productcubit/product_cubit.dart';
import '../cubit/products_cubit.dart';
import '../widgets/widgets.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final bool isAdmin;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.isAdmin = true,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _contentController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is SingleProductDeleted) {
          // Product was deleted successfully, navigate back with result
          _showSuccessSnackBar('Product deleted successfully');
          context.pop(true);
        } else if (state is ProductError && state.message.contains('delete')) {
          // Show error message for delete failures
          _showErrorSnackBar('Failed to delete product: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is ProductLoading) {
          return _buildLoadingScreen(context);
        }

        if (state is ProductLoaded) {
          final product = state.product;
          final cubit = context.read<ProductCubit>();
          final images =
              product.attachments.isNotEmpty
                  ? product.attachments
                      .map((attachment) => attachment.path)
                      .toList()
                  : ['placeholder']; // Fallback for products without images

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: CustomAppBar(
              title: product.name,
              showSearch: false,
              showDrawer: false,
            ),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: ResponsiveUtils.getResponsiveSpacing(context, 16),
                      right: ResponsiveUtils.getResponsiveSpacing(context, 16),
                      bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
                      // No top padding to eliminate space between AppBar and image
                    ),
                    child: Column(
                      children: [
                        // Enhanced product image carousel
                        _buildImageCarousel(context, product, cubit, images),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            24,
                          ),
                        ),

                        // Enhanced product details section
                        _buildProductDetails(context, product),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (state is ProductError) {
          return _buildErrorScreen(context, state.message);
        }

        return _buildLoadingScreen(context);
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Loading...',
        showSearch: false,
        showDrawer: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 40),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      32,
                    ),
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 100),
                    height: ResponsiveUtils.getResponsiveSpacing(context, 100),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveSpacing(context, 50),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth:
                            ResponsiveUtils.isTablet(context) ? 4.0 : 3.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 32),
                  ),
                  Text(
                    'Loading Product Details',
                    style: TextStyle(
                      fontSize:
                          24 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  Text(
                    'Please wait while we fetch the product information',
                    style: TextStyle(
                      fontSize:
                          16 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Error',
        showSearch: false,
        showDrawer: false,
      ),
      body: Center(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 40),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        32,
                      ),
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(context, 24),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.1),
                            Colors.red.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            20,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          80,
                        ),
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 28),
                    ),
                    Text(
                      'Failed to Load Product',
                      style: TextStyle(
                        fontSize:
                            24 * ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize:
                            16 * ResponsiveUtils.getFontSizeMultiplier(context),
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 32),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: ResponsiveUtils.getResponsiveButtonHeight(
                              context,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveBorderRadius(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                'Go Back',
                                style: TextStyle(
                                  fontSize:
                                      16 *
                                      ResponsiveUtils.getFontSizeMultiplier(
                                        context,
                                      ),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            16,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: ResponsiveUtils.getResponsiveButtonHeight(
                              context,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                              ),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveBorderRadius(
                                  context,
                                  16,
                                ),
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<ProductCubit>().getProduct(
                                  widget.productId,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize:
                                      16 *
                                      ResponsiveUtils.getFontSizeMultiplier(
                                        context,
                                      ),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(
    BuildContext context,
    product,
    cubit,
    List<String> images,
  ) {
    // Calculate two-thirds of screen height minus AppBar height
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 70.0; // CustomAppBar height for non-search
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;
    final imageHeight =
        availableHeight * 0.67; // Two-thirds of available height

    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        // Remove top border radius to connect seamlessly with AppBar
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 24),
          ),
          bottomRight: Radius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 24),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 24),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        // Apply same border radius as container
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 24),
          ),
          bottomRight: Radius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 24),
          ),
        ),
        child: ProductImageCarousel(
          images: images,
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          isAdmin: widget.isAdmin,
          product: product,
          onImageDeleted: (index) {
            if (index >= 0 && index < product.attachments.length) {
              final attachmentId = product.attachments[index].id;
              cubit.deleteAttachment(attachmentId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 24),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ProductDetailsSection(
        product: product,
        contentFadeAnimation: _contentFadeAnimation,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
