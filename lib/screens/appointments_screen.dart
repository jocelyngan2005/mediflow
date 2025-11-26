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

  // Available time slots
  final Map<String, List<String>> _timeSlots = {
    'Morning': ['9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM'],
    'Afternoon': ['2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM'],
    'Evening': ['6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM'],
  };

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  String _getUrgencyAI() {
    // AI-based urgency classification (mock)
    if (_selectedSymptoms.contains('Fever') && _selectedSymptoms.contains('Headache')) {
      return 'Medium';
    } else if (_selectedSymptoms.contains('Skin rash') || _selectedSymptoms.contains('Dizziness')) {
      return 'High';
    } else {
      return 'Low';
    }
  }

  Color _getUrgencyColor(String urgency) {
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

  void _nextStep() {
    if (_currentStep == 0 && _selectedSymptoms.isEmpty && _symptomsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms')),
      );
      return;
    }

    if (_currentStep == 0) {
      // AI classifies urgency
      setState(() {
        _selectedUrgency = _getUrgencyAI();
      });
    }

    if (_currentStep == 1 && _selectedDate == null) {
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
      builder: (context) => AlertDialog(
        title: const Text('Appointment Confirmed! ✅'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clinic: ${widget.clinic.name}'),
            const SizedBox(height: 8),
            Text('Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            Text('Time: $_selectedTimeSlot'),
            const SizedBox(height: 8),
            Text('Urgency: $_selectedUrgency'),
            const SizedBox(height: 12),
            const Text(
              'You will receive a confirmation message shortly.',
              style: TextStyle(fontSize: 12, color: AppTheme.greyText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Book Appointment 📅', style: TextStyle(fontSize: 18)),
            Text(
              widget.clinic.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          _buildStepIndicator(0, 'Symptoms', Icons.medical_services),
          _buildStepLine(0),
          _buildStepIndicator(1, 'Urgency', Icons.priority_high),
          _buildStepLine(1),
          _buildStepIndicator(2, 'Date', Icons.calendar_today),
          _buildStepLine(2),
          _buildStepIndicator(3, 'Confirm', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : AppTheme.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.greyText,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppTheme.darkText : AppTheme.greyText,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? AppTheme.primaryBlue : AppTheme.background,
      ),
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

  Widget _buildSymptomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe Your Symptoms',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Select common symptoms or describe in detail',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          'Common Symptoms:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSymptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              selectedColor: AppTheme.lightBlue,
              checkmarkColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.darkText,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Additional Details:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _symptomsController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe your symptoms in detail...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Assessment',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your symptoms, our AI has classified the urgency',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getUrgencyColor(_selectedUrgency ?? 'Low'),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.health_and_safety,
                size: 64,
                color: _getUrgencyColor(_selectedUrgency ?? 'Low'),
              ),
              const SizedBox(height: 16),
              Text(
                'Urgency Level: $_selectedUrgency',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _getUrgencyColor(_selectedUrgency ?? 'Low'),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _getUrgencyDescription(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Symptoms:',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSymptoms
              .map((symptom) => Chip(
                    label: Text(symptom),
                    backgroundColor: AppTheme.lightBlue,
                  ))
              .toList(),
        ),
        if (_symptomsController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_symptomsController.text),
          ),
        ],
      ],
    );
  }

  String _getUrgencyDescription() {
    switch (_selectedUrgency) {
      case 'High':
        return 'We recommend seeing a doctor as soon as possible. We\'ll prioritize your appointment.';
      case 'Medium':
        return 'Your symptoms require medical attention. We\'ll schedule you within 1-2 days.';
      case 'Low':
        return 'Your symptoms are manageable. We can schedule a regular appointment.';
      default:
        return '';
    }
  }

  Widget _buildDateSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date & Time',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred appointment date',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null; // Reset time slot
                  });
                },
              ),
            ],
          ),
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 24),
          Text(
            'Available Time Slots:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ..._timeSlots.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        },
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              )),
        ],
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Appointment',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your appointment details',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildConfirmationCard(
          'Clinic',
          widget.clinic.name,
          Icons.local_hospital,
          AppTheme.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Date & Time',
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at $_selectedTimeSlot',
          Icons.calendar_today,
          AppTheme.softGreen,
        ),
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Urgency Level',
          _selectedUrgency ?? 'Low',
          Icons.priority_high,
          _getUrgencyColor(_selectedUrgency ?? 'Low'),
        ),
        const SizedBox(height: 12),
        _buildConfirmationCard(
          'Symptoms',
          _selectedSymptoms.join(', '),
          Icons.medical_services,
          AppTheme.softOrange,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will receive a confirmation message via SMS/WhatsApp',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkText,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == 3 ? 'Confirm Booking' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

