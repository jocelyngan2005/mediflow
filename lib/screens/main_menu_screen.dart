import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/screens/ai_assistant_screen.dart';
import 'package:mediflow/screens/appointments_screen.dart';
import 'package:mediflow/screens/medication_screen.dart';
import 'package:mediflow/screens/profile_screen.dart';
import 'package:mediflow/widgets/menu_card.dart';

class MainMenuScreen extends StatelessWidget {
  final Clinic clinic;
  final bool isGuest;

  const MainMenuScreen({
    super.key,
    required this.clinic,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ClinicFlow+', style: TextStyle(fontSize: 18)),
            Text(
              clinic.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ClinicSelectionScreen(isGuest: isGuest),
                ),
              );
            },
            tooltip: 'Change Clinic',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello${isGuest ? ' Guest' : ''}! 👋',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'How can I help you today?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    MenuCard(
                      title: 'AI Assistant',
                      subtitle: 'FAQ & Documents',
                      icon: Icons.smart_toy_rounded,
                      color: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.lightBlue,
                      onTap: () {
                        _navigateToScreen(context, 'AI Assistant');
                      },
                    ),
                    MenuCard(
                      title: 'Appointments',
                      subtitle: 'Book & manage',
                      icon: Icons.calendar_today_rounded,
                      color: AppTheme.softGreen,
                      backgroundColor: AppTheme.lightGreen,
                      onTap: () {
                        _navigateToScreen(context, 'Appointments');
                      },
                    ),
                    MenuCard(
                      title: 'Medication',
                      subtitle: 'Stock lookup',
                      icon: Icons.medication_rounded,
                      color: AppTheme.softRed,
                      backgroundColor: AppTheme.lightRed,
                      badge: 'Staff Only',
                      onTap: () {
                        _showStaffPinDialog(context);
                      },
                    ),
                    MenuCard(
                      title: 'Profile',
                      subtitle: isGuest ? 'Login to save' : 'Your info',
                      icon: Icons.person_rounded,
                      color: AppTheme.softPeach,
                      backgroundColor: AppTheme.lightPeach,
                      onTap: () {
                        _navigateToScreen(context, 'Profile');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screenName) {
    Widget? screen;
    
    switch (screenName) {
      case 'AI Assistant':
        screen = AIAssistantScreen(clinic: clinic);
        break;
      case 'Appointments':
        screen = AppointmentsScreen(clinic: clinic);
        break;
      case 'Profile':
        screen = ProfileScreen(clinic: clinic, isGuest: isGuest);
        break;
    }

    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }

  void _showStaffPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter staff PIN to access medication lookup'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == '1234') {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MedicationScreen(clinic: clinic),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid PIN')),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}

