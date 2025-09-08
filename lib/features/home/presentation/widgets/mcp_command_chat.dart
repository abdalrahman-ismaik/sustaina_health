import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'voice_waveform.dart';

/// Persistent chat storage for MCP Command Chat
class MCPChatStorage {
  static final List<ChatMessage> _messages = <ChatMessage>[];
  static List<ChatMessage> get messages => _messages;
  
  static void addMessage(ChatMessage message) {
    _messages.add(message);
  }
  
  static void clearMessages() {
    _messages.clear();
  }
}

/// MCP Command Chat Widget with Speech-to-Text functionality
class MCPCommandChat extends ConsumerStatefulWidget {
  const MCPCommandChat({Key? key}) : super(key: key);

  @override
  ConsumerState<MCPCommandChat> createState() => _MCPCommandChatState();
}

class _MCPCommandChatState extends ConsumerState<MCPCommandChat>
    with TickerProviderStateMixin {
  
  // Speech Recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  String _currentWords = '';
  double _confidence = 0.0;
  
  // UI Controllers
  late TextEditingController _textController;
  late FocusNode _textFocusNode;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  // Chat State
  bool _isSending = false;
  Timer? _speechTimer;
  Timer? _speechMonitorTimer;
  DateTime? _lastSpeechActivity;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _textController = TextEditingController();
    _textFocusNode = FocusNode();
    _speech = stt.SpeechToText();
    
    // Listen to text changes to update send button state
    _textController.addListener(() {
      setState(() {
        // This will trigger rebuild for send button state
      });
    });
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _initializeSpeech();
    
    // Add welcome message if chat is empty
    if (MCPChatStorage.messages.isEmpty) {
      MCPChatStorage.addMessage(ChatMessage(
        text: 'Hello! I\'m your AI assistant. You can speak to me or type your questions about health, fitness, nutrition, and sustainability.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _speechTimer?.cancel();
    _speechMonitorTimer?.cancel();
    _speech.stop();
    super.dispose();
  }
  
  Future<void> _initializeSpeech() async {
    try {
      // Request microphone permission
      final PermissionStatus status = await Permission.microphone.request();
      
      if (status.isGranted) {
        _isInitialized = await _speech.initialize(
          onError: (SpeechRecognitionError errorNotification) {
            print('Speech error: ${errorNotification.errorMsg}');
            // On error, restart speech recognition if we're supposed to be listening
            if (_isListening) {
              _restartSpeechRecognition();
            }
          },
          onStatus: (String status) {
            print('Speech status: $status');
            // Monitor for unresponsive states
            if (status == 'notListening' || status == 'done') {
              if (_isListening) {
                // Speech stopped but we want to keep listening - restart
                _restartSpeechRecognition();
              }
            }
          },
        );
        
        if (mounted) {
          setState(() {});
        }
      } else {
        _showError('Microphone permission denied. Please enable it in settings.');
      }
    } catch (e) {
      _showError('Failed to initialize speech recognition: $e');
    }
  }
  
  void _toggleListening() {
    if (!_isInitialized) {
      _showError('Speech recognition not initialized');
      return;
    }
    
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }
  
  void _startListening() async {
    if (!_isInitialized) return;
    
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          setState(() {
            _currentWords = result.recognizedWords;
            _confidence = result.confidence;
            _lastSpeechActivity = DateTime.now(); // Track speech activity
            
            if (result.finalResult && _currentWords.isNotEmpty) {
              // Final result: add to accumulated text and clear current words
              if (_recognizedText.isNotEmpty && !_recognizedText.endsWith(' ')) {
                _recognizedText += ' ';
              }
              _recognizedText += _currentWords;
              _textController.text = _recognizedText;
              _currentWords = ''; // Clear after adding to accumulated text
            } else if (_currentWords.isNotEmpty) {
              // Partial result: show accumulated text + current words (preview only)
              String displayText = _recognizedText;
              if (displayText.isNotEmpty && !displayText.endsWith(' ')) {
                displayText += ' ';
              }
              displayText += _currentWords;
              _textController.text = displayText;
            } else {
              // No current words, just show accumulated text
              _textController.text = _recognizedText;
            }
          });
        },
        onSoundLevelChange: (double level) {
          // Optional: Handle sound level changes for visual feedback
        },
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation, // Changed to dictation mode
        pauseFor: const Duration(seconds: 30), // Very long pause before stopping
        listenFor: const Duration(hours: 1), // Very long listening duration
      );
      
      setState(() {
        _isListening = true;
        _currentWords = '';
        // Initialize _recognizedText with existing text if any
        _recognizedText = _textController.text;
        _lastSpeechActivity = DateTime.now();
      });
      
      // Start animations
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
      
      // Start monitoring for unresponsive speech recognition
      _startSpeechMonitoring();
      
      // Auto-scroll to show recording indicator
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
    } catch (e) {
      _showError('Failed to start listening: $e');
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    
    // Stop speech recognition
    _speech.stop();
    
    // Stop monitoring
    _speechMonitorTimer?.cancel();
    
    // Update UI state
    setState(() {
      // If there are current words being spoken, add them to accumulated text
      if (_currentWords.isNotEmpty) {
        if (_recognizedText.isNotEmpty && !_recognizedText.endsWith(' ')) {
          _recognizedText += ' ';
        }
        _recognizedText += _currentWords;
        _currentWords = '';
      }
      // Set final text in controller
      _textController.text = _recognizedText;
    });
    
    // Stop animations
    _pulseController.stop();
    _waveController.stop();
    _speechTimer?.cancel();
    
    // Haptic feedback
    HapticFeedback.selectionClick();
  }
  
  void _startSpeechMonitoring() {
    _speechMonitorTimer?.cancel();
    _speechMonitorTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!_isListening || !mounted) {
        timer.cancel();
        return;
      }
      
      // Check if speech recognition is still active
      final DateTime now = DateTime.now();
      if (_lastSpeechActivity != null) {
        final Duration timeSinceLastActivity = now.difference(_lastSpeechActivity!);
        
        // If no speech activity for 15 seconds and no current words, restart
        if (timeSinceLastActivity.inSeconds > 15 && _currentWords.isEmpty) {
          print('Speech recognition appears unresponsive, restarting...');
          _restartSpeechRecognition();
        }
      }
    });
  }
  
  void _restartSpeechRecognition() async {
    if (!_isListening || !_isInitialized || !mounted) return;
    
    print('Restarting speech recognition...');
    
    try {
      // Stop current recognition
      await _speech.stop();
      
      // Wait a moment
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Restart if still supposed to be listening
      if (_isListening && mounted) {
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            setState(() {
              _currentWords = result.recognizedWords;
              _confidence = result.confidence;
              _lastSpeechActivity = DateTime.now(); // Track speech activity
              
              if (result.finalResult && _currentWords.isNotEmpty) {
                // Final result: add to accumulated text and clear current words
                if (_recognizedText.isNotEmpty && !_recognizedText.endsWith(' ')) {
                  _recognizedText += ' ';
                }
                _recognizedText += _currentWords;
                _textController.text = _recognizedText;
                _currentWords = ''; // Clear after adding to accumulated text
              } else if (_currentWords.isNotEmpty) {
                // Partial result: show accumulated text + current words (preview only)
                String displayText = _recognizedText;
                if (displayText.isNotEmpty && !displayText.endsWith(' ')) {
                  displayText += ' ';
                }
                displayText += _currentWords;
                _textController.text = displayText;
              } else {
                // No current words, just show accumulated text
                _textController.text = _recognizedText;
              }
            });
          },
          onSoundLevelChange: (double level) {
            // Optional: Handle sound level changes for visual feedback
          },
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 30),
          listenFor: const Duration(hours: 1),
        );
        
        // Update last activity time
        _lastSpeechActivity = DateTime.now();
      }
    } catch (e) {
      print('Error restarting speech recognition: $e');
      if (mounted) {
        _showError('Speech recognition restarted due to connectivity issues');
      }
    }
  }
  
  void _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;
    
    // Stop recording if currently listening
    if (_isListening) {
      _stopListening();
    }
    
    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    // Clear input
    _textController.clear();
    _recognizedText = '';
    _currentWords = '';
    
    setState(() {
      _isSending = true;
    });
    
    // Simulate MCP backend call (replace with actual implementation)
    await _simulateMCPResponse(text);
    
    setState(() {
      _isSending = false;
    });
  }
  
  Future<void> _simulateMCPResponse(String userMessage) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate a sample response based on the message
    final String response = _generateSampleResponse(userMessage);
    
    _addMessage(ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }
  
  String _generateSampleResponse(String message) {
    final String lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('workout') || lowerMessage.contains('exercise')) {
      return 'I can help you with personalized workout plans! Based on your fitness level, I recommend starting with 20 minutes of cardio and strength training. Would you like me to create a custom workout for you?';
    } else if (lowerMessage.contains('nutrition') || lowerMessage.contains('food') || lowerMessage.contains('diet')) {
      return 'Great question about nutrition! A balanced diet with whole foods, lean proteins, and plenty of vegetables is key. I can analyze your current eating habits and suggest improvements. What did you eat today?';
    } else if (lowerMessage.contains('sleep')) {
      return 'Sleep is crucial for health! I recommend 7-9 hours per night with a consistent schedule. Creating a bedtime routine and avoiding screens before sleep can improve your sleep quality significantly.';
    } else if (lowerMessage.contains('sustainability') || lowerMessage.contains('environment')) {
      return 'Sustainability and health go hand in hand! Small changes like walking instead of driving, eating locally sourced foods, and reducing waste can make a big impact. What sustainable practices interest you most?';
    } else {
      return 'Thank you for your question! I\'m here to help with health, fitness, nutrition, and sustainability advice. Could you be more specific about what you\'d like to know?';
    }
  }
  
  void _addMessage(ChatMessage message) {
    setState(() {
      MCPChatStorage.addMessage(message);
    });
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header
          _buildHeader(cs, isDark),
          
          // Messages
          Expanded(
            child: _buildMessagesList(cs, isDark),
          ),
          
          // Input Area
          _buildInputArea(cs, isDark),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cs.primaryContainer,
            cs.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: <Widget>[
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title and status
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[cs.primary, cs.primary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: cs.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'AI Health Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      _isListening 
                        ? 'Listening...' 
                        : _isInitialized 
                          ? 'Ready to help' 
                          : 'Initializing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Speech status indicator
              if (_isListening)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Recording',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesList(ColorScheme cs, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: MCPChatStorage.messages.length + (_isSending ? 1 : 0) + (_isListening ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        // Show recording indicator with waveform when listening
        if (_isListening && index == MCPChatStorage.messages.length) {
          return _buildRecordingIndicator(cs);
        }
        
        // Show typing indicator when sending
        if (_isSending && index == MCPChatStorage.messages.length + (_isListening ? 1 : 0)) {
          return _buildTypingIndicator(cs);
        }
        
        // Show regular message
        if (index < MCPChatStorage.messages.length) {
          final ChatMessage message = MCPChatStorage.messages[index];
          return _buildMessageBubble(message, cs, isDark);
        }
        
        // Fallback for invalid index
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, ColorScheme cs, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 16,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isUser
                  ? LinearGradient(
                      colors: <Color>[cs.primary, cs.primary.withValues(alpha: 0.8)],
                    )
                  : LinearGradient(
                      colors: <Color>[
                        cs.surfaceContainerHigh,
                        cs.surfaceContainer,
                      ],
                    ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser 
                    ? const Radius.circular(20) 
                    : const Radius.circular(4),
                  bottomRight: message.isUser 
                    ? const Radius.circular(4) 
                    : const Radius.circular(20),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? cs.onPrimary : cs.onSurface,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                        ? cs.onPrimary.withValues(alpha: 0.7)
                        : cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 16,
                color: cs.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTypingIndicator(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 16,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildDot(cs, 0),
                const SizedBox(width: 4),
                _buildDot(cs, 1),
                const SizedBox(width: 4),
                _buildDot(cs, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDot(ColorScheme cs, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (BuildContext context, double value, Widget? child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.3 + (value * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
  
  Widget _buildRecordingIndicator(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[cs.error.withValues(alpha: 0.1), cs.error.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: const Radius.circular(4),
                ),
                border: Border.all(
                  color: cs.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recording...',
                        style: TextStyle(
                          color: cs.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Animated waveform
                  VoiceWaveform(
                    key: const ValueKey('recording_waveform'),
                    isActive: _isListening,
                    color: cs.error,
                    height: 40,
                    barCount: 8,
                  ),
                  if (_currentWords.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      _currentWords,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              size: 16,
              color: cs.error,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputArea(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Live speech text display - show only current words being spoken
          if (_isListening && _currentWords.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Currently speaking: $_currentWords',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
          // Input row
          Row(
            children: <Widget>[
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFocusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: _isListening 
                        ? 'Listening...' 
                        : 'Ask me about health, fitness, nutrition...',
                      hintStyle: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Microphone button with compact pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Compact pulse ring that stays within 48x48
                      if (_isListening)
                        Container(
                          width: 48 + (_pulseAnimation.value * 6), // Small pulse expansion
                          height: 48 + (_pulseAnimation.value * 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.error.withValues(alpha: 0.15 - (_pulseAnimation.value * 0.1)),
                            border: Border.all(
                              color: cs.error.withValues(alpha: 0.4 - (_pulseAnimation.value * 0.2)),
                              width: 1,
                            ),
                          ),
                        ),
                      
                      // Main microphone button (fixed size)
                      GestureDetector(
                        onTap: _toggleListening,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isListening ? cs.error : cs.primary,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: (_isListening ? cs.error : cs.primary)
                                    .withValues(alpha: 0.3),
                                blurRadius: _isListening ? 8 + (_pulseAnimation.value * 2) : 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? cs.onError : cs.onPrimary,
                            size: 18, // Smaller icon to accommodate pulse within same space
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              GestureDetector(
                onTap: _textController.text.trim().isNotEmpty ? _sendMessage : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _textController.text.trim().isNotEmpty
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: _textController.text.trim().isNotEmpty
                      ? <BoxShadow>[
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                  ),
                  child: _isSending
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cs.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _textController.text.trim().isNotEmpty
                          ? cs.onPrimary
                          : cs.onSurfaceVariant,
                        size: 18,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
