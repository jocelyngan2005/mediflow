import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/screens/ai_assistant_screen.dart';
import 'package:mediflow/screens/appointments_screen.dart';

class ClinicCard extends StatefulWidget {
  final Clinic clinic;

  const ClinicCard({
    super.key,
    required this.clinic,
  });

  @override
  State<ClinicCard> createState() => _ClinicCardState();
}

class _ClinicCardState extends State<ClinicCard> {
  bool _isHoursExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinic image
          Image.asset(
            'assets/clinic_placeholder.webp',
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 180,
                color: AppTheme.lightBlue,
                child: const Icon(
                  Icons.local_hospital,
                  size: 60,
                  color: AppTheme.primaryBlue,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clinic name and distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.clinic.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.clinic.distance,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating and Open status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.clinic.rating} stars',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.clinic.isOpen
                            ? AppTheme.lightGreen
                            : AppTheme.lightRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.clinic.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: widget.clinic.isOpen
                              ? AppTheme.softGreen
                              : AppTheme.softRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.clinic.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Phone number
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.clinic.phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Hours with dropdown
                InkWell(
                  onTap: () {
                    setState(() {
                      _isHoursExpanded = !_isHoursExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.clinic.hours,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        _isHoursExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppTheme.greyText,
                      ),
                    ],
                  ),
                ),
                if (_isHoursExpanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDayHours('Monday', '8:00 AM - 8:00 PM'),
                        _buildDayHours('Tuesday', '8:00 AM - 8:00 PM'),
                        _buildDayHours('Wednesday', '8:00 AM - 8:00 PM'),
                        _buildDayHours('Thursday', '8:00 AM - 8:00 PM'),
                        _buildDayHours('Friday', '8:00 AM - 8:00 PM'),
                        _buildDayHours('Saturday', '8:00 AM - 2:00 PM'),
                        _buildDayHours('Sunday', 'Closed', isLast: true),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Make an appointment button and chat icon
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate directly to appointments screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AppointmentsScreen(clinic: widget.clinic),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'MAKE AN APPOINTMENT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Navigate to chat/AI Assistant
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AIAssistantScreen(clinic: widget.clinic),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                        tooltip: 'Chat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHours(String day, String hours, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 13,
              color: hours == 'Closed' ? AppTheme.softRed : AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

