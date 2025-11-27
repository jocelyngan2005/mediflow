import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/services/api_service.dart';
import 'dart:convert';

class StaffAssistantScreen extends StatefulWidget {
  final Clinic clinic;

  const StaffAssistantScreen({super.key, required this.clinic});

  @override
  State<StaffAssistantScreen> createState() => _StaffAssistantScreenState();
}

class _StaffAssistantScreenState extends State<StaffAssistantScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _currentLanguage = 'BM'; // BM or EN
  bool _isConnected = false;
  bool _hasUserSentMessage = false;
  late AnimationController _dotAnimationController;

  // Quick suggestion chips for staff
  final List<String> _quickChipsBM = [
    'Stock Panadol',
    'Harga ubat demam',
    'Antibiotik tersedia',
    'Ubat alternatif',
    'Stock rendah',
    'Carian pantas',
  ];

  final List<String> _quickChipsEN = [
    'Panadol stock',
    'Fever medicine price',
    'Available antibiotics',
    'Alternative medicine',
    'Low stock',
    'Quick search',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for blinking dot
    _dotAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    // Simulate connection: red for 3 seconds, then green
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
    
    // Welcome message for staff
    _messages.add(ChatMessage(
      text: _currentLanguage == 'BM'
          ? 'Selamat datang, Kakitangan ${widget.clinic.name}! 👨‍⚕️\n\nSaya Staff AI Assistant anda. Saya boleh membantu dengan:\n• Carian stock ubat & ketersediaan\n• Harga ubat semasa\n• Ubat alternatif yang tersedia\n• Amaran stock rendah\n• Maklumat inventori klinik\n\nContoh: "Panadol stock tinggal berapa?" atau "Do we have Chlorpheniramine?"\n\nApa yang anda ingin semak?'
          : 'Welcome, ${widget.clinic.name} Staff! 👨‍⚕️\n\nI\'m your Staff AI Assistant. I can help with:\n• Medication stock & availability lookup\n• Current drug pricing\n• Available alternatives\n• Low stock alerts\n• Clinic inventory information\n\nExample: "Panadol stock tinggal berapa?" or "Do we have Chlorpheniramine?"\n\nWhat would you like to check?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dotAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _hasUserSentMessage = true; // Hide suggestions after first message
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Call the staff-specific medication lookup API
      ApiResponse<Map<String, dynamic>> response = await ApiService.sendStaffChatMessage(
        clinicId: widget.clinic.clinicId,
        message: text,
        language: _currentLanguage,
      );

      setState(() {
        if (response.success && response.data != null) {
          // Parse drug_entry JSON if available
          MedicationData? medData;
          if (response.data!['drug_entry'] != null && response.data!['drug_entry'] != '{}') {
            try {
              Map<String, dynamic> drugJson;
              
              if (response.data!['drug_entry'] is String) {
                String drugEntryStr = response.data!['drug_entry'];
                print('Raw drug entry string: $drugEntryStr');
                
                // Clean the string - remove [@0] or similar suffixes
                drugEntryStr = drugEntryStr.replaceAll(RegExp(r'\s*\[@\d+\]$'), '').trim();
                print('Cleaned drug entry string: $drugEntryStr');
                
                drugJson = Map<String, dynamic>.from(json.decode(drugEntryStr));
              } else {
                drugJson = Map<String, dynamic>.from(response.data!['drug_entry']);
              }
              
              print('Parsed drug JSON: $drugJson');
              medData = MedicationData.fromDrugEntry(drugJson);
              print('Created MedicationData: ${medData.medicationName}');
            } catch (e) {
              print('Error parsing drug_entry: $e');
              print('Raw drug_entry: ${response.data!['drug_entry']}');
            }
          } else {
            print('No drug_entry found or it is empty/null');
            print('Response data keys: ${response.data!.keys.toList()}');
          }
          
          _messages.add(ChatMessage(
            text: response.data!['medication_message'] ?? response.data!['reply'] ?? 'No response',
            isUser: false,
            timestamp: DateTime.now(),
            medicationData: medData,
          ));
        } else {
          // Show error message
          _messages.add(ChatMessage(
            text: _getErrorMessage(response.error ?? 'Unknown error'),
            isUser: false,
            timestamp: DateTime.now(),
            isSystem: true,
          ));
        }
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: _getErrorMessage('Network error: $e'),
          isUser: false,
          timestamp: DateTime.now(),
          isSystem: true,
        ));
        _isTyping = false;
      });
    }
    
    _scrollToBottom();
  }

  // Mock response generator for frontend prototype
  StaffChatResponse _generateMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    final isBM = _currentLanguage == 'BM';

    // Panadol queries
    if (message.contains('panadol') || message.contains('paracetamol')) {
      if (message.contains('stock') || message.contains('tinggal') || message.contains('ada')) {
        return StaffChatResponse(
          reply: isBM
              ? 'Panadol 500mg masih ada dalam stok. Berikut maklumat terperinci:'
              : 'Panadol 500mg is still in stock. Here are the details:',
          medicationData: MedicationData(
            medicationName: 'Panadol 500mg',
            quantity: 45,
            unit: 'boxes',
            price: 8.50,
            isLowStock: false,
            alternatives: ['Paracetamol 500mg', 'Uphamol 500mg', 'Tylenol 500mg'],
          ),
        );
      }
      if (message.contains('harga') || message.contains('price')) {
        return StaffChatResponse(
          reply: isBM
              ? 'Harga Panadol 500mg ialah RM 8.50 sekotak.'
              : 'Panadol 500mg price is RM 8.50 per box.',
          medicationData: MedicationData(
            medicationName: 'Panadol 500mg',
            quantity: 45,
            unit: 'boxes',
            price: 8.50,
            isLowStock: false,
            alternatives: [],
          ),
        );
      }
    }

    // Antibiotic queries
    if (message.contains('antibiotik') || message.contains('antibiotic')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Antibiotik yang tersedia di klinik:'
            : 'Available antibiotics in the clinic:',
        medicationData: MedicationData(
          medicationName: 'Amoxicillin 500mg',
          quantity: 23,
          unit: 'boxes',
          price: 12.00,
          isLowStock: false,
          alternatives: ['Amoxicillin 250mg', 'Azithromycin 500mg', 'Ciprofloxacin 500mg'],
        ),
      );
    }

    // Low stock queries
    if (message.contains('stock rendah') || message.contains('low stock') || 
        message.contains('tinggal sedikit')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Ubat berikut mempunyai stok rendah dan perlu ditambah:'
            : 'The following medications have low stock and need to be restocked:',
        medicationData: MedicationData(
          medicationName: 'Chlorpheniramine 4mg',
          quantity: 5,
          unit: 'boxes',
          price: 6.50,
          isLowStock: true,
          alternatives: ['Cetirizine 10mg', 'Loratadine 10mg'],
        ),
      );
    }

    // Alternative medicine queries
    if (message.contains('alternatif') || message.contains('alternative') || 
        message.contains('ganti') || message.contains('replace')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Berikut adalah ubat alternatif yang tersedia:'
            : 'Here are available alternative medications:',
        medicationData: MedicationData(
          medicationName: 'Paracetamol 500mg',
          quantity: 30,
          unit: 'boxes',
          price: 7.00,
          isLowStock: false,
          alternatives: ['Panadol 500mg', 'Uphamol 500mg', 'Tylenol 500mg'],
        ),
      );
    }

    // Fever medicine queries
    if (message.contains('demam') || message.contains('fever')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Ubat demam yang tersedia:'
            : 'Available fever medications:',
        medicationData: MedicationData(
          medicationName: 'Paracetamol 500mg',
          quantity: 30,
          unit: 'boxes',
          price: 7.00,
          isLowStock: false,
          alternatives: ['Panadol 500mg', 'Ibuprofen 400mg'],
        ),
      );
    }

    // Quick search queries
    if (message.contains('cari') || message.contains('search') || 
        message.contains('carian pantas') || message.contains('quick search')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Sila nyatakan nama ubat yang ingin dicari. Contoh: "Panadol", "Antibiotik", atau "Ubat demam".'
            : 'Please specify the medication name you want to search. Example: "Panadol", "Antibiotic", or "Fever medicine".',
      );
    }

    // Generic medication search
    if (message.contains('chlorpheniramine') || message.contains('allergy')) {
      return StaffChatResponse(
        reply: isBM
            ? 'Chlorpheniramine 4mg - Stok rendah! Hanya tinggal beberapa kotak.'
            : 'Chlorpheniramine 4mg - Low stock! Only a few boxes remaining.',
        medicationData: MedicationData(
          medicationName: 'Chlorpheniramine 4mg',
          quantity: 5,
          unit: 'boxes',
          price: 6.50,
          isLowStock: true,
          alternatives: ['Cetirizine 10mg', 'Loratadine 10mg'],
        ),
      );
    }

    // Default response
    return StaffChatResponse(
      reply: isBM
          ? 'Saya boleh membantu anda dengan:\n• Carian stock ubat\n• Harga ubat\n• Ubat alternatif\n• Amaran stock rendah\n\nCuba tanya: "Panadol stock", "Harga ubat demam", atau "Antibiotik tersedia".'
          : 'I can help you with:\n• Medication stock search\n• Drug pricing\n• Alternative medications\n• Low stock alerts\n\nTry asking: "Panadol stock", "Fever medicine price", or "Available antibiotics".',
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'BM' ? 'EN' : 'BM';
      _messages.add(ChatMessage(
        text: _currentLanguage == 'BM'
            ? 'Bahasa ditukar kepada Bahasa Melayu.'
            : 'Language switched to English.',
        isUser: false,
        timestamp: DateTime.now(),
        isSystem: true,
      ));
    });
    _scrollToBottom();
  }

  Widget _buildStatusDot() {
    return AnimatedBuilder(
      animation: _dotAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_dotAnimationController.value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.medical_services,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                _currentLanguage == 'BM' ? 'Carian Pantas:' : 'Quick Lookup:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: (_currentLanguage == 'BM' ? _quickChipsBM : _quickChipsEN)
                  .map((chip) => ActionChip(
                        label: Text(chip),
                        onPressed: () => _sendMessage(chip),
                        backgroundColor: AppTheme.lightBlue,
                        labelStyle: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
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
            Text(
              widget.clinic.name,
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 12,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Staff Assistant',
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 6),
                _buildStatusDot(),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: OutlinedButton(
              onPressed: _toggleLanguage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _currentLanguage == 'BM' ? 'BM' : 'EN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Container(
              color: AppTheme.background,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0) + (!_hasUserSentMessage ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show all messages first
                  if (index < _messages.length) {
                    return _buildMessageBubble(_messages[index]);
                  }
                  
                  // After all messages, show typing indicator if typing
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  
                  // After typing indicator (or messages if not typing), show suggestions if user hasn't sent a message
                  if (!_hasUserSentMessage && index == _messages.length + (_isTyping ? 1 : 0)) {
                    return _buildQuickSuggestions();
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Medication icon
                    IconButton(
                      icon: const Icon(
                        Icons.medication,
                        color: AppTheme.primaryBlue,
                        size: 22,
                      ),
                      onPressed: () {
                        // Quick medication search shortcut
                        setState(() {
                          _messageController.text = _currentLanguage == 'BM' 
                              ? 'Cari ubat: ' 
                              : 'Search medicine: ';
                        });
                      },
                    ),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _currentLanguage == 'BM'
                              ? 'Cari ubat, stock, harga...'
                              : 'Search medicine, stock, price...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    // Barcode scanner icon
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        // TODO: Handle barcode scanning for medication lookup
                      },
                    ),
                    const SizedBox(width: 4),
                    // Send button
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () => _sendMessage(_messageController.text),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // System messages (like language switch) are displayed as centered text
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Center(
          child: Text(
            message.text,
            style: TextStyle(
              color: AppTheme.greyText,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    
    // Regular message bubbles
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : AppTheme.darkText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.greyText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Medication data card displayed separately below the message
                if (!message.isUser && message.medicationData != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: _buildMedicationCard(message.medicationData!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isLowStock ? Colors.red.shade300 : AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with medication icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.medicationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    if (data.genericName.isNotEmpty && data.genericName != data.medicationName)
                      Text(
                        '${data.genericName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              if (data.isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        _currentLanguage == 'BM' ? 'Stock Rendah' : 'Low Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Drug information grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // First row: Category and Location
                Row(
                  children: [
                    if (data.category.isNotEmpty) ...[
                      Expanded(
                        child: _buildInfoRow(
                          Icons.category,
                          _currentLanguage == 'BM' ? 'Kategori' : 'Category',
                          data.category,
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                    if (data.location.isNotEmpty) ...[
                      if (data.category.isNotEmpty) const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.place,
                          _currentLanguage == 'BM' ? 'Lokasi' : 'Location',
                          data.location,
                          AppTheme.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
                
                if ((data.category.isNotEmpty || data.location.isNotEmpty)) 
                  const SizedBox(height: 12),
                
                // Second row: Stock and Price
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.inventory_2,
                        _currentLanguage == 'BM' ? 'Stock' : 'Stock',
                        '${data.quantity} ${data.unit}',
                        data.isLowStock ? Colors.red.shade700 : AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.attach_money,
                        _currentLanguage == 'BM' ? 'Harga' : 'Price',
                        'RM ${data.price.toStringAsFixed(2)}',
                        AppTheme.softOrange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Third row: Min Stock and Expiry
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.warning_outlined,
                        _currentLanguage == 'BM' ? 'Min Stock' : 'Min Stock',
                        '${data.minStock} ${data.unit}',
                        Colors.orange.shade600,
                      ),
                    ),
                    if (data.expiryDate.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          Icons.schedule,
                          _currentLanguage == 'BM' ? 'Luput' : 'Expiry',
                          data.expiryDate,
                          AppTheme.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: ((value + index * 0.3) % 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.greyText,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystem;
  final MedicationData? medicationData;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystem = false,
    this.medicationData,
  });
}

class MedicationData {
  final String medicationName;
  final String genericName;
  final String category;
  final int quantity;
  final String unit;
  final double price;
  final bool isLowStock;
  final String expiryDate;
  final String location;
  final String clinic;
  final int minStock;

  MedicationData({
    required this.medicationName,
    required this.genericName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.isLowStock,
    required this.expiryDate,
    required this.location,
    required this.clinic,
    required this.minStock,
  });

  factory MedicationData.fromDrugEntry(Map<String, dynamic> drugEntry) {
    final quantity = int.tryParse(drugEntry['stock_quantity']?.toString() ?? '0') ?? 0;
    final minStock = int.tryParse(drugEntry['min_stock']?.toString() ?? '0') ?? 0;
    final price = double.tryParse(drugEntry['price']?.toString() ?? '0.0') ?? 0.0;
    
    return MedicationData(
      medicationName: drugEntry['common_name'] ?? drugEntry['generic_name'] ?? 'Unknown',
      genericName: drugEntry['generic_name'] ?? '',
      category: drugEntry['category'] ?? '',
      quantity: quantity,
      unit: drugEntry['unit'] ?? 'units',
      price: price,
      isLowStock: quantity <= minStock,
      expiryDate: drugEntry['expiry_date'] ?? '',
      location: drugEntry['location'] ?? '',
      clinic: drugEntry['clinic'] ?? '',
      minStock: minStock,
    );
  }
}

// Removed - no longer needed as we use Map<String, dynamic> directly