import 'package:flutter/material.dart';
import 'package:mediflow/theme/app_theme.dart';
import 'package:mediflow/screens/clinic_selection_screen.dart';
import 'package:mediflow/services/api_service.dart';

class AIAssistantScreen extends StatefulWidget {
  final Clinic clinic;

  const AIAssistantScreen({super.key, required this.clinic});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _currentLanguage = 'BM'; // BM or EN
  bool _isConnected = false;
  bool _hasUserSentMessage = false;
  late AnimationController _dotAnimationController;

  // Quick suggestion chips
  final List<String> _quickChipsBM = [
    'Waktu operasi',
    'Rawatan tersedia',
    'Jadual vaksin',
    'Senarai harga',
    'Protokol denggi',
    'COVID-19',
  ];

  final List<String> _quickChipsEN = [
    'Operating hours',
    'Available treatments',
    'Vaccine schedule',
    'Price list',
    'Dengue protocol',
    'COVID-19',
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
    
    // Welcome message
    _messages.add(ChatMessage(
      text: _currentLanguage == 'BM'
          ? 'Selamat datang ke ${widget.clinic.name}! 👋\n\nSaya AI Assistant anda. Saya boleh membantu dengan:\n• Soalan tentang klinik (waktu, rawatan, harga)\n• Carian dokumen SOP dan panduan KKM\n• Jadual vaksin dan imunisasi\n• Protokol pencegahan penyakit\n\nBagaimana saya boleh membantu anda?'
          : 'Welcome to ${widget.clinic.name}! 👋\n\nI\'m your AI Assistant. I can help with:\n• Clinic inquiries (hours, treatments, pricing)\n• SOP documents and KKM guidelines\n• Vaccine and immunisation schedules\n• Disease prevention protocols\n\nHow can I help you today?',
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
      // Call the unified backend chat API
      ApiResponse<ChatResponse> response = await ApiService.sendChatMessage(
        clinicId: widget.clinic.clinicId,
        message: text,
        language: _currentLanguage,
      );

      setState(() {
        if (response.success && response.data != null) {
          _messages.add(ChatMessage(
            text: response.data!.reply,
            isUser: false,
            timestamp: DateTime.now(),
            sourceDocument: response.data!.sourceDocument,
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

  String _getErrorMessage(String error) {
    return _currentLanguage == 'BM'
        ? 'Maaf, sistem menghadapi masalah: $error\n\nSila cuba lagi atau hubungi klinik terus.'
        : 'Sorry, the system encountered an issue: $error\n\nPlease try again or contact the clinic directly.';
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
                Icons.lightbulb_outline,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                _currentLanguage == 'BM' ? 'Cadangan Soalan:' : 'Quick Suggestions:',
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
                Text(
                  'AI Assistant',
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
                    // Paperclip icon
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        // TODO: Handle file attachment
                      },
                    ),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _currentLanguage == 'BM'
                              ? 'Tanya apa-apa soalan...'
                              : 'Ask any question...',
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
                    // Mic icon
                    IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        // TODO: Handle voice input
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
                Icons.smart_toy_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
          Flexible(
            child: Container(
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