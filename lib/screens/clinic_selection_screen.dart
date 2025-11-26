import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/widgets/clinic_card.dart';
import 'package:mediflow/screens/profile_screen.dart';

class ClinicSelectionScreen extends StatefulWidget {
  final bool isGuest;

  const ClinicSelectionScreen({super.key, required this.isGuest});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  // Filter state
  bool _showOpenOnly = false;
  int _minRating = 0;
  String _sortBy = 'distance'; // distance, rating, name

  // Sample clinic data
  final List<Clinic> _clinics = [
    Clinic(
      clinicId: 'klinik-bandar-utama',
      name: 'Klinik Bandar Utama',
      address: '191, Jalan Bandar Puteri Jaya 1/2, Bandar Puteri Jaya, 08000 Sungai Petani, Kedah',
      distance: '0.5km',
      hours: 'Wednesday 8:00am to 8:00pm',
      isOpen: true,
      phoneNumber: '010-309 5217',
      rating: 5,
    ),
    Clinic(
      clinicId: 'klinik-sri-hartamas',
      name: 'Klinik Sri Hartamas',
      address: 'Taman Desa, Kuala Lumpur',
      distance: '1.2km',
      hours: 'Mon-Sat: 9:00 AM - 9:00 PM',
      isOpen: true,
      phoneNumber: '012-345 6789',
      rating: 4,
    ),
    Clinic(
      clinicId: 'klinik-desa-jaya',
      name: 'Klinik Desa Jaya',
      address: 'Setapak, Kuala Lumpur',
      distance: '2.0km',
      hours: 'Mon-Sun: 24 Hours',
      isOpen: true,
      phoneNumber: '011-234 5678',
      rating: 5,
    ),
    Clinic(
      clinicId: 'klinik-wangsa',
      name: 'Klinik Famili Wangsa Maju',
      address: 'Wangsa Maju, Kuala Lumpur',
      distance: '2.8km',
      hours: 'Mon-Fri: 8:00 AM - 10:00 PM',
      isOpen: false,
      phoneNumber: '013-456 7890',
      rating: 3,
    ),
  ];

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
                    // Top row with filter icon and profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Filter icon
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _showFilterOptions,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // Profile indicator
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(
                                  clinic: _clinics.first,
                                  isGuest: widget.isGuest,
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                                Text(
                                  widget.isGuest ? 'Guest' : 'Ahmad Abdullah',
                                  style: const TextStyle(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      "Let's Find Your Clinic",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Search bar with location button
                    Row(
                      children: [
                        Expanded(
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
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for clinics',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Location button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.my_location,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            ),
                            onPressed: () {
                              // Handle location button press
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Finding nearby clinics...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Find nearby clinics',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Clinics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _showOpenOnly = false;
                            _minRating = 0;
                            _sortBy = 'distance';
                          });
                          setState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Show only open clinics
                  CheckboxListTile(
                    title: const Text('Show only open clinics'),
                    value: _showOpenOnly,
                    onChanged: (bool? value) {
                      setModalState(() {
                        _showOpenOnly = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  // Minimum rating
                  Text(
                    'Minimum Rating: ${_minRating == 0 ? 'Any' : '$_minRating stars'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _minRating.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _minRating == 0 ? 'Any' : '$_minRating stars',
                    onChanged: (double value) {
                      setModalState(() {
                        _minRating = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Sort by
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Distance'),
                        selected: _sortBy == 'distance',
                        onSelected: (bool selected) {
                          setModalState(() {
                            _sortBy = 'distance';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Rating'),
                        selected: _sortBy == 'rating',
                        onSelected: (bool selected) {
                          setModalState(() {
                            _sortBy = 'rating';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Name'),
                        selected: _sortBy == 'name',
                        onSelected: (bool selected) {
                          setModalState(() {
                            _sortBy = 'name';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Refresh the main screen with filters
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Clinic> _getFilteredAndSortedClinics() {
    List<Clinic> filtered = _clinics.where((clinic) {
      if (_showOpenOnly && !clinic.isOpen) return false;
      if (_minRating > 0 && clinic.rating < _minRating) return false;
      return true;
    }).toList();

    // Sort clinics
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'name':
          return a.name.compareTo(b.name);
        case 'distance':
        default:
          // Extract numeric part from distance string (e.g., "0.5km" -> 0.5)
          double distA = double.tryParse(a.distance.replaceAll('km', '')) ?? 0;
          double distB = double.tryParse(b.distance.replaceAll('km', '')) ?? 0;
          return distA.compareTo(distB);
      }
    });

    return filtered;
  }

  Widget _buildListView() {
    final filteredClinics = _getFilteredAndSortedClinics();

    if (filteredClinics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No clinics found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredClinics.length,
      itemBuilder: (context, index) {
        return ClinicCard(
          clinic: filteredClinics[index],
        );
      },
    );
  }
}

class Clinic {
  final String clinicId;  // Added for API integration
  final String name;
  final String address;
  final String distance;
  final String hours;
  final bool isOpen;
  final String phoneNumber;
  final int rating;

  Clinic({
    required this.clinicId,
    required this.name,
    required this.address,
    required this.distance,
    required this.hours,
    required this.isOpen,
    required this.phoneNumber,
    required this.rating,
  });
}

