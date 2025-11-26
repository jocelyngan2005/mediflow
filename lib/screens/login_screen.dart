import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/screens/signup_screen.dart';
import 'package:mediflow/screens/staff_main_menu.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/user_auth_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to continue',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      _buildLoginForm(),
                      const SizedBox(height: 16),
                      _buildGuestButton(),
                      const SizedBox(height: 24),
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(
              labelText: 'Email or Phone',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_loginFormKey.currentState!.validate()) {
                  // Prototype login logic
                  final email = _loginEmailController.text.trim().toLowerCase();
                  
                  if (email == 'staff@gmail.com') {
                    // Navigate to medication screen for staff
                    final mockClinic = Clinic(
                      clinicId: 'clinic_staff',
                      name: 'General Hospital',
                      address: '123 Main Street',
                      distance: '2.5 km',
                      hours: '8:00 AM - 8:00 PM',
                      isOpen: true,
                      phoneNumber: '04-123-4567',
                      rating: 5,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => StaffMainMenu(clinic: mockClinic)),
                    );
                  } else if (email == 'user@gmail.com') {
                    // Navigate to clinic selection screen for regular users
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ClinicSelectionScreen(isGuest: false)),
                    );
                  } else {
                    // Default behavior for other emails
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ClinicSelectionScreen(isGuest: false)),
                    );
                  }
                }
              },
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ClinicSelectionScreen(isGuest: true)),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
          foregroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: const Text('Continue as Guest'),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            child: Text(
              'Sign Up here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

