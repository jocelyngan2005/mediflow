import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class StaffClinicAnalyticsScreen extends StatefulWidget {
  final Clinic clinic;

  const StaffClinicAnalyticsScreen({super.key, required this.clinic});

  @override
  State<StaffClinicAnalyticsScreen> createState() => _StaffClinicAnalyticsScreenState();
}

class _StaffClinicAnalyticsScreenState extends State<StaffClinicAnalyticsScreen> {
  String _selectedTimeframe = 'Today';
  bool _isLoading = true;

  final List<String> _timeframes = ['Today', 'This Week', 'This Month'];

  // Sample data
  Map<String, int> _urgencyData = {'Routine': 15, 'Urgent': 8, 'Emergency': 3};
  List<Map<String, dynamic>> _appointmentTimeData = [];
  List<Map<String, dynamic>> _medicineStockData = [];
  Map<String, dynamic> _summaryStats = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _generateDataForTimeframe();
        _isLoading = false;
      });
    });
  }

  void _generateDataForTimeframe() {
    // Update data based on selected timeframe
    switch (_selectedTimeframe) {
      case 'Today':
        _urgencyData = {'Routine': 15, 'Urgent': 8, 'Emergency': 3};
        _appointmentTimeData = [
          {'label': '8:00', 'count': 2},
          {'label': '9:00', 'count': 4},
          {'label': '10:00', 'count': 6},
          {'label': '11:00', 'count': 5},
          {'label': '12:00', 'count': 2},
          {'label': '14:00', 'count': 7},
          {'label': '15:00', 'count': 8},
          {'label': '16:00', 'count': 6},
          {'label': '17:00', 'count': 4},
        ];
        _summaryStats = {
          'totalAppointments': 26,
          'totalRevenue': 2340.0,
          'avgWaitTime': '12 mins',
          'patientSatisfaction': 4.6,
        };
        break;
      case 'This Week':
        _urgencyData = {'Routine': 89, 'Urgent': 34, 'Emergency': 12};
        _appointmentTimeData = [
          {'label': 'Mon', 'count': 28},
          {'label': 'Tue', 'count': 32},
          {'label': 'Wed', 'count': 26},
          {'label': 'Thu', 'count': 35},
          {'label': 'Fri', 'count': 30},
          {'label': 'Sat', 'count': 18},
          {'label': 'Sun', 'count': 12},
        ];
        _summaryStats = {
          'totalAppointments': 181,
          'totalRevenue': 16290.0,
          'avgWaitTime': '15 mins',
          'patientSatisfaction': 4.5,
        };
        break;
      case 'This Month':
        _urgencyData = {'Routine': 342, 'Urgent': 156, 'Emergency': 45};
        _appointmentTimeData = [
          {'label': 'Week 1', 'count': 145},
          {'label': 'Week 2', 'count': 167},
          {'label': 'Week 3', 'count': 156},
          {'label': 'Week 4', 'count': 178},
        ];
        _summaryStats = {
          'totalAppointments': 687,
          'totalRevenue': 61830.0,
          'avgWaitTime': '14 mins',
          'patientSatisfaction': 4.7,
        };
        break;
    }

    _medicineStockData = [
      {'name': 'Panadol', 'current': 450, 'min': 100, 'level': 'High'},
      {'name': 'Chlorpheniramine', 'current': 65, 'min': 50, 'level': 'Medium'},
      {'name': 'Amoxicillin', 'current': 25, 'min': 30, 'level': 'Low'},
      {'name': 'Ibuprofen', 'current': 180, 'min': 75, 'level': 'High'},
      {'name': 'Cetirizine', 'current': 15, 'min': 25, 'level': 'Critical'},
      {'name': 'Metformin', 'current': 95, 'min': 50, 'level': 'High'},
      {'name': 'Omeprazole', 'current': 35, 'min': 40, 'level': 'Low'},
      {'name': 'Simvastatin', 'current': 120, 'min': 60, 'level': 'High'},
    ];
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

  Color _getStockLevelColor(String level) {
    switch (level) {
      case 'Critical':
        return Colors.red;
      case 'Low':
        return Colors.orange;
      case 'Medium':
        return AppTheme.primaryBlue;
      case 'High':
        return Colors.green;
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
            const Text('Clinic Analytics', style: TextStyle(fontSize: 18)),
            Text(
              widget.clinic.clinicId == 'Clinic_Staff' ? 'Klinik Bandar Utama' : widget.clinic.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedTimeframe,
            onSelected: (String value) {
              setState(() {
                _selectedTimeframe = value;
                _isLoading = true;
              });
              _loadAnalyticsData();
            },
            itemBuilder: (BuildContext context) {
              return _timeframes.map((String timeframe) {
                return PopupMenuItem<String>(
                  value: timeframe,
                  child: Text(timeframe),
                );
              }).toList();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedTimeframe,
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryBlue,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Reports Card
                  _buildReportsCard(),
                  const SizedBox(height: 20),
                  
                  // Summary Stats
                  _buildSummaryStats(),
                  const SizedBox(height: 20),
                  
                  // Urgency Distribution
                  _buildUrgencyDistribution(),
                  const SizedBox(height: 20),
                  
                  // Appointments Over Time
                  _buildAppointmentsOverTime(),
                  const SizedBox(height: 20),
                  
                  // Medicine Stock Analytics
                  _buildMedicineStockAnalytics(),
                ],
              ),
            ),
    );
  }

  Widget _buildReportsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Icon(
            Icons.assessment,
            color: AppTheme.softOrange,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate detailed clinic reports for $_selectedTimeframe',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              _showReportsDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Generate',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Summary Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCompactStatItem(
                  'Appointments',
                  '${_summaryStats['totalAppointments']}',
                  Icons.event,
                  AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildCompactStatItem(
                  'Revenue',
                  'RM ${(_summaryStats['totalRevenue'] as double).toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCompactStatItem(
                  'Wait Time',
                  _summaryStats['avgWaitTime'],
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildCompactStatItem(
                  'Satisfaction',
                  '${_summaryStats['patientSatisfaction']} ⭐',
                  Icons.sentiment_satisfied,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.assessment, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('Generate Reports'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Performance Report'),
              subtitle: Text('Appointments, revenue & satisfaction for $_selectedTimeframe'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('Performance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication, color: Colors.orange),
              title: const Text('Inventory Report'),
              subtitle: const Text('Medicine stock levels & alerts'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('Inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppTheme.primaryBlue),
              title: const Text('Schedule Report'),
              subtitle: Text('Appointment patterns for $_selectedTimeframe'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('Schedule');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _generateReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.file_download, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Generating $reportType Report for $_selectedTimeframe...'),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Widget _buildUrgencyDistribution() {
    final total = _urgencyData.values.reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Urgency Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Custom pie chart representation using circular progress indicators
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Pie chart visual
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Emergency (outer ring)
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: _urgencyData['Emergency']! / total,
                              strokeWidth: 20,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          // Urgent (middle ring)
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: _urgencyData['Urgent']! / total,
                              strokeWidth: 20,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          ),
                          // Routine (inner ring)
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: _urgencyData['Routine']! / total,
                              strokeWidth: 20,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          // Center text
                          Text(
                            '$total\nTotal',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Legend
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _urgencyData.entries.map((entry) {
                      final percentage = (entry.value / total * 100).toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getUrgencyColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} ($percentage%)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.greyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsOverTime() {
    final maxCount = _appointmentTimeData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b);
    
    String chartTitle = _selectedTimeframe == 'Today' 
        ? 'Appointments by Hour'
        : _selectedTimeframe == 'This Week'
            ? 'Appointments by Day'
            : 'Appointments by Week';
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                chartTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Custom bar chart using containers
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _appointmentTimeData.map((data) {
                final count = data['count'] as int;
                final label = data['label'] as String;
                final height = (count / maxCount) * 160; // Max height 160
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Count label
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Bar
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time label
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineStockAnalytics() {
    final criticalCount = _medicineStockData.where((m) => m['level'] == 'Critical').length;
    final lowCount = _medicineStockData.where((m) => m['level'] == 'Low').length;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Medicine Stock Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stock alerts
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$criticalCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text(
                            'Critical Stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$lowCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text(
                            'Low Stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Medicine stock list
          ..._medicineStockData.take(6).map((medicine) => _buildMedicineStockItem(medicine)),
          
          if (_medicineStockData.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Full medicine inventory coming soon!'),
                      ),
                    );
                  },
                  child: Text('View All ${_medicineStockData.length} Medicines'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineStockItem(Map<String, dynamic> medicine) {
    final current = medicine['current'] as int;
    final min = medicine['min'] as int;
    final level = medicine['level'] as String;
    final name = medicine['name'] as String;
    final percentage = (current / min * 100).clamp(0, 100);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStockLevelColor(level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStockLevelColor(level),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$current units',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStockLevelColor(level),
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Min: $min',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
