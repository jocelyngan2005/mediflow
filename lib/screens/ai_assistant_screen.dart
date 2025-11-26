import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  final Clinic clinic;

  const AIAssistantScreen({super.key, required this.clinic});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _currentLanguage = 'BM'; // BM or EN
  late TabController _tabController;
  int _currentTab = 0; // 0 = FAQ, 1 = SOP/Documents

  // FAQ quick chips
  final List<String> _faqChipsBM = [
    'Waktu operasi',
    'Rawatan tersedia',
    'Jadual vaksin',
    'Senarai harga',
    'Ubat tersedia',
  ];

  final List<String> _faqChipsEN = [
    'Operating hours',
    'Available treatments',
    'Vaccine schedule',
    'Price list',
    'Available medications',
  ];

  // Document quick chips
  final List<String> _docChipsBM = [
    'Jadual imunisasi',
    'Panduan vaksin',
    'Protokol denggi',
    'SOP influenza',
    'COVID-19',
  ];

  final List<String> _docChipsEN = [
    'Immunisation schedule',
    'Vaccine guidelines',
    'Dengue protocol',
    'Influenza SOP',
    'COVID-19',
  ];

  // Available documents
  final List<DocumentSource> _availableDocuments = [
    DocumentSource(
      title: 'Immunisation Schedule (BM)',
      type: 'KKM Circular',
      icon: Icons.vaccines,
      color: AppTheme.primaryBlue,
    ),
    DocumentSource(
      title: 'Child Vaccination Guidelines',
      type: 'Clinic SOP',
      icon: Icons.child_care,
      color: AppTheme.softGreen,
    ),
    DocumentSource(
      title: 'Dengue Prevention Protocol',
      type: 'KKM Circular',
      icon: Icons.bug_report,
      color: AppTheme.softRed,
    ),
    DocumentSource(
      title: 'Influenza Treatment Guidelines',
      type: 'Clinic SOP',
      icon: Icons.sick,
      color: AppTheme.softOrange,
    ),
    DocumentSource(
      title: 'COVID-19 Testing Protocol',
      type: 'KKM Circular',
      icon: Icons.coronavirus,
      color: AppTheme.softPeach,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    
    // Welcome message
    _messages.add(ChatMessage(
      text: _currentLanguage == 'BM'
          ? 'Selamat datang ke ${widget.clinic.name}! 👋\n\nSaya AI Assistant anda. Saya boleh membantu dengan:\n• Soalan tentang klinik (waktu, rawatan, harga)\n• Carian dokumen SOP dan panduan KKM\n\nBagaimana saya boleh membantu anda?'
          : 'Welcome to ${widget.clinic.name}! 👋\n\nI\'m your AI Assistant. I can help with:\n• Clinic inquiries (hours, treatments, pricing)\n• SOP documents and KKM guidelines search\n\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response based on current tab/mode
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(ChatMessage(
          text: _generateResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
          sourceDocument: _detectDocumentSource(text),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String? _detectDocumentSource(String query) {
    // Detect if response should include document source
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('vaksin') || lowerQuery.contains('vaccine') || 
        lowerQuery.contains('imunisasi') || lowerQuery.contains('immunisation')) {
      return 'Immunisation Schedule (BM) - Page 3';
    } else if (lowerQuery.contains('dengue') || lowerQuery.contains('demam denggi')) {
      return 'Dengue Prevention Protocol - Page 5';
    } else if (lowerQuery.contains('covid') || lowerQuery.contains('corona')) {
      return 'COVID-19 Testing Protocol - Page 2';
    } else if (lowerQuery.contains('influenza') || lowerQuery.contains('flu')) {
      return 'Influenza Treatment Guidelines - Page 8';
    }
    return null;
  }

  String _generateResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // FAQ Responses
    if (lowerQuery.contains('waktu') || lowerQuery.contains('hours') || lowerQuery.contains('operasi')) {
      return _currentLanguage == 'BM'
          ? '${widget.clinic.name} beroperasi pada waktu berikut:\n\n${widget.clinic.hours}\n\nAdakah anda ingin membuat temujanji?'
          : '${widget.clinic.name} operates at the following hours:\n\n${widget.clinic.hours}\n\nWould you like to book an appointment?';
    } 
    else if (lowerQuery.contains('rawatan') || lowerQuery.contains('treatment')) {
      return _currentLanguage == 'BM'
          ? 'Kami menyediakan rawatan berikut:\n\n• Pemeriksaan kesihatan am\n• Rawatan demam & batuk\n• Vaksinasi kanak-kanak & dewasa\n• Ujian COVID-19\n• Rawatan kecemasan ringan\n\nRawatan mana yang anda perlukan?'
          : 'We provide the following treatments:\n\n• General health check-ups\n• Fever & cough treatment\n• Child & adult vaccinations\n• COVID-19 testing\n• Minor emergency care\n\nWhich treatment do you need?';
    }
    else if (lowerQuery.contains('harga') || lowerQuery.contains('price')) {
      return _currentLanguage == 'BM'
          ? 'Berikut adalah anggaran harga untuk perkhidmatan kami:\n\n• Konsultasi am: RM30-50\n• Rawatan demam: RM50-80\n• Vaksinasi: RM80-200\n• Ujian COVID-19: RM150\n• Pemeriksaan kesihatan: RM100-300\n\nHarga sebenar bergantung kepada rawatan yang diperlukan.'
          : 'Here are the estimated prices for our services:\n\n• General consultation: RM30-50\n• Fever treatment: RM50-80\n• Vaccination: RM80-200\n• COVID-19 test: RM150\n• Health check-up: RM100-300\n\nActual prices depend on the required treatment.';
    }
    // Document/SOP Responses
    else if (lowerQuery.contains('vaksin') || lowerQuery.contains('vaccine') || 
             lowerQuery.contains('imunisasi') || lowerQuery.contains('immunisation')) {
      return _currentLanguage == 'BM'
          ? '📄 **Berdasarkan Jadual Imunisasi KKM:**\n\nKanak-kanak patut menerima vaksin berikut:\n\n• BCG - Semasa lahir\n• Hepatitis B - 0, 1, dan 6 bulan\n• DTaP - 2, 3, dan 5 bulan\n• MMR - 12 bulan\n• Dos penggalang mengikut jadual\n\nDewasa:\n• Vaksin Influenza - Tahunan\n• COVID-19 - Mengikut keperluan\n• Tetanus - Setiap 10 tahun\n\nSila buat temujanji untuk vaksinasi.'
          : '📄 **Based on KKM Immunisation Schedule:**\n\nChildren should receive:\n\n• BCG - At birth\n• Hepatitis B - 0, 1, and 6 months\n• DTaP - 2, 3, and 5 months\n• MMR - 12 months\n• Booster doses as scheduled\n\nAdults:\n• Influenza vaccine - Annually\n• COVID-19 - As needed\n• Tetanus - Every 10 years\n\nPlease book an appointment for vaccination.';
    }
    else if (lowerQuery.contains('dengue') || lowerQuery.contains('demam denggi')) {
      return _currentLanguage == 'BM'
          ? '📄 **Berdasarkan Protokol Pencegahan Denggi KKM:**\n\nLangkah pencegahan:\n\n• Hapuskan air bertakung\n• Guna racun serangga\n• Pakai pelindung anti-nyamuk\n• Pastikan sistem saliran baik\n• Program kesedaran komuniti\n\nSimptom:\n• Demam tinggi\n• Sakit kepala teruk\n• Sakit di belakang mata\n• Sakit sendi dan otot\n• Ruam kulit\n\nJika simptom bertambah teruk, dapatkan rawatan segera!'
          : '📄 **Based on KKM Dengue Prevention Protocol:**\n\nPrevention measures:\n\n• Eliminate stagnant water\n• Use insect repellent\n• Wear protective clothing\n• Ensure proper drainage\n• Community awareness programs\n\nSymptoms:\n• High fever\n• Severe headache\n• Pain behind the eyes\n• Joint and muscle pain\n• Skin rash\n\nIf symptoms worsen, seek immediate medical attention!';
    }
    else if (lowerQuery.contains('covid') || lowerQuery.contains('corona')) {
      return _currentLanguage == 'BM'
          ? '📄 **Berdasarkan Protokol Ujian COVID-19 KKM:**\n\nUjian perlu dijalankan untuk:\n\n• Individu bergejala\n• Kontak rapat kes disahkan\n• Keperluan pra-perjalanan\n• Saringan tempat kerja\n\nJenis ujian:\n• RT-PCR (lebih tepat)\n• RTK-Ag (lebih cepat)\n\nPanduan pengasingan:\n• Minimum 5 hari untuk kes positif\n• Pantau simptom setiap hari\n• Dapatkan rawatan jika sesak nafas atau demam berterusan'
          : '📄 **Based on KKM COVID-19 Testing Protocol:**\n\nTesting should be conducted for:\n\n• Symptomatic individuals\n• Close contacts of confirmed cases\n• Pre-travel requirements\n• Workplace screening\n\nTest types:\n• RT-PCR (more accurate)\n• RTK-Ag (faster results)\n\nIsolation guidelines:\n• Minimum 5 days for positive cases\n• Monitor symptoms daily\n• Seek medical attention if experiencing breathing difficulties or persistent fever';
    }
    else if (lowerQuery.contains('influenza') || lowerQuery.contains('flu') || lowerQuery.contains('selesema')) {
      return _currentLanguage == 'BM'
          ? '📄 **Berdasarkan SOP Rawatan Influenza:**\n\nSimptom biasa:\n• Demam tinggi mendadak\n• Batuk kering\n• Sakit tekak\n• Sakit badan\n• Keletihan\n\nRawatan:\n• Rehat mencukupi\n• Minum banyak air\n• Ubat penurun demam\n• Antiviral (jika perlu)\n\nPencegahan:\n• Vaksin influenza tahunan\n• Kebersihan tangan\n• Elak kontak dengan pesakit'
          : '📄 **Based on Influenza Treatment SOP:**\n\nCommon symptoms:\n• Sudden high fever\n• Dry cough\n• Sore throat\n• Body aches\n• Fatigue\n\nTreatment:\n• Adequate rest\n• Plenty of fluids\n• Fever reducers\n• Antivirals (if necessary)\n\nPrevention:\n• Annual flu vaccine\n• Hand hygiene\n• Avoid contact with patients';
    }
    // Generic response
    else {
      return _currentLanguage == 'BM'
          ? 'Terima kasih atas soalan anda tentang "${query}".\n\nSaya boleh membantu dengan:\n\n📋 **Maklumat Klinik:**\n• Waktu operasi\n• Rawatan & perkhidmatan\n• Harga & bayaran\n• Temujanji\n\n📄 **Dokumen & Panduan:**\n• Jadual imunisasi\n• SOP klinik\n• Pekeliling KKM\n• Protokol rawatan\n\nSila pilih topik di atas atau tanya soalan yang lebih spesifik.'
          : 'Thank you for your question about "${query}".\n\nI can help with:\n\n📋 **Clinic Information:**\n• Operating hours\n• Treatments & services\n• Pricing & fees\n• Appointments\n\n📄 **Documents & Guidelines:**\n• Immunisation schedules\n• Clinic SOPs\n• KKM circulars\n• Treatment protocols\n\nPlease choose a topic above or ask a more specific question.';
    }
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

  List<String> _getCurrentChips() {
    if (_currentTab == 0) {
      return _currentLanguage == 'BM' ? _faqChipsBM : _faqChipsEN;
    } else {
      return _currentLanguage == 'BM' ? _docChipsBM : _docChipsEN;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Assistant 🤖', style: TextStyle(fontSize: 18)),
            Text(
              widget.clinic.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
          // Mode Tabs
          Container(
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
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.greyText,
              indicatorColor: AppTheme.primaryBlue,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.question_answer, size: 18),
                      const SizedBox(width: 8),
                      Text(_currentLanguage == 'BM' ? 'FAQ Klinik' : 'Clinic FAQ'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, size: 18),
                      const SizedBox(width: 8),
                      Text(_currentLanguage == 'BM' ? 'Dokumen SOP' : 'SOP Docs'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _currentTab == 0 ? Icons.lightbulb_outline : Icons.folder_open,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentTab == 0
                          ? (_currentLanguage == 'BM' ? 'Topik Popular:' : 'Popular Topics:')
                          : (_currentLanguage == 'BM' ? 'Dokumen Popular:' : 'Popular Documents:'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getCurrentChips()
                      .map((chip) => ActionChip(
                            label: Text(chip),
                            onPressed: () => _sendMessage(chip),
                            backgroundColor: _currentTab == 0 
                                ? AppTheme.lightBlue 
                                : AppTheme.lightOrange,
                            labelStyle: TextStyle(
                              color: _currentTab == 0 
                                  ? AppTheme.primaryBlue 
                                  : AppTheme.softOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Show document library when in SOP tab and no messages
          if (_currentTab == 1 && _messages.length <= 1)
            Expanded(
              child: _buildDocumentLibrary(),
            )
          else
            // Chat Messages
            Expanded(
              child: Container(
                color: AppTheme.background,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
            ),

          // Message Input
          Container(
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
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: _currentTab == 0
                            ? (_currentLanguage == 'BM'
                                ? 'Tanya tentang klinik...'
                                : 'Ask about clinic...')
                            : (_currentLanguage == 'BM'
                                ? 'Cari dalam dokumen...'
                                : 'Search in documents...'),
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _currentTab == 0 ? AppTheme.primaryBlue : AppTheme.softOrange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
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

  Widget _buildDocumentLibrary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentLanguage == 'BM' ? 'Dokumen Tersedia' : 'Available Documents',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _currentLanguage == 'BM' 
                ? 'Pilih dokumen atau tanya soalan' 
                : 'Select a document or ask a question',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ...(_availableDocuments.map((doc) => _buildDocumentCard(doc))),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentSource doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: doc.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(doc.icon, color: doc.color, size: 28),
        ),
        title: Text(
          doc.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          doc.type,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _sendMessage(doc.title);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser && !message.isSystem)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isSystem
                    ? AppTheme.lightGreen
                    : message.isUser
                        ? AppTheme.primaryBlue
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: message.isSystem
                    ? []
                    : [
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
                  if (message.sourceDocument != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 12,
                            color: AppTheme.softOrange,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              message.sourceDocument!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.softOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          ),
        ],
      ),
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
              Icons.smart_toy_rounded,
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
  final String? sourceDocument;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystem = false,
    this.sourceDocument,
  });
}

class DocumentSource {
  final String title;
  final String type;
  final IconData icon;
  final Color color;

  DocumentSource({
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
  });
}

