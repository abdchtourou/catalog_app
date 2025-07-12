import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/route/app_routes.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/network/service_locator.dart';
import '../category/presentation/cubit/categories_cubit.dart';
import '../category/presentation/cubit/categories_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation
    _backgroundController.forward();

    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Start text animation after logo animation starts
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Navigate to home after all animations complete
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CategoriesCubit>()..getCategories(isInitialLoad: true),
      child: Scaffold(
        body: BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            // When categories are loaded successfully, we can continue with navigation
            if (state is CategoriesLoaded) {
              // Categories are now loaded and cached
              // The navigation will happen after the animation completes
            } else if (state is CategoriesError) {
              // Even if categories fail to load, we should still navigate
              // The categories screen will handle the error state
            }
          },
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFC1D4).withOpacity(_backgroundAnimation.value),
                      Color(0xFFFF8A95).withOpacity(_backgroundAnimation.value),
                      Color(0xFFFF6B7A).withOpacity(_backgroundAnimation.value),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo section
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Opacity(
                                opacity: _logoFadeAnimation.value,
                                child: Container(
                                  width:
                                      ResponsiveUtils.isMobile(context)
                                          ? 120
                                          : ResponsiveUtils.isTablet(context)
                                          ? 150
                                          : 180,
                                  height:
                                      ResponsiveUtils.isMobile(context)
                                          ? 120
                                          : ResponsiveUtils.isTablet(context)
                                          ? 150
                                          : 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Image.asset(
                                        'assets/Logo-AM-1-medium.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            40,
                          ),
                        ),

                        // App name and tagline
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textFadeAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'Catalog App',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.isMobile(context)
                                              ? 32
                                              : ResponsiveUtils.isTablet(
                                                context,
                                              )
                                              ? 40
                                              : 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          12,
                                        ),
                                  ),
                                  Text(
                                    'Your Digital Catalog Solution',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.isMobile(context)
                                              ? 16
                                              : ResponsiveUtils.isTablet(
                                                context,
                                              )
                                              ? 18
                                              : 20,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white.withOpacity(0.9),
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            60,
                          ),
                        ),

                        // Loading indicator with status
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textFadeAnimation.value,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width:
                                        ResponsiveUtils.isMobile(context)
                                            ? 30
                                            : ResponsiveUtils.isTablet(context)
                                            ? 35
                                            : 40,
                                    height:
                                        ResponsiveUtils.isMobile(context)
                                            ? 30
                                            : ResponsiveUtils.isTablet(context)
                                            ? 35
                                            : 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  BlocBuilder<CategoriesCubit, CategoriesState>(
                                    builder: (context, state) {
                                      String statusText = 'Loading...';
                                      if (state is CategoriesLoading) {
                                        statusText = 'Loading categories...';
                                      } else if (state is CategoriesLoaded) {
                                        statusText = 'Categories loaded!';
                                      } else if (state is CategoriesError) {
                                        statusText = 'Ready to start';
                                      }

                                      return Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveUtils.isMobile(context)
                                                  ? 12
                                                  : ResponsiveUtils.isTablet(
                                                    context,
                                                  )
                                                  ? 14
                                                  : 16,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w300,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
