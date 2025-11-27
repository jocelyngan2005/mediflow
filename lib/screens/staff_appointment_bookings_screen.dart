import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class StaffAppointmentBookingsScreen extends StatefulWidget {
  final Clinic clinic;

  const StaffAppointmentBookingsScreen({super.key, required this.clinic});

  @override
  State<StaffAppointmentBookingsScreen> createState() => _StaffAppointmentBookingsScreenState();
}

class _StaffAppointmentBookingsScreenState extends State<StaffAppointmentBookingsScreen> {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedUrgency = 'All';
  String _selectedDoctor = 'All';
  bool _isLoading = true;

  final List<String> _urgencyLevels = ['All', 'Routine', 'Urgent', 'Emergency'];
  final List<String> _doctors = [
    'All',
    'Dr. Ahmad Rahman',
    'Dr. Sarah Lim',
    'Dr. Raj Kumar',
    'Dr. Fatimah Ali',
    'Dr. Chen Wei Ming'
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    // Simulate loading appointments
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _appointments = _generateMockAppointments();
        _filterAppointments();
        _isLoading = false;
      });
    });
  }

  List<Appointment> _generateMockAppointments() {
    final now = DateTime.now();
    return [
      // Today's appointments
      Appointment(
        id: 'APT001',
        patientName: 'Ahmad Bin Hassan',
        patientPhone: '+60123456789',
        doctor: 'Dr. Ahmad Rahman',
        dateTime: DateTime(now.year, now.month, now.day, 9, 0),
        urgency: 'Routine',
        symptoms: 'Regular checkup, diabetes follow-up',
        status: 'Confirmed',
        notes: 'Bring previous blood test results',
      ),
      Appointment(
        id: 'APT002',
        patientName: 'Siti Nurhaliza',
        patientPhone: '+60198765432',
        doctor: 'Dr. Sarah Lim',
        dateTime: DateTime(now.year, now.month, now.day, 10, 30),
        urgency: 'Urgent',
        symptoms: 'Severe headache, nausea',
        status: 'Confirmed',
        notes: 'Patient requests female doctor',
      ),
      Appointment(
        id: 'APT003',
        patientName: 'Raj Patel',
        patientPhone: '+60187654321',
        doctor: 'Dr. Raj Kumar',
        dateTime: DateTime(now.year, now.month, now.day, 11, 15),
        urgency: 'Routine',
        symptoms: 'Annual health screening',
        status: 'Pending',
        notes: 'Fasting blood test required',
      ),
      Appointment(
        id: 'APT004',
        patientName: 'Lee Mei Ling',
        patientPhone: '+60176543210',
        doctor: 'Dr. Chen Wei Ming',
        dateTime: DateTime(now.year, now.month, now.day, 14, 0),
        urgency: 'Emergency',
        symptoms: 'Chest pain, shortness of breath',
        status: 'Confirmed',
        notes: 'Rush appointment - cardiac concern',
      ),
      Appointment(
        id: 'APT005',
        patientName: 'Fatimah Abdullah',
        patientPhone: '+60165432109',
        doctor: 'Dr. Fatimah Ali',
        dateTime: DateTime(now.year, now.month, now.day, 15, 30),
        urgency: 'Routine',
        symptoms: 'Pregnancy checkup - 2nd trimester',
        status: 'Confirmed',
        notes: 'Ultrasound scheduled',
      ),
      
      // Tomorrow's appointments
      Appointment(
        id: 'APT006',
        patientName: 'Muhammad Ali',
        patientPhone: '+60154321098',
        doctor: 'Dr. Ahmad Rahman',
        dateTime: DateTime(now.year, now.month, now.day + 1, 9, 30),
        urgency: 'Urgent',
        symptoms: 'High fever, persistent cough',
        status: 'Confirmed',
        notes: 'Possible respiratory infection',
      ),
      Appointment(
        id: 'APT007',
        patientName: 'Jennifer Wong',
        patientPhone: '+60143210987',
        doctor: 'Dr. Sarah Lim',
        dateTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        urgency: 'Routine',
        symptoms: 'Skin rash, allergic reaction',
        status: 'Pending',
        notes: 'Bring list of recent medications',
      ),
      Appointment(
        id: 'APT008',
        patientName: 'Kumar Selvam',
        patientPhone: '+60132109876',
        doctor: 'Dr. Raj Kumar',
        dateTime: DateTime(now.year, now.month, now.day + 1, 16, 45),
        urgency: 'Routine',
        symptoms: 'Joint pain, arthritis consultation',
        status: 'Confirmed',
        notes: 'X-ray results available',
      ),

      // Day after tomorrow
      Appointment(
        id: 'APT009',
        patientName: 'Aminah Kassim',
        patientPhone: '+60121098765',
        doctor: 'Dr. Fatimah Ali',
        dateTime: DateTime(now.year, now.month, now.day + 2, 10, 15),
        urgency: 'Emergency',
        symptoms: 'Severe abdominal pain',
        status: 'Confirmed',
        notes: 'Emergency slot - investigate immediately',
      ),
      Appointment(
        id: 'APT010',
        patientName: 'David Tan',
        patientPhone: '+60110987654',
        doctor: 'Dr. Chen Wei Ming',
        dateTime: DateTime(now.year, now.month, now.day + 2, 13, 30),
        urgency: 'Routine',
        symptoms: 'Eye examination, vision problems',
        status: 'Pending',
        notes: 'New patient registration needed',
      ),
    ];
  }

  void _filterAppointments() {
    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        // Date filter
        final appointmentDate = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );
        final selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        
        final dateMatch = appointmentDate == selectedDate;
        
        // Urgency filter
        final urgencyMatch = _selectedUrgency == 'All' || appointment.urgency == _selectedUrgency;
        
        // Doctor filter
        final doctorMatch = _selectedDoctor == 'All' || appointment.doctor == _selectedDoctor;
        
        return dateMatch && urgencyMatch && doctorMatch;
      }).toList();
      
      // Sort by time
      _filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Emergency':
        return Colors.red;
      case 'Urgent':
        return Colors.orange;
      case 'Routine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appointment Bookings', style: TextStyle(fontSize: 18)),
            Text(
              widget.clinic.clinicId == 'Clinic_Staff' ? 'Klinik Bandar Utama' : widget.clinic.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadAppointments();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters Section
                Container(
                  padding: const EdgeInsets.all(16),
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
                      // Date Picker
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                  _filterAppointments();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.primaryBlue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(color: AppTheme.primaryBlue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Urgency and Doctor Filters
                      Row(
                        children: [
                          // Urgency Filter
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.priority_high, size: 16, color: AppTheme.primaryBlue),
                                    SizedBox(width: 4),
                                    Text('Urgency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedUrgency,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    isDense: true,
                                  ),
                                  items: _urgencyLevels.map((urgency) {
                                    return DropdownMenuItem(
                                      value: urgency,
                                      child: Text(urgency, style: const TextStyle(fontSize: 12)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUrgency = value!;
                                    });
                                    _filterAppointments();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Doctor Filter
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_hospital, size: 16, color: AppTheme.primaryBlue),
                                    SizedBox(width: 4),
                                    Text('Doctor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedDoctor,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    isDense: true,
                                  ),
                                  items: _doctors.map((doctor) {
                                    return DropdownMenuItem(
                                      value: doctor,
                                      child: Text(
                                        doctor.length > 12 ? '${doctor.substring(0, 12)}...' : doctor,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDoctor = value!;
                                    });
                                    _filterAppointments();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Summary Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Total',
                        '${_filteredAppointments.length}',
                        Icons.event,
                        AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Confirmed',
                        '${_filteredAppointments.where((a) => a.status == 'Confirmed').length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Emergency',
                        '${_filteredAppointments.where((a) => a.urgency == 'Emergency').length}',
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),
                ),

                // Appointments List
                Expanded(
                  child: _filteredAppointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: AppTheme.greyText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No appointments found for selected filters',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime.now();
                                    _selectedUrgency = 'All';
                                    _selectedDoctor = 'All';
                                  });
                                  _filterAppointments();
                                },
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(_filteredAppointments[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getUrgencyColor(appointment.urgency).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getUrgencyColor(appointment.urgency).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            appointment.urgency == 'Emergency' 
                ? Icons.local_hospital 
                : appointment.urgency == 'Urgent'
                    ? Icons.priority_high
                    : Icons.event,
            color: _getUrgencyColor(appointment.urgency),
            size: 20,
          ),
        ),
        title: Text(
          appointment.patientName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppTheme.greyText),
                const SizedBox(width: 4),
                Text(
                  '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appointment.doctor,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildDetailRow('Patient ID', appointment.id, Icons.badge),
          const SizedBox(height: 8),
          _buildDetailRow('Phone', appointment.patientPhone, Icons.phone),
          const SizedBox(height: 8),
          _buildDetailRow('Symptoms', appointment.symptoms, Icons.healing),
          const SizedBox(height: 8),
          _buildDetailRow('Urgency', appointment.urgency, Icons.priority_high, 
              valueColor: _getUrgencyColor(appointment.urgency)),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow('Notes', appointment.notes, Icons.note),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditStatusDialog(appointment);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle call patient
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${appointment.patientName}...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call Patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.greyText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.greyText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditStatusDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status - ${appointment.patientName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Confirmed'),
              leading: Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                _updateAppointmentStatus(appointment.id, 'Confirmed');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pending'),
              leading: Icon(Icons.schedule, color: Colors.orange),
              onTap: () {
                _updateAppointmentStatus(appointment.id, 'Pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Cancelled'),
              leading: Icon(Icons.cancel, color: Colors.red),
              onTap: () {
                _updateAppointmentStatus(appointment.id, 'Cancelled');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateAppointmentStatus(String appointmentId, String newStatus) {
    setState(() {
      final index = _appointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(status: newStatus);
      }
    });
    _filterAppointments();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment status updated to $newStatus'),
        backgroundColor: _getStatusColor(newStatus),
      ),
    );
  }
}

class Appointment {
  final String id;
  final String patientName;
  final String patientPhone;
  final String doctor;
  final DateTime dateTime;
  final String urgency;
  final String symptoms;
  final String status;
  final String notes;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.doctor,
    required this.dateTime,
    required this.urgency,
    required this.symptoms,
    required this.status,
    required this.notes,
  });

  Appointment copyWith({
    String? id,
    String? patientName,
    String? patientPhone,
    String? doctor,
    DateTime? dateTime,
    String? urgency,
    String? symptoms,
    String? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctor: doctor ?? this.doctor,
      dateTime: dateTime ?? this.dateTime,
      urgency: urgency ?? this.urgency,
      symptoms: symptoms ?? this.symptoms,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
