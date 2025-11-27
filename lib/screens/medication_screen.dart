import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class MedicationScreen extends StatefulWidget {
  final Clinic clinic;

  const MedicationScreen({super.key, required this.clinic});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Medication> _medications = [];
  List<Medication> _filteredMedications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMedications() async {
    try {
      final csvString = await rootBundle.loadString('assets/medication_inventory.csv');
      final lines = csvString.split('\n');
      
      // Skip header row and filter by Klinik Bandar Utama
      final medicationData = <List<String>>[];
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final row = _parseCsvLine(lines[i]);
        if (row.length > 11 && row[11].trim() == 'Klinik Bandar Utama') {
          medicationData.add(row);
        }
      }
      
      setState(() {
        _medications = medicationData.map((row) => _createMedicationFromCsv(row)).toList();
        _filteredMedications = _medications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() {
        _medications = [];
        _filteredMedications = [];
        _isLoading = false;
      });
    }
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    String current = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current.trim());
    return result;
  }

  Medication _createMedicationFromCsv(List<String> row) {
    // CSV columns: english_name, malay_name, generic_name, stock_quantity, unit, price_rm, reorder_level, category, common_uses, location, supplier, clinic, expiry_date
    String getValue(int index, String defaultValue) {
      return (index < row.length && row[index].isNotEmpty) ? row[index] : defaultValue;
    }
    
    return Medication(
      name: getValue(0, 'Unknown'),
      genericName: getValue(2, 'Unknown'),
      stock: int.tryParse(getValue(3, '0')) ?? 0,
      minStock: int.tryParse(getValue(6, '0')) ?? 0,
      location: getValue(9, 'Unknown'),
      price: double.tryParse(getValue(5, '0.0')) ?? 0.0,
      expiryDate: _parseDate(getValue(12, '')),
      category: getValue(7, 'Unknown'),
      unit: getValue(4, 'units'),
      malayName: getValue(1, ''),
      commonUses: getValue(8, ''),
      supplier: getValue(10, ''),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      // Parse date in format DD/MM/YYYY
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $dateStr');
    }
    return DateTime.now().add(const Duration(days: 365)); // Default to 1 year from now
  }

  void _filterMedications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedications = _medications;
      } else {
        _filteredMedications = _medications
            .where((med) =>
                med.name.toLowerCase().contains(query.toLowerCase()) ||
                med.genericName.toLowerCase().contains(query.toLowerCase()) ||
                med.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Color _getStockLevelColor(Medication med) {
    if (med.stock < med.minStock) {
      return AppTheme.softRed;
    } else if (med.stock < med.minStock * 1.5) {
      return AppTheme.softOrange;
    } else {
      return AppTheme.softGreen;
    }
  }

  String _getStockLevelText(Medication med) {
    if (med.stock < med.minStock) {
      return 'Low Stock';
    } else if (med.stock < med.minStock * 1.5) {
      return 'Medium Stock';
    } else {
      return 'Good Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medication Lookup', style: TextStyle(fontSize: 18)),
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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
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
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterMedications,
                    decoration: InputDecoration(
                      hintText: 'Search by drug name or category...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterMedications('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Stock Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStockSummaryCard(
                        'Total Items',
                        '${_medications.length}',
                        Icons.medication,
                        AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      _buildStockSummaryCard(
                        'Low Stock',
                        '${_medications.where((m) => m.stock < m.minStock).length}',
                        Icons.warning,
                        AppTheme.softRed,
                      ),
                    ],
                  ),
                ),

                // Medications List
                Expanded(
                  child: _filteredMedications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppTheme.greyText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No medications found',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredMedications.length,
                          itemBuilder: (context, index) {
                            return _buildMedicationCard(_filteredMedications[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLowStockReport,
        backgroundColor: AppTheme.softRed,
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Low Stock Alert'),
      ),
    );
  }

  Widget _buildStockSummaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Medication med) {
    final stockColor = _getStockLevelColor(med);
    final daysUntilExpiry = med.expiryDate.difference(DateTime.now()).inDays;
    final isNearExpiry = daysUntilExpiry < 90;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: med.stock < med.minStock
              ? AppTheme.softRed.withOpacity(0.3)
              : Colors.transparent,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: stockColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.medication, color: stockColor, size: 28),
        ),
        title: Text(
          med.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              med.genericName,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyText,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: stockColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${med.stock} ${med.unit}',
                style: TextStyle(
                  fontSize: 11,
                  color: stockColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isNearExpiry) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Expires in $daysUntilExpiry days',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.softOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow('Category', med.category, Icons.category),
          const SizedBox(height: 8),
          _buildInfoRow('Location', med.location, Icons.location_on),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Stock Level',
            _getStockLevelText(med),
            Icons.inventory,
            valueColor: stockColor,
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Min Stock', '${med.minStock} ${med.unit}', Icons.warning_amber),
          const SizedBox(height: 8),
          _buildInfoRow('Price per unit', 'RM ${med.price.toStringAsFixed(2)}', Icons.attach_money),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Expiry Date',
            '${med.expiryDate.day}/${med.expiryDate.month}/${med.expiryDate.year}',
            Icons.calendar_today,
            valueColor: isNearExpiry ? AppTheme.softOrange : null,
          ),
          if (med.supplier.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Supplier', med.supplier, Icons.business),
          ],
          if (med.commonUses.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Uses', med.commonUses, Icons.healing),
          ],
          const SizedBox(height: 12),
          if (med.stock < med.minStock)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.softRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stock below minimum level. Consider reordering.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.softRed.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.greyText),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Medications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Medications'),
              onTap: () {
                setState(() {
                  _filteredMedications = _medications;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Low Stock Only'),
              leading: const Icon(Icons.warning, color: AppTheme.softRed),
              onTap: () {
                setState(() {
                  _filteredMedications =
                      _medications.where((m) => m.stock < m.minStock).toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Near Expiry'),
              leading: const Icon(Icons.calendar_today, color: AppTheme.softOrange),
              onTap: () {
                setState(() {
                  _filteredMedications = _medications
                      .where((m) => m.expiryDate.difference(DateTime.now()).inDays < 90)
                      .toList();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLowStockReport() {
    final lowStockMeds = _medications.where((m) => m.stock < m.minStock).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.softRed),
            SizedBox(width: 8),
            Text('Low Stock Alert'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: lowStockMeds.isEmpty
              ? const Text('All medications are well stocked! ✅')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: lowStockMeds.length,
                  itemBuilder: (context, index) {
                    final med = lowStockMeds[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(med.name),
                      subtitle: Text('${med.stock} units (min: ${med.minStock})'),
                      trailing: Text(
                        'Need: ${med.minStock - med.stock}',
                        style: const TextStyle(
                          color: AppTheme.softRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (lowStockMeds.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating reorder report...')),
                );
                Navigator.pop(context);
              },
              child: const Text('Generate Report'),
            ),
        ],
      ),
    );
  }
}

class Medication {
  final String name;
  final String genericName;
  final int stock;
  final int minStock;
  final String location;
  final double price;
  final DateTime expiryDate;
  final String category;
  final String unit;
  final String malayName;
  final String commonUses;
  final String supplier;

  Medication({
    required this.name,
    required this.genericName,
    required this.stock,
    required this.minStock,
    required this.location,
    required this.price,
    required this.expiryDate,
    required this.category,
    required this.unit,
    this.malayName = '',
    this.commonUses = '',
    this.supplier = '',
  });
}

