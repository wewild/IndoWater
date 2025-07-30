import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/services/storage_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: Constants.mediumAnimationDuration,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate to next screen after delay
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final storageService = Provider.of<StorageService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if onboarding is completed
    final onboardingCompleted = await storageService.getBool(Constants.onboardingKey) ?? false;
    
    if (!onboardingCompleted) {
      // Navigate to onboarding screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }
    
    // Check if user is logged in
    final isLoggedIn = await authProvider.isLoggedIn();
    
    if (isLoggedIn) {
      // Navigate to dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  isDarkMode ? 'assets/images/logo_dark.png' : 'assets/images/logo_light.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: Constants.marginLarge),
                // App name
                Text(
                  Constants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: Constants.marginMedium),
                // Tagline
                Text(
                  'Prepaid Water Meter Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: Constants.marginExtraLarge),
                // Loading indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}