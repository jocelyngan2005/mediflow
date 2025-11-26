import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Clinic clinic;
  final bool isGuest;

  const ProfileScreen({
    super.key,
    required this.clinic,
    required this.isGuest,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'BM';
  String _userType = 'Patient';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // Mock user data
  final String _userName = 'Ahmad bin Abdullah';
  final String _userEmail = 'ahmad@example.com';
  final String _userPhone = '+60 12-345 6789';
  final String _healthId = 'MY123456789';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile 👤', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isGuest)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditProfileDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightBlue,
                          border: Border.all(
                            color: AppTheme.primaryBlue,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          widget.isGuest ? Icons.person_outline : Icons.person,
                          size: 50,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      if (!widget.isGuest)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.softGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isGuest ? 'Guest User' : _userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  if (widget.isGuest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Guest Mode - Limited Features',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.softOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      _userType,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (widget.isGuest) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login / Sign Up'),
                    ),
                  ],
                ],
              ),
            ),

            if (!widget.isGuest) ...[
              const SizedBox(height: 20),
              _buildSection('Personal Information', [
                _buildInfoTile('Full Name', _userName, Icons.person),
                _buildInfoTile('Email', _userEmail, Icons.email),
                _buildInfoTile('Phone', _userPhone, Icons.phone),
                _buildInfoTile('Health ID', _healthId, Icons.badge),
              ]),
            ],

            const SizedBox(height: 20),
            _buildSection('Current Clinic', [
              _buildClinicTile(),
            ]),

            const SizedBox(height: 20),
            _buildSection('Preferences', [
              _buildLanguageTile(),
              if (!widget.isGuest) _buildUserTypeTile(),
              _buildSwitchTile(
                'Notifications',
                'Receive appointment reminders',
                Icons.notifications,
                _notificationsEnabled,
                (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                'Dark Mode',
                'Coming soon',
                Icons.dark_mode,
                _darkModeEnabled,
                (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dark mode coming soon!')),
                  );
                },
              ),
            ]),

            if (!widget.isGuest) ...[
              const SizedBox(height: 20),
              _buildSection('History', [
                _buildActionTile(
                  'Past Appointments',
                  'View your appointment history',
                  Icons.history,
                  AppTheme.primaryBlue,
                  () => _showComingSoonDialog('Appointment history'),
                ),
                _buildActionTile(
                  'Medical Records',
                  'Access your health records',
                  Icons.folder_shared,
                  AppTheme.softGreen,
                  () => _showComingSoonDialog('Medical records'),
                ),
              ]),
            ],

            const SizedBox(height: 20),
            _buildSection('Support', [
              _buildActionTile(
                'Help & FAQ',
                'Get answers to common questions',
                Icons.help_outline,
                AppTheme.softOrange,
                () => _showComingSoonDialog('Help center'),
              ),
              _buildActionTile(
                'Contact Support',
                'Reach out to our team',
                Icons.support_agent,
                AppTheme.softPeach,
                () => _showComingSoonDialog('Support'),
              ),
              _buildActionTile(
                'About MediFlow',
                'Version 1.0.0',
                Icons.info_outline,
                AppTheme.greyText,
                () => _showAboutDialog(),
              ),
            ]),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout, color: AppTheme.softRed),
                  label: Text(
                    widget.isGuest ? 'Exit Guest Mode' : 'Logout',
                    style: const TextStyle(color: AppTheme.softRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.softRed),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.greyText,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkText,
        ),
      ),
    );
  }

  Widget _buildClinicTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.local_hospital, color: AppTheme.softGreen, size: 20),
      ),
      title: Text(
        widget.clinic.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkText,
        ),
      ),
      subtitle: Text(
        widget.clinic.address,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.greyText,
        ),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ClinicSelectionScreen(isGuest: widget.isGuest),
            ),
          );
        },
        child: const Text('Switch'),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.language, color: AppTheme.primaryBlue, size: 20),
      ),
      title: const Text('Language'),
      subtitle: Text(_selectedLanguage == 'BM' ? 'Bahasa Melayu' : 'English'),
      trailing: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'BM', label: Text('BM')),
          ButtonSegment(value: 'EN', label: Text('EN')),
        ],
        selected: {_selectedLanguage},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedLanguage = newSelection.first;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedLanguage == 'BM'
                    ? 'Bahasa ditukar kepada Bahasa Melayu'
                    : 'Language changed to English',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserTypeTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightPeach,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.person_pin, color: AppTheme.softPeach, size: 20),
      ),
      title: const Text('User Type'),
      subtitle: Text(_userType),
      trailing: DropdownButton<String>(
        value: _userType,
        underline: Container(),
        items: ['Patient', 'Staff'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _userType = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.softGreen, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MediFlow'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MediFlow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Your intelligent healthcare companion for Malaysian clinics.',
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('• AI Nurse FAQ Assistant'),
            Text('• Smart Appointment Booking'),
            Text('• SOP & Guidelines Search'),
            Text('• Medication Management'),
            SizedBox(height: 16),
            Text(
              '© 2025 MediFlow. All rights reserved.',
              style: TextStyle(fontSize: 11, color: AppTheme.greyText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isGuest ? 'Exit Guest Mode?' : 'Logout'),
        content: Text(
          widget.isGuest
              ? 'Are you sure you want to exit guest mode?'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softRed,
            ),
            child: Text(widget.isGuest ? 'Exit' : 'Logout'),
          ),
        ],
      ),
    );
  }
}

