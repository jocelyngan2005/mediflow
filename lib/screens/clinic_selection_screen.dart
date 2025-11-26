import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/widgets/clinic_card.dart';
import 'package:mediflow/screens/main_menu_screen.dart';

class ClinicSelectionScreen extends StatefulWidget {
  final bool isGuest;

  const ClinicSelectionScreen({super.key, required this.isGuest});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  bool _isMapView = false;

  // Sample clinic data
  final List<Clinic> _clinics = [
    Clinic(
      name: 'Klinik Kesihatan Bandar',
      address: 'Jalan Putra 1, Kuala Lumpur',
      distance: '0.5 km',
      hours: 'Mon-Fri: 8:00 AM - 5:00 PM',
      isOpen: true,
    ),
    Clinic(
      name: 'Klinik Dr. Ahmad',
      address: 'Taman Desa, Kuala Lumpur',
      distance: '1.2 km',
      hours: 'Mon-Sat: 9:00 AM - 9:00 PM',
      isOpen: true,
    ),
    Clinic(
      name: 'Pusat Kesihatan Setapak',
      address: 'Setapak, Kuala Lumpur',
      distance: '2.0 km',
      hours: 'Mon-Sun: 24 Hours',
      isOpen: true,
    ),
    Clinic(
      name: 'Klinik Famili Wangsa Maju',
      address: 'Wangsa Maju, Kuala Lumpur',
      distance: '2.8 km',
      hours: 'Mon-Fri: 8:00 AM - 10:00 PM',
      isOpen: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Clinic'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppTheme.lightPeach,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.softPeach),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Guest Mode: Profile saving disabled',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkText,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for clinics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: AppTheme.lightBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: AppTheme.primaryBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Map View',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Map integration coming soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _clinics.length,
      itemBuilder: (context, index) {
        return ClinicCard(
          clinic: _clinics[index],
          onSelect: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainMenuScreen(
                  clinic: _clinics[index],
                  isGuest: widget.isGuest,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Clinic {
  final String name;
  final String address;
  final String distance;
  final String hours;
  final bool isOpen;

  Clinic({
    required this.name,
    required this.address,
    required this.distance,
    required this.hours,
    required this.isOpen,
  });
}

