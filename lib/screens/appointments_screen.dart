import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/services/api_service.dart';
import 'dart:convert';

class AppointmentsScreen extends StatefulWidget {
  final Clinic clinic;

  const AppointmentsScreen({super.key, required this.clinic});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  final TextEditingController _symptomsController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final List<String> _selectedSymptoms = [];
  
  // Backend response data
  List<Map<String, dynamic>> _availableTimeSlots = [];
  Map<String, dynamic>? _caseType;
  Map<String, dynamic>? _recommendedTime;
  String? _refinedUserMessage;
  bool _isLoadingAIResponse = false;

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
  void initState() {
    super.initState();
    // Initialize with basic slots to ensure we always have something to show
    _initializeDefaultSlots();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _initializeDefaultSlots() {
    // Pre-populate with default slots so users always see options
    if (_availableTimeSlots.isEmpty) {
      print('Initializing default slots...');
      
      // Try regular generation first
      _availableTimeSlots = _generateTimeSlots();
      print('Regular generation: ${_availableTimeSlots.length} slots');
      
      // If empty, try fallback
      if (_availableTimeSlots.isEmpty) {
        _availableTimeSlots = _generateFallbackTimeSlots();
        print('Fallback generation: ${_availableTimeSlots.length} slots');
      }
      
      // If still empty, use basic fallback
      if (_availableTimeSlots.isEmpty) {
        _availableTimeSlots = _generateBasicFallbackSlots();
        print('Basic fallback generation: ${_availableTimeSlots.length} slots');
      }
      
      print('Final initialized slots: ${_availableTimeSlots.length}');
      
      // Debug: Print first few slots
      for (int i = 0; i < _availableTimeSlots.length && i < 3; i++) {
        print('Slot $i: ${_availableTimeSlots[i]}');
      }
    }
  }

  Future<void> _callAppointmentBookingAPI() async {
    setState(() {
      _isLoadingAIResponse = true;
    });

    try {
      String userInput = _formatSymptomsForAPI();
      
      ApiResponse<ChatResponse> response = await ApiService.bookAppointment(
        clinicId: widget.clinic.clinicId,
        message: userInput,
        language: 'EN',
      );

      if (response.success && response.data != null) {
        _parseBackendResponse(response.data!);
      } else {
        _setFallbackData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Error: ${response.error ?? "Unknown error"}')),
          );
        }
      }
    } catch (e) {
      _setFallbackData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingAIResponse = false;
      });
    }
  }

  String _formatSymptomsForAPI() {
    List<String> allSymptoms = List.from(_selectedSymptoms);
    
    if (_selectedSymptoms.contains('Other') && _symptomsController.text.trim().isNotEmpty) {
      allSymptoms.remove('Other');
      allSymptoms.add(_symptomsController.text.trim());
    }
    
    return 'Patient symptoms: ${allSymptoms.join(", ")}';
  }

  void _parseBackendResponse(ChatResponse response) {
    try {
      Map<String, dynamic> data = json.decode(response.reply);
      
      if (data['available_time_slots'] is String) {
        _availableTimeSlots = List<Map<String, dynamic>>.from(
          json.decode(data['available_time_slots'])
        );
      }
      
      if (data['case_type'] is String) {
        _caseType = json.decode(data['case_type']);
      }
      
      if (data['recommended_time'] is String) {
        _recommendedTime = json.decode(data['recommended_time']);
      }
      
      _refinedUserMessage = data['refined_user_message'];
      
      // Note: booking_record from sourceDocument can be used if needed in the future
      
    } catch (e) {
      print('Error parsing backend response: $e');
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    String caseTypeValue = _determineCaseType();
    
    _caseType = {
      "case_type": caseTypeValue,
      "booking_needed": true,
      "response_template": _getResponseTemplate(caseTypeValue)
    };
    
    print('Setting fallback data...');
    
    // Always ensure we have time slots, prefer generated slots but use fallback if needed
    List<Map<String, dynamic>> generatedSlots = _generateTimeSlots();
    print('Generated slots count: ${generatedSlots.length}');
    
    if (generatedSlots.isNotEmpty) {
      _availableTimeSlots = generatedSlots;
      print('Using generated slots');
    } else {
      _availableTimeSlots = _generateFallbackTimeSlots();
      print('Using fallback slots, count: ${_availableTimeSlots.length}');
    }
    
    // If still empty, force create basic fallback slots
    if (_availableTimeSlots.isEmpty) {
      _availableTimeSlots = _generateBasicFallbackSlots();
      print('Using basic fallback slots, count: ${_availableTimeSlots.length}');
    }
    
    print('Final available slots count: ${_availableTimeSlots.length}');
    
    if (caseTypeValue == 'EMERGENCY' || caseTypeValue == 'URGENT') {
      _recommendedTime = {
        "slot_found": true,
        "display_date": _formatDate(DateTime.now().add(const Duration(days: 1))),
        "display_time": "09:00",
        "doctor": "Dr. Sarah Lee",
        "clinic": widget.clinic.name
      };
    } else {
      _recommendedTime = {
        "slot_found": true,
        "display_date": _formatDate(DateTime.now().add(const Duration(days: 3))),
        "display_time": "14:00",
        "doctor": "Dr. Ahmad Rahman",
        "clinic": widget.clinic.name
      };
    }
    
    _refinedUserMessage = "We recommend scheduling an appointment to address your symptoms.";
  }

  String _determineCaseType() {
    if (_selectedSymptoms.any((symptom) => 
        ['Nausea', 'Dizziness', 'Severe pain'].contains(symptom))) {
      return 'EMERGENCY';
    } else if (_selectedSymptoms.any((symptom) => 
        ['Fever', 'Headache'].contains(symptom))) {
      return 'URGENT';
    } else if (_selectedSymptoms.length > 2) {
      return 'ROUTINE';
    } else {
      return 'NON_URGENT';
    }
  }

  String _getResponseTemplate(String caseType) {
    switch (caseType) {
      case 'EMERGENCY':
        return 'Your symptoms indicate a potential emergency. Please seek immediate medical attention.';
      case 'URGENT':
        return 'Your symptoms require prompt medical attention. We recommend scheduling an appointment within 24-48 hours.';
      case 'ROUTINE':
        return 'Your symptoms can be addressed during a routine appointment. Please schedule at your convenience.';
      case 'NON_URGENT':
        return 'Your symptoms are mild and can be monitored. Consider scheduling a routine check-up.';
      default:
        return 'Please consult with a healthcare provider about your symptoms.';
    }
  }

  List<Map<String, dynamic>> _generateTimeSlots() {
    List<Map<String, dynamic>> slots = [];
    DateTime startDate = DateTime.now().add(const Duration(days: 1)); // Tomorrow
    
    // Debug: Print current date info
    print('Current date: ${DateTime.now()}');
    print('Start date: $startDate, weekday: ${startDate.weekday}');
    
    for (int day = 0; day < 7; day++) {
      DateTime date = startDate.add(Duration(days: day));
      print('Checking date: $date, weekday: ${date.weekday}');
      
      // Include weekdays (Monday=1 to Friday=5) and Saturday=6 for more availability  
      if (date.weekday <= 6) {
        print('Adding slots for: $date');
        slots.addAll([
          {
            "date": _formatDate(date),
            "time": "09:00",
            "doctor": "Dr. Sarah Lee",
            "clinic": widget.clinic.name
          },
          {
            "date": _formatDate(date), 
            "time": "10:30",
            "doctor": "Dr. Ahmad Rahman",
            "clinic": widget.clinic.name
          },
          {
            "date": _formatDate(date),
            "time": "14:00",
            "doctor": "Dr. Lisa Wong",
            "clinic": widget.clinic.name
          },
          {
            "date": _formatDate(date),
            "time": "16:30", 
            "doctor": "Dr. Sarah Lee",
            "clinic": widget.clinic.name
          }
        ]);
      }
    }
    
    print('Generated ${slots.length} slots total');
    return slots;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  bool _isUsingFallbackData() {
    // Check if we're using fallback data (when API failed or returned limited data)
    return _availableTimeSlots.isNotEmpty && 
           _availableTimeSlots.any((slot) => 
             slot['doctor'] == 'Available Doctor' || 
             slot['doctor'] == 'Dr. On-Call' || 
             slot['doctor'] == 'General Practitioner'
           );
  }

  List<Map<String, dynamic>> _generateFallbackTimeSlots() {
    // Generate basic fallback slots when API fails or returns empty
    List<Map<String, dynamic>> fallbackSlots = [];
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    
    // List of generic doctor names for fallback
    List<String> fallbackDoctors = [
      "Available Doctor",
      "Dr. On-Call",
      "General Practitioner"
    ];
    
    // Generate slots for the next 3 weekdays
    int addedDays = 0;
    int dayCounter = 0;
    
    while (addedDays < 3 && dayCounter < 7) {
      DateTime date = startDate.add(Duration(days: dayCounter));
      if (date.weekday <= 5) { // Monday to Friday
        // Morning slots
        fallbackSlots.addAll([
          {
            "date": _formatDate(date),
            "time": "09:00",
            "doctor": fallbackDoctors[0],
            "clinic": widget.clinic.name
          },
          {
            "date": _formatDate(date),
            "time": "11:00",
            "doctor": fallbackDoctors[1],
            "clinic": widget.clinic.name
          },
        ]);
        
        // Afternoon slots
        fallbackSlots.addAll([
          {
            "date": _formatDate(date),
            "time": "14:00",
            "doctor": fallbackDoctors[2],
            "clinic": widget.clinic.name
          },
          {
            "date": _formatDate(date),
            "time": "16:00",
            "doctor": fallbackDoctors[addedDays % fallbackDoctors.length],
            "clinic": widget.clinic.name
          },
        ]);
        
        addedDays++;
      }
      dayCounter++;
    }
    
    return fallbackSlots;
  }

  List<Map<String, dynamic>> _generateBasicFallbackSlots() {
    // Emergency basic slots when all else fails
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return [
      {
        "date": _formatDate(tomorrow),
        "time": "09:00",
        "doctor": "Available Doctor",
        "clinic": widget.clinic.name
      },
      {
        "date": _formatDate(tomorrow),
        "time": "14:00",
        "doctor": "Available Doctor",
        "clinic": widget.clinic.name
      },
      {
        "date": _formatDate(tomorrow.add(const Duration(days: 1))),
        "time": "10:00",
        "doctor": "General Practitioner",
        "clinic": widget.clinic.name
      },
      {
        "date": _formatDate(tomorrow.add(const Duration(days: 1))),
        "time": "15:00",
        "doctor": "General Practitioner",
        "clinic": widget.clinic.name
      },
    ];
  }

  void _nextStep() async {
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

    if (_currentStep == 0) {
      await _callAppointmentBookingAPI();
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
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.softGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your appointment has been successfully booked for ${_selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'the selected date'} at ${_selectedTimeSlot ?? 'the selected time'}.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.greyText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAIUrgencyAssessment() {
    if (_caseType != null) {
      return _caseType!['case_type'];
    }
    return 'ROUTINE';
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.greyText,
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
    return Container(
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
          _buildStepContent(),
          const SizedBox(height: 24),
          _buildNavigationButtons(),
        ],
      ),
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
              color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SELECT ALL THAT APPLY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.greyText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: allSymptomOptions.length,
              itemBuilder: (context, index) {
                final symptom = allSymptomOptions[index];
                final isSelected = _selectedSymptoms.contains(symptom);
                
                if (symptom == 'Other') {
                  return _buildOtherOptionTile(isSelected, () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    });
                  });
                }
                
                return _buildOptionTile(symptom, isSelected, () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(symptom);
                    } else {
                      _selectedSymptoms.add(symptom);
                    }
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyStep() {
    if (_isLoadingAIResponse) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getQuestionTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryBlue),
                    const SizedBox(height: 16),
                    Text(
                      'AI is analyzing your symptoms...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.greyText,
                        fontWeight: FontWeight.w500,
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

    final aiUrgency = _getAIUrgencyAssessment();
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getUrgencyBorderColor(aiUrgency),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getUrgencyIcon(aiUrgency),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getUrgencyDisplayName(aiUrgency),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getUrgencyBorderColor(aiUrgency),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'AI Assessment Result',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.greyText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _caseType?['response_template'] ?? _getUrgencyMessage(aiUrgency),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionStep() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // AI Recommendation Banner
          if (_recommendedTime != null && _recommendedTime!['slot_found'] == true) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.smart_toy_rounded,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI recommends: ${_recommendedTime!['display_date']} at ${_recommendedTime!['display_time']} with ${_recommendedTime!['doctor']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Refined User Message Card
          if (_refinedUserMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.softGreen,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.softGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assessment Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.softGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _refinedUserMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Fallback mode indicator (show only when using fallback slots)
          if (_isUsingFallbackData()) ...[  
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing general availability. Contact clinic for updated slots.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Available Time Slots
          const Text(
            'Available appointments:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 12),
          
          // Scrollable time slots
          Expanded(
            child: _buildAvailableTimeSlots(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTimeSlots() {
    // Ensure we always have fallback slots if empty
    List<Map<String, dynamic>> slotsToShow = _availableTimeSlots;
    
    // Double check - if still empty, generate emergency fallback
    if (slotsToShow.isEmpty) {
      slotsToShow = _generateBasicFallbackSlots();
    }

    if (slotsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: AppTheme.greyText,
            ),
            const SizedBox(height: 16),
            Text(
              'No available slots found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please try again later or contact the clinic directly',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group slots by date
    Map<String, List<Map<String, dynamic>>> groupedSlots = {};
    for (var slot in slotsToShow) {
      String date = slot['date'];
      if (!groupedSlots.containsKey(date)) {
        groupedSlots[date] = [];
      }
      groupedSlots[date]!.add(slot);
    }

    return ListView.builder(
      itemCount: groupedSlots.keys.length,
      itemBuilder: (context, index) {
        String date = groupedSlots.keys.elementAt(index);
        List<Map<String, dynamic>> daySlots = groupedSlots[date]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              ...daySlots.map((slot) => _buildTimeSlotCard(slot)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    bool isRecommended = _recommendedTime != null &&
        _recommendedTime!['display_date'] == slot['date'] &&
        _recommendedTime!['display_time'] == slot['time'];
    
    bool isSelected = _selectedDate != null &&
        _selectedTimeSlot != null &&
        _formatDate(_selectedDate!) == slot['date'] &&
        _selectedTimeSlot == slot['time'];

    return GestureDetector(
      onTap: () {
        setState(() {
          List<String> dateParts = slot['date'].split('-');
          _selectedDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          _selectedTimeSlot = slot['time'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.lightBlue
              : isRecommended 
                  ? AppTheme.lightGreen
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : isRecommended
                    ? AppTheme.softGreen
                    : Colors.grey.shade300,
            width: isSelected || isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : isRecommended
                              ? AppTheme.softGreen
                              : AppTheme.greyText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      slot['time'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.darkText,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AI Recommended',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  slot['doctor'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateHeader(String dateString) {
    List<String> parts = dateString.split('-');
    DateTime date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildConfirmationStep() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getQuestionTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                  _buildSummaryItem(
                    'Clinic',
                    widget.clinic.name,
                  ),
                  _buildSummaryItem(
                    'Symptoms',
                    _selectedSymptoms.join(', '),
                  ),
                  _buildSummaryItem(
                    'Priority Level',
                    _getUrgencyDisplayName(_getAIUrgencyAssessment()),
                  ),
                  _buildSummaryItem(
                    'Date & Time',
                    _selectedDate != null && _selectedTimeSlot != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at $_selectedTimeSlot'
                        : 'Not selected',
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.greyText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
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
        if (_currentStep > 0 && !_isLoadingAIResponse) ...[
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppTheme.greyText),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: AppTheme.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoadingAIResponse ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoadingAIResponse ? AppTheme.greyText : AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: _isLoadingAIResponse
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _currentStep == 3 ? 'Confirm Appointment' : 'Continue',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isRadio ? null : BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      isRadio ? Icons.circle : Icons.check,
                      color: Colors.white,
                      size: isRadio ? 12 : 14,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.darkText,
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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.darkText,
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
              decoration: InputDecoration(
                hintText: 'Describe your symptoms...',
                hintStyle: TextStyle(
                  color: AppTheme.greyText,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getUrgencyDisplayName(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return 'Emergency Priority';
      case 'URGENT':
        return 'Urgent Priority';
      case 'ROUTINE':
        return 'Routine Priority';
      case 'NON_URGENT':
        return 'Non-Urgent Priority';
      default:
        return 'Standard Priority';
    }
  }

  Color _getUrgencyBackgroundColor(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return AppTheme.lightRed;
      case 'URGENT':
        return AppTheme.lightOrange;
      case 'ROUTINE':
        return AppTheme.lightGreen;
      case 'NON_URGENT':
        return AppTheme.lightBlue;
      default:
        return AppTheme.background;
    }
  }

  Color _getUrgencyBorderColor(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return AppTheme.softRed;
      case 'URGENT':
        return AppTheme.softOrange;
      case 'ROUTINE':
        return AppTheme.softGreen;
      case 'NON_URGENT':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.greyText;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return Icons.local_hospital_rounded;
      case 'URGENT':
        return Icons.warning_rounded;
      case 'ROUTINE':
        return Icons.schedule_rounded;
      case 'NON_URGENT':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getUrgencyMessage(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return 'Your symptoms indicate a potential emergency. Please seek immediate medical attention.';
      case 'URGENT':
        return 'Your symptoms require prompt medical attention. We recommend scheduling an appointment within 24-48 hours.';
      case 'ROUTINE':
        return 'Your symptoms can be addressed during a routine appointment. Please schedule at your convenience.';
      case 'NON_URGENT':
        return 'Your symptoms are mild and can be monitored. Consider scheduling a routine check-up.';
      default:
        return '';
    }
  }
}

