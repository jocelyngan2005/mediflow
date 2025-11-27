import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupFormKey = GlobalKey<FormState>();
  
  // Account type: 'personal' or 'clinic'
  String _accountType = 'personal';
  
  // Personal account fields
  final _icNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Clinic account fields
  Clinic? _selectedClinic;
  final _clinicEmailController = TextEditingController();
  final _clinicPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureClinicPassword = true;
  
  // Sample clinic data (same as in clinic_selection_screen.dart)
  final List<Clinic> _clinics = [
    Clinic(
      clinicId: 'clinic_001',
      name: 'Klinik Bandar Utama',
      address: 'Bandar Utama, Petaling Jaya',
      distance: '0.5km',
      hours: 'Wednesday 8:00am to 8:00pm',
      isOpen: true,
      phoneNumber: '010-309 5217',
      rating: 5,
    ),
    Clinic(
      clinicId: 'clinic_002',
      name: 'Klinik Sri Hartamas',
      address: 'Sri Hartamas, Kuala Lumpur',
      distance: '1.2km',
      hours: 'Mon-Sat: 9:00 AM - 9:00 PM',
      isOpen: true,
      phoneNumber: '012-345 6789',
      rating: 4,
    ),
    Clinic(
      clinicId: 'clinic_003',
      name: 'Klinik Desa Jaya',
      address: 'Dasa Jaya',
      distance: '2.0km',
      hours: 'Mon-Sun: 24 Hours',
      isOpen: true,
      phoneNumber: '011-234 5678',
      rating: 5,
    ),
    Clinic(
      clinicId: 'clinic_004',
      name: 'Klinik Famili Wangsa Maju',
      address: 'Wangsa Maju, Kuala Lumpur',
      distance: '2.8km',
      hours: 'Mon-Fri: 8:00 AM - 10:00 PM',
      isOpen: false,
      phoneNumber: '013-456 7890',
      rating: 3,
    ),
  ];

  @override
  void dispose() {
    _icNumberController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _clinicEmailController.dispose();
    _clinicPasswordController.dispose();
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
                        'Create Account',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      _buildSignUpForm(),
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

  Widget _buildSignUpForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          // Account type selection
          _buildAccountTypeSelector(),
          const SizedBox(height: 24),
          // Conditional fields based on account type
          if (_accountType == 'personal') ..._buildPersonalAccountFields(),
          if (_accountType == 'clinic') ..._buildClinicAccountFields(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_signupFormKey.currentState!.validate()) {
                  // Navigate back to login screen
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Sign Up'),
            ),
          ),
          const SizedBox(height: 24),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _accountType = 'personal';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _accountType == 'personal' ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Personal Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _accountType == 'personal' ? Colors.white : Colors.black87,
                    fontWeight: _accountType == 'personal' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _accountType = 'clinic';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _accountType == 'clinic' ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Clinic Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _accountType == 'clinic' ? Colors.white : Colors.black87,
                    fontWeight: _accountType == 'clinic' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonalAccountFields() {
    return [
      TextFormField(
        controller: _icNumberController,
        decoration: const InputDecoration(
          labelText: 'IC Number',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your IC number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(
          labelText: 'Telephone Number',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your telephone number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
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
            return 'Please enter a password';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildClinicAccountFields() {
    return [
      DropdownButtonFormField<Clinic>(
        value: _selectedClinic,
        isExpanded: true, // 👈 PREVENT overflow
        decoration: const InputDecoration(
          labelText: 'Select Clinic',
          prefixIcon: Icon(Icons.local_hospital_outlined),
        ),
        items: _clinics.map((Clinic clinic) {
          return DropdownMenuItem<Clinic>(
            value: clinic,
            child: Text(
              clinic.name,
              overflow: TextOverflow.clip,
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return _clinics.map<Widget>((Clinic clinic) {
            return Text(
              clinic.name,
              overflow: TextOverflow.ellipsis, // 👈 safer
              maxLines: 1,
            );
          }).toList();
        },
        onChanged: (Clinic? newValue) {
          setState(() {
            _selectedClinic = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a clinic';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _clinicEmailController,
        decoration: const InputDecoration(
          labelText: 'Clinic Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter clinic email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _clinicPasswordController,
        obscureText: _obscureClinicPassword,
        decoration: InputDecoration(
          labelText: 'Clinic Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscureClinicPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _obscureClinicPassword = !_obscureClinicPassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          return null;
        },
      ),
    ];
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Login here',
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

