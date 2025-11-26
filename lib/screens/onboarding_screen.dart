import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'English';
  bool _locationEnabled = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Klinik Assistant',
      description: 'Your AI-powered clinic companion for instant answers and appointments',
      imagePath: 'assets/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Choose Your Language',
      description: 'Pilih bahasa pilihan anda',
      imagePath: 'assets/onboarding_2.png',
      isLanguageSelector: true,
    ),
    OnboardingPage(
      title: 'Enable Location Services',
      description: 'Find clinics near you for easier access',
      imagePath: 'assets/onboarding_3.png',
      isLocationSelector: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
            // Skip button at top right
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 16,
                right: 24,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.greyText,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          // Image without background container
          SizedBox(
            width: 320,
            height: 320,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(flex: 1),
          // Text content aligned to left
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.greyText,
                ),
            textAlign: TextAlign.left,
          ),
          if (page.isLanguageSelector) ...[
            const SizedBox(height: 32),
            _buildLanguageSelector(),
          ],
          if (page.isLocationSelector) ...[
            const SizedBox(height: 32),
            _buildLocationButton(),
          ],
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      children: [
        _buildLanguageOption('🇬🇧 English', 'English'),
        const SizedBox(height: 16),
        _buildLanguageOption('🇲🇾 Bahasa Melayu', 'Bahasa Melayu'),
      ],
    );
  }

  Widget _buildLanguageOption(String label, String value) {
    final isSelected = _selectedLanguage == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.darkText,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _locationEnabled = !_locationEnabled;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_locationEnabled 
              ? 'Location services enabled' 
              : 'Location services disabled'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _locationEnabled ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _locationEnabled ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.my_location,
              color: _locationEnabled ? Colors.white : AppTheme.darkText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enable Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _locationEnabled ? Colors.white : AppTheme.darkText,
                ),
              ),
            ),
            if (_locationEnabled)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _pages.length - 1;
    final indicatorColor = isLastPage ? AppTheme.primaryBlue : AppTheme.darkText;
    final buttonColor = isLastPage ? AppTheme.primaryBlue : AppTheme.darkText;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress indicators at bottom left
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? indicatorColor
                      : indicatorColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Next button or Get Started button
          if (_currentPage < _pages.length - 1)
            // Forward arrow in circle
            GestureDetector(
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )
          else
            // Get Started button with fit content width
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Get Started'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final bool isLanguageSelector;
  final bool isLocationSelector;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLanguageSelector = false,
    this.isLocationSelector = false,
  });
}

