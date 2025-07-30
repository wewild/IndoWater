import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/storage_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Welcome to IndoWater',
      description: 'The smart way to manage your prepaid water meter',
      image: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'Monitor Usage',
      description: 'Track your water consumption in real-time and view historical data',
      image: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'Easy Payments',
      description: 'Top up your balance and pay your bills with just a few taps',
      image: 'assets/images/onboarding_3.png',
    ),
    OnboardingItem(
      title: 'QR Code Scanning',
      description: 'Scan your meter QR code to quickly add meters and submit readings',
      image: 'assets/images/onboarding_4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: Constants.shortAnimationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    await storageService.setBool(Constants.onboardingKey, true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(Constants.paddingMedium),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(Constants.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Image.asset(
                          item.image,
                          height: size.height * 0.3,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: Constants.marginLarge),
                        // Title
                        Text(
                          item.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        // Description
                        Text(
                          item.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                (index) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.primaryColor
                        : theme.dividerColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Constants.marginLarge),
            // Next button
            Padding(
              padding: const EdgeInsets.all(Constants.paddingLarge),
              child: AppButton(
                text: _currentPage == _onboardingItems.length - 1 ? 'Get Started' : 'Next',
                onPressed: _nextPage,
                isFullWidth: true,
                size: ButtonSize.large,
                icon: _currentPage == _onboardingItems.length - 1 ? Icons.check : Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}