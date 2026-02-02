import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'auth_lifecycle_provider.dart';
import 'database_providers.dart';
import 'user_context_provider.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String chatEndpoint = '/api/chat/message';
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isUser => role == 'user';
  bool get isAI => role == 'assistant';
}

/// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String sessionId;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
    required this.sessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

/// Chat state notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(ChatState(
          messages: [],
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        )) {
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    try {
      final conversationDao = _ref.read(conversationDaoProvider);
      final messages = await conversationDao.getConversation(
        sessionId: state.sessionId,
      );

      state = state.copyWith(
        messages: messages.map((m) => ChatMessage.fromMap(m)).toList(),
      );
    } catch (e) {
      // Start fresh if error loading
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userId = _ref.read(currentUserIdProvider);
    final conversationDao = _ref.read(conversationDaoProvider);

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Save to local DB
    await conversationDao.addMessage(
      userId: userId,
      sessionId: state.sessionId,
      role: 'user',
      content: content,
    );

    try {
      // Call AI API
      final response = await _callChatAPI(content);

      // Add AI response
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'assistant',
        content: response,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      // Save AI response to local DB
      await conversationDao.addMessage(
        userId: userId,
        sessionId: state.sessionId,
        role: 'assistant',
        content: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get AI response. Please try again.',
      );

      // Add error message as AI response for UX
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'assistant',
        content:
            'I\'m having trouble connecting right now. Please try again in a moment.',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
      );
    }
  }

  Future<String> _callChatAPI(String message) async {
    // Get user context for personalized responses
    final userContext = _ref.read(userContextSummaryProvider);

    try {
      // Try to call backend API
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'session_id': state.sessionId,
              'user_context': userContext,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String;
      }
      throw Exception('API error: ${response.statusCode}');
    } catch (e) {
      // Fallback to local responses if API unavailable
      return _getLocalResponse(message, userContext);
    }
  }

  String _getLocalResponse(String message, String userContext) {
    final lowerMessage = message.toLowerCase();

    // ==========================================
    // CRISIS DETECTION - ALWAYS CHECK FIRST
    // ==========================================
    final crisisResponse = _checkForCrisisSignals(lowerMessage);
    if (crisisResponse != null) {
      return crisisResponse;
    }

    // Build context-aware intro if we have user data
    String contextIntro = '';
    if (userContext.isNotEmpty && !userContext.contains('has not logged any')) {
      contextIntro = 'Based on your recent tracking, ';
    }

    if (lowerMessage.contains('anxious') || lowerMessage.contains('anxiety')) {
      return "I hear that you're feeling anxious. That's a common experience, and it's okay to feel this way. "
          "Here are some things that might help:\n\n"
          "1. Take slow, deep breaths - try breathing in for 4 counts, holding for 4, and exhaling for 6.\n"
          "2. Ground yourself by noticing 5 things you can see, 4 you can touch, 3 you can hear.\n"
          "3. Remember that this feeling will pass.\n\n"
          "Would you like me to guide you through a breathing exercise?";
    }

    if (lowerMessage.contains('sad') || lowerMessage.contains('depressed')) {
      return "I'm sorry you're feeling this way. Sadness is a natural emotion, and it's important to acknowledge it. "
          "Some things that might help:\n\n"
          "1. Reach out to someone you trust - connection can be healing.\n"
          "2. Try gentle movement like a short walk.\n"
          "3. Be kind to yourself - you deserve compassion.\n\n"
          "If these feelings persist or feel overwhelming, please consider speaking with a counselor or therapist who can provide personalized support.\n\n"
          "Would you like to talk more about what's on your mind?";
    }

    if (lowerMessage.contains('sleep') || lowerMessage.contains('tired')) {
      return "Sleep difficulties can really affect how we feel. Here are some helpful tips:\n\n"
          "1. Try to maintain a consistent sleep schedule.\n"
          "2. Limit screen time an hour before bed.\n"
          "3. Create a calm, dark sleeping environment.\n"
          "4. Try the 4-7-8 breathing technique before bed.\n\n"
          "Would you like to log your sleep or try a relaxation exercise?";
    }

    if (lowerMessage.contains('stress')) {
      return "${contextIntro}Stress is something we all experience. Here are some strategies:\n\n"
          "1. Identify what you can control vs. what you can't.\n"
          "2. Break big tasks into smaller, manageable steps.\n"
          "3. Take regular breaks and practice self-care.\n"
          "4. Movement and deep breathing can help release tension.\n\n"
          "What's causing you the most stress right now?";
    }

    if (lowerMessage.contains('happy') ||
        lowerMessage.contains('good') ||
        lowerMessage.contains('great')) {
      return "That's wonderful to hear! 😊 It's great that you're feeling positive. "
          "Consider taking a moment to really appreciate this feeling.\n\n"
          "Would you like to journal about what's going well? Capturing these moments can be helpful on harder days.";
    }

    if (lowerMessage.contains('how am i doing') ||
        lowerMessage.contains('my progress') ||
        lowerMessage.contains('my trends')) {
      if (userContext.isNotEmpty) {
        return "Here's a summary of your recent wellness data:\n\n$userContext\n\n"
            "Would you like tips on improving any specific area?";
      } else {
        return "I don't have much data to share yet. Try logging your mood and sleep regularly, "
            "and I'll be able to give you personalized insights!";
      }
    }

    // Default supportive response
    return "Thank you for sharing that with me. I'm here to listen and support you. "
        "Would you like to:\n\n"
        "• Log your mood to track how you're feeling\n"
        "• Try a breathing exercise for relaxation\n"
        "• Write in your journal\n"
        "• Talk more about what's on your mind\n\n"
        "What feels right for you?";
  }

  /// Check for crisis signals and return appropriate safety response
  /// Returns null if no crisis detected
  String? _checkForCrisisSignals(String message) {
    // High-risk keywords indicating immediate danger
    final immediateRiskPatterns = [
      'kill myself',
      'end my life',
      'suicide',
      'want to die',
      'don\'t want to live',
      'don\'t want to be alive',
      'better off dead',
      'no reason to live',
      'hurt myself',
      'self harm',
      'self-harm',
      'cutting myself',
    ];

    // Medium-risk keywords indicating distress
    final distressPatterns = [
      'want to disappear',
      'i feel empty',
      'nothing matters',
      'hopeless',
      'no point',
      'can\'t go on',
      'give up',
      'hate myself',
      'worthless',
      'burden to everyone',
      'everyone would be better',
      'can\'t take it anymore',
    ];

    // Check for immediate risk
    for (final pattern in immediateRiskPatterns) {
      if (message.contains(pattern)) {
        return _getImmediateCrisisResponse();
      }
    }

    // Check for distress signals
    for (final pattern in distressPatterns) {
      if (message.contains(pattern)) {
        return _getDistressResponse(pattern);
      }
    }

    return null;
  }

  /// Response for immediate crisis situations
  String _getImmediateCrisisResponse() {
    return """I'm really concerned about what you're sharing, and I want you to know that your life matters. What you're feeling right now is temporary, even if it doesn't feel that way.

**Please reach out to someone who can help right now:**

🆘 **Crisis Helplines:**
• 988 Suicide & Crisis Lifeline (US): Call or text **988**
• International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/
• iCall (India): **9152987821**
• Vandrevala Foundation (India): **1860-2662-345**

You don't have to face this alone. A trained counselor can provide the support you need right now.

**While you wait or if you're not ready to call:**
• Stay with someone you trust if possible
• Remove anything you might use to hurt yourself
• Focus on getting through the next few minutes

Would you like me to help you with a grounding exercise while you decide what to do next?""";
  }

  /// Response for distress but not immediate crisis
  String _getDistressResponse(String trigger) {
    String specificMessage = '';

    if (trigger.contains('empty') || trigger.contains('hopeless')) {
      specificMessage =
          "Feeling empty or hopeless can be incredibly difficult. These feelings are valid, but they don't have to be permanent.";
    } else if (trigger.contains('disappear') || trigger.contains('give up')) {
      specificMessage =
          "It sounds like you're going through a really hard time. Wanting to escape pain is understandable.";
    } else if (trigger.contains('hate myself') ||
        trigger.contains('worthless')) {
      specificMessage =
          "I'm sorry you're being so hard on yourself. The way you're feeling about yourself right now isn't the whole truth.";
    } else if (trigger.contains('nothing matters') ||
        trigger.contains('no point')) {
      specificMessage =
          "When everything feels meaningless, it can be overwhelming. These feelings often point to exhaustion or depression.";
    } else {
      specificMessage =
          "What you're feeling sounds really difficult. Please know that you're not alone.";
    }

    return """$specificMessage

**I'm not able to provide the support you might need, but these resources can:**

• Talk to a trusted friend, family member, or counselor
• 988 Suicide & Crisis Lifeline: Call or text **988** (US)
• AASRA (India): **9820466726**
• Your doctor or a mental health professional

**Right now, let's try something together:**

Take a slow breath with me. Breathe in for 4 counts... hold for 4... and breathe out for 6.

This app is here to help with daily wellness, but a real person can provide the deeper support you deserve. You matter, and asking for help is a sign of strength.

Would you like to talk about what's been happening, or try a grounding exercise?""";
  }

  void startNewSession() {
    state = ChatState(
      messages: [],
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

/// Chat suggestions
final chatSuggestionsProvider = Provider<List<String>>((ref) {
  return [
    "How am I doing?",
    "I'm feeling anxious today",
    "Help me relax",
    "I can't sleep well",
    "I'm stressed about work",
    "I feel happy today!",
  ];
});
