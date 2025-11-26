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

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Klinik Assistant',
      description: 'Your AI-powered clinic companion for instant answers and appointments',
      icon: Icons.waving_hand_rounded,
      color: AppTheme.primaryBlue,
      backgroundColor: AppTheme.lightBlue,
    ),
    OnboardingPage(
      title: 'Choose Your Language',
      description: 'Pilih bahasa pilihan anda',
      icon: Icons.language_rounded,
      color: AppTheme.softPeach,
      backgroundColor: AppTheme.lightPeach,
      isLanguageSelector: true,
    ),
    OnboardingPage(
      title: 'Enable Location Services',
      description: 'Find clinics near you for easier access',
      icon: Icons.location_on_rounded,
      color: AppTheme.softGreen,
      backgroundColor: AppTheme.lightGreen,
      isLocationSelector: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
            _buildIndicators(),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.backgroundColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.greyText,
                ),
            textAlign: TextAlign.center,
          ),
          if (page.isLanguageSelector) ...[
            const SizedBox(height: 40),
            _buildLanguageSelector(),
          ],
          if (page.isLocationSelector) ...[
            const SizedBox(height: 40),
            _buildLocationButton(),
          ],
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
    return ElevatedButton.icon(
      onPressed: () {
        // Enable location services
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services enabled')),
        );
      },
      icon: const Icon(Icons.my_location),
      label: const Text('Enable Location'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primaryBlue
                : AppTheme.primaryBlue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (_currentPage < _pages.length - 1)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          if (_currentPage == _pages.length - 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),
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
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isLanguageSelector;
  final bool isLocationSelector;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.isLanguageSelector = false,
    this.isLocationSelector = false,
  });
}

