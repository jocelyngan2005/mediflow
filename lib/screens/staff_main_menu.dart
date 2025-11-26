import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/widgets/menu_card.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/screens/medication_screen.dart';
import 'package:mediflow/screens/ai_assistant_staff_screen.dart';
import 'package:mediflow/screens/login_screen.dart';

class StaffMainMenu extends StatefulWidget {
  final Clinic clinic;

  const StaffMainMenu({super.key, required this.clinic});

  @override
  State<StaffMainMenu> createState() => _StaffMainMenuState();
}

class _StaffMainMenuState extends State<StaffMainMenu> {
  void _navigateToStaffAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaffAssistantScreen(clinic: widget.clinic),
      ),
    );
  }

  void _navigateToMedicationLookup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicationScreen(clinic: widget.clinic),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom header with gradient background
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with staff profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logout icon
                        IconButton(
                          onPressed: _handleLogout,
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // Staff indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Staff',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF1E5AC8),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Clinic Name Title
                    Text(
                      widget.clinic.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // AI Assistant chat field (disabled, clickable)
                    GestureDetector(
                      onTap: _navigateToStaffAssistant,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.smart_toy,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Try smart AI Assistant...',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Menu Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  MenuCard(
                    title: 'Medical Lookup',
                    subtitle: 'Search medications & stock',
                    icon: Icons.medication,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.lightBlue,
                    onTap: _navigateToMedicationLookup,
                  ),
                  MenuCard(
                    title: 'Appointment Bookings',
                    subtitle: 'Manage patient appointments',
                    icon: Icons.calendar_today,
                    color: AppTheme.softGreen,
                    backgroundColor: AppTheme.lightGreen,
                    badge: 'Soon',
                    onTap: () => _showComingSoon('Appointment Bookings'),
                  ),
                  MenuCard(
                    title: 'Clinic Analytics',
                    subtitle: 'View reports & insights',
                    icon: Icons.analytics,
                    color: AppTheme.softOrange,
                    backgroundColor: AppTheme.lightOrange,
                    badge: 'Soon',
                    onTap: () => _showComingSoon('Clinic Analytics'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

