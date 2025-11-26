import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final Clinic clinic;

  const AppointmentsScreen({super.key, required this.clinic});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _currentStep = 0;
  final TextEditingController _symptomsController = TextEditingController();
  String? _selectedUrgency;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final List<String> _selectedSymptoms = [];
  
  // Mock AI suggested appointment time
  final DateTime _aiSuggestedDate = DateTime.now().add(const Duration(days: 1));
  final String _aiSuggestedTime = '10:00 AM';

  // Common symptoms
  final List<String> _commonSymptoms = [
    'Fever',
    'Cough',
    'Sore throat',
    'Runny nose',
    'Headache',
    'Body ache',
    'Nausea',
    'Dizziness',
    'Skin rash',
    'Stomach pain',
  ];


  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }


  void _nextStep() {
    if (_currentStep == 0 && _selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    if (_currentStep == 0 && _selectedSymptoms.contains('Other') && _symptomsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your other symptoms')),
      );
      return;
    }

    if (_currentStep == 1) {
      // Auto-set AI urgency assessment
      setState(() {
        _selectedUrgency = _getAIUrgencyAssessment();
      });
    }

    if (_currentStep == 2 && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_currentStep == 2 && _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _confirmAppointment();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _confirmAppointment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.softGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.softGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment at ${widget.clinic.name} has been scheduled',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Date', '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                    const Divider(height: 16),
                    _buildInfoRow('Time', _selectedTimeSlot ?? ''),
                    const Divider(height: 16),
                    _buildInfoRow('Priority', _selectedUrgency ?? 'Low'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkText,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.greyText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinic.name, 
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  'Book Appointment',
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: _buildQuestionCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background stacked cards
        Positioned(
          top: 8,
          left: -8,
          right: -8,
          child: Container(
            height: 580,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: -16,
          right: -16,
          child: Container(
            height: 580,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        // Main card
        Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 580,
          ),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              Text(
                'Q.0${_currentStep + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.greyText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildStepContent(),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF8A65)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSymptomsStep();
      case 1:
        return _buildUrgencyStep();
      case 2:
        return _buildDateSelectionStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return Container();
    }
  }

  String _getQuestionTitle() {
    switch (_currentStep) {
      case 0:
        return 'What symptoms are you experiencing?';
      case 1:
        return 'AI Triage Assessment';
      case 2:
        return 'When would you like to schedule your appointment?';
      case 3:
        return 'Please confirm your appointment details';
      default:
        return '';
    }
  }

  Widget _buildSymptomsStep() {
    final allSymptomOptions = [..._commonSymptoms.take(5), 'Other'];
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SELECT ALL THAT APPLY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.greyText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Scrollable options container - shows ~3 options
          Expanded(
            child: ListView.builder(
              shrinkWrap: false,
              itemCount: allSymptomOptions.length,
              itemBuilder: (context, index) {
                final symptom = allSymptomOptions[index];
                final isSelected = _selectedSymptoms.contains(symptom);
                
                // Special handling for "Other" option with text field
                if (symptom == 'Other') {
                  return _buildOtherOptionTile(
                    isSelected,
                    () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove('Other');
                          _symptomsController.clear();
                        } else {
                          _selectedSymptoms.add('Other');
                        }
                      });
                    },
                  );
                }
                
                return _buildOptionTile(
                  symptom,
                  isSelected,
                  () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyStep() {
    // Mock AI assessment (will be replaced with backend call)
    final aiUrgency = _getAIUrgencyAssessment();
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI ASSESSMENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.greyText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getUrgencyBackgroundColor(aiUrgency),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getUrgencyBorderColor(aiUrgency),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getUrgencyIcon(aiUrgency),
                          size: 48,
                          color: _getUrgencyBorderColor(aiUrgency),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${aiUrgency} Priority',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _getUrgencyBorderColor(aiUrgency),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getUrgencyMessage(aiUrgency),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your reported symptoms:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSymptoms.map((symptom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          symptom,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAIUrgencyAssessment() {
    // Mock AI logic (will be replaced with actual backend call)
    if (_selectedSymptoms.contains('Fever') && _selectedSymptoms.contains('Headache')) {
      return 'Medium';
    } else if (_selectedSymptoms.contains('Dizziness') || _selectedSymptoms.contains('Nausea')) {
      return 'High';
    } else {
      return 'Low';
    }
  }

  Color _getUrgencyBackgroundColor(String urgency) {
    switch (urgency) {
      case 'High':
        return AppTheme.lightRed;
      case 'Medium':
        return AppTheme.lightOrange;
      case 'Low':
        return AppTheme.lightGreen;
      default:
        return AppTheme.background;
    }
  }

  Color _getUrgencyBorderColor(String urgency) {
    switch (urgency) {
      case 'High':
        return AppTheme.softRed;
      case 'Medium':
        return AppTheme.softOrange;
      case 'Low':
        return AppTheme.softGreen;
      default:
        return AppTheme.greyText;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'High':
        return Icons.warning_rounded;
      case 'Medium':
        return Icons.info_rounded;
      case 'Low':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getUrgencyMessage(String urgency) {
    switch (urgency) {
      case 'High':
        return 'Based on your symptoms, we recommend seeing a doctor as soon as possible. We\'ll prioritize your appointment.';
      case 'Medium':
        return 'Your symptoms require medical attention. We\'ll schedule you within 1-2 days.';
      case 'Low':
        return 'Your symptoms are manageable. A routine appointment should be sufficient.';
      default:
        return '';
    }
  }


  Widget _buildOptionTile(String label, bool isSelected, VoidCallback onTap, {bool isRadio = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isRadio ? null : BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      isRadio ? Icons.circle : Icons.check,
                      size: isRadio ? 11 : 15,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: AppTheme.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherOptionTile(bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.lightBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _symptomsController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelectionStep() {
    final isAISuggestedDate = _selectedDate != null &&
        _selectedDate!.year == _aiSuggestedDate.year &&
        _selectedDate!.month == _aiSuggestedDate.month &&
        _selectedDate!.day == _aiSuggestedDate.day;
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // AI Suggestion Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Recommended',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        '${_aiSuggestedDate.day}/${_aiSuggestedDate.month}/${_aiSuggestedDate.year} at $_aiSuggestedTime',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  const Text(
                    'SELECT DATE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.greyText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryBlue,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _aiSuggestedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDate = date;
                            _selectedTimeSlot = null; // Reset time slot
                          });
                        },
                      ),
                    ),
                  ),
                  
                  // Time Slots
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'SELECT TIME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.greyText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeDropdown(isAISuggestedDate),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDropdown(bool isAISuggestedDate) {
    // Mock available time slots
    final timeSlots = [
      '9:00 AM', '10:00 AM', '11:00 AM',
      '2:00 PM', '3:00 PM', '4:00 PM',
    ];
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (time) {
        setState(() {
          _selectedTimeSlot = time;
        });
      },
      itemBuilder: (context) {
        return timeSlots.map((time) {
          final isAISuggested = isAISuggestedDate && time == _aiSuggestedTime;
          final isSelected = _selectedTimeSlot == time;
          
          return PopupMenuItem<String>(
            value: time,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (isAISuggested)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isAISuggested ? FontWeight.w600 : FontWeight.w500,
                        color: isAISuggested ? AppTheme.primaryBlue : AppTheme.darkText,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      size: 18,
                      color: AppTheme.primaryBlue,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTimeSlot != null ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: _selectedTimeSlot != null ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTimeSlot ?? 'Select time slot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: _selectedTimeSlot != null ? FontWeight.w500 : FontWeight.w400,
                color: _selectedTimeSlot != null ? AppTheme.darkText : AppTheme.greyText,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: _selectedTimeSlot != null ? AppTheme.primaryBlue : AppTheme.greyText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Clinic', widget.clinic.name),
                  _buildSummaryItem(
                    'Date & Time',
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at $_selectedTimeSlot',
                  ),
                  _buildSummaryItem('Priority', '${_selectedUrgency ?? 'Low'}'),
                  _buildSummaryItem('Symptoms', _selectedSymptoms.where((s) => s != 'Other').join(', ')),
                  if (_selectedSymptoms.contains('Other') && _symptomsController.text.isNotEmpty)
                    _buildSummaryItem('Other Symptoms', _symptomsController.text),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'ll receive a confirmation via SMS',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.darkText.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentStep > 0) ...[
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.darkText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              _currentStep == 3 ? 'Confirm' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

