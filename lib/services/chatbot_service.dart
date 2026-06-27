import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ChatbotService {
  // API key should be provided via environment variable or Firebase Cloud Functions
  // For production: Use Firebase Cloud Functions to proxy Gemini API calls
  // For development: Set GEMINI_API_KEY in your environment or use --dart-define
  static String get _apiKey {
    // Try to get from environment variable (set via --dart-define)
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    // Fallback: In production, this should be handled by Cloud Functions
    // For now, disable AI if no key is provided
    return '';
  }

  late final GenerativeModel? _model;
  late final ChatSession? _chat;
  bool _isAIEnabled = true;
  final Logger _logger = Logger();

  ChatbotService() {
    _initializeAI();
  }

  void _initializeAI() {
    try {
      if (_apiKey.isEmpty) {
        if (kDebugMode) {
          print(
            'Gemini API key not provided. AI features disabled. Set GEMINI_API_KEY via --dart-define.',
          );
        }
        _isAIEnabled = false;
        _model = null;
        _chat = null;
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system('''
You are LUXE TIME Assistant, a premium AI chatbot for a luxury watch e-commerce app.

Your role:
- Help users find the perfect watch
- Answer questions about watch brands, features, and specifications
- Provide styling advice for watches
- Assist with order tracking and account issues
- Maintain a professional, luxurious tone

Guidelines:
- Be concise and helpful
- Recommend watches based on user preferences
- Explain watch terminology in simple terms
- Always maintain a premium, professional tone
- If unsure, suggest contacting customer support
- Never provide false information about products
'''),
      );

      _chat = _model!.startChat();
    } catch (e) {
      _logger.d('Error: ');
      _isAIEnabled = false;
      _model = null;
      _chat = null;
    }
  }

  // Send message and get response
  Future<String> sendMessage(String message) async {
    _logger.d('Received message: $message');

    // First try AI if available
    if (_isAIEnabled && _model != null && _chat != null) {
      try {
        _logger.d('Using AI response');
        final response = await _chat!.sendMessage(Content.text(message));
        if (response.text != null && response.text!.isNotEmpty) {
          _logger.d('AI response received');
          return response.text!;
        }
      } catch (e) {
        _logger.d('AI error: $e');
        _isAIEnabled = false;
        // Fall through to rule-based response
      }
    }

    _logger.d('Using rule-based response');
    // Rule-based fallback for immediate responses
    return _getRuleBasedResponse(message);
  }

  String _getRuleBasedResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Waterproof watches
    if (lowerMessage.contains('waterproof') ||
        lowerMessage.contains('water resistance')) {
      return '''🌊 **Waterproof Watches**

Here are our top waterproof recommendations:

**🏆 Best Waterproof Watches:**
• **Rolex Submariner** - 300m water resistance, legendary durability
• **Omega Seamaster** - 300m, professional diving watch
• **Seiko Prospex** - 200m, excellent value for diving
• **Citizen Promaster** - 200m, solar-powered reliability

**💧 Water Resistance Guide:**
• 30m: Splash resistant only
• 50m: Shower safe
• 100m: Swimming safe  
• 200m+: Snorkeling/diving safe

Would you like specific recommendations for your budget?''';
    }

    // Luxury brands
    if (lowerMessage.contains('luxury') ||
        lowerMessage.contains('best brand') ||
        lowerMessage.contains('top brand')) {
      return '''⭐ **Top Luxury Watch Brands**

**🏆 The Big 3:**
• **Rolex** - Swiss luxury, iconic designs, excellent investment
• **Patek Philippe** - Swiss prestige, complications mastery
• **Audemars Piguet** - Royal Oak, bold luxury

**🎯 Other Premium Brands:**
• **Omega** - Swiss precision, Speedmaster, Seamaster
• **Tag Heuer** - Swiss racing heritage, Carrera
• **Breitling** - Swiss aviation, Navitimer
• **Jaeger-LeCoultre** - Swiss complications, Reverso

Which brand interests you most? I can provide specific model recommendations!''';
    }

    // Business watches
    if (lowerMessage.contains('business') ||
        lowerMessage.contains('office') ||
        lowerMessage.contains('professional')) {
      return '''💼 **Perfect Business Watches**

**🏆 Top Business Recommendations:**

**Classic Professional:**
• **Rolex Datejust** - Timeless elegance, 36mm
• **Omega Constellation** - Sophisticated, dress watch
• **Tag Heuer Carrera** - Sporty professional

**Modern Professional:**
• **Longines Master Collection** - Swiss elegance
• **Tissot Gentleman** - Excellent value
• **Seiko Presage** - Japanese precision

**🎯 Business Watch Tips:**
• 36-40mm case size for most wrists
• Leather strap for formal occasions
• Silver or blue dial for versatility
• Date complication is essential

What's your budget range? I can suggest specific models!''';
    }

    // Watch maintenance
    if (lowerMessage.contains('maintain') ||
        lowerMessage.contains('care') ||
        lowerMessage.contains('service')) {
      return '''🔧 **Watch Care & Maintenance**

**⚙️ Regular Maintenance:**
• Service every 3-5 years (mechanical)
• Service every 2-3 years (quartz)
• Keep away from magnets
• Avoid extreme temperatures

**💧 Daily Care:**
• Clean with soft cloth
• Dry after exposure to water
• Store in watch box when not wearing
• Avoid perfume contact

**🔋 Battery Life:**
• Quartz: 2-5 years
• Automatic: Self-winding with movement
• Solar: 6+ months with light exposure

Need help finding a service center for your watch?''';
    }

    // Quartz vs Automatic
    if (lowerMessage.contains('quartz') ||
        lowerMessage.contains('automatic') ||
        lowerMessage.contains('movement')) {
      return '''⚙️ **Quartz vs Automatic Movements**

**🔋 Quartz Movement:**
• Battery powered
• Extremely accurate (±15 seconds/month)
• Affordable (\$50-\$500)
• Low maintenance
• Perfect for everyday wear

**⚙️ Automatic Movement:**
• Self-winding from wrist motion
• Traditional craftsmanship
• More expensive (\$200-\$10,000+)
• Requires regular wear
• Watch enthusiast favorite

**🎯 Which to Choose:**
• **Quartz**: Practical, accurate, affordable
• **Automatic**: Luxury status, craftsmanship, tradition

Both are excellent - it depends on your priorities!''';
    }

    // Order tracking
    if (lowerMessage.contains('order') ||
        lowerMessage.contains('track') ||
        lowerMessage.contains('delivery')) {
      return '''📦 **Order Tracking**

To track your order:

1. **Check Your Email**: You should have received tracking information
2. **Log into Your Account**: View order history in profile
3. **Contact Support**: Email support@luxetime.com with order number
4. **Delivery Times**: 
   • Standard: 3-5 business days
   • Express: 1-2 business days

**Need Help?**
• Order number: ORD-XXXXXX
• Email: support@luxetime.com  
• Phone: 1-800-LUXETIME

What's your order number? I can check the status for you!''';
    }

    // Password reset
    if (lowerMessage.contains('password') ||
        lowerMessage.contains('reset') ||
        lowerMessage.contains('login')) {
      return '''🔐 **Password Reset**

**To reset your password:**

1. **Go to Login Screen**
2. **Click "Forgot Password"**
3. **Enter your email address**
4. **Check your email** for reset link
5. **Create new password**

**🔒 Password Requirements:**
• At least 8 characters
• Include uppercase & lowercase
• Add numbers and symbols
• Don't use common passwords

**Still having issues?**
• Email: support@luxetime.com
• Call: 1-800-LUXETIME
• Live chat available 9am-6pm EST

I can help you through the process step by step!''';
    }

    // Price ranges
    if (lowerMessage.contains('under') ||
        lowerMessage.contains('budget') ||
        lowerMessage.contains('\$')) {
      if (lowerMessage.contains('500') || lowerMessage.contains('affordable')) {
        return '''💰 **Best Watches Under \$500**

**🏆 Top Picks:**
• **Seiko 5 Sports** - \$125, automatic, reliable
• **Citizen Eco-Drive** - \$200-400, solar powered
• **Tissot Everytime** - \$350, Swiss quality
• **Hamilton Khaki Field** - \$500, military style
• **Orient Bambino** - \$300, classic design

**🎯 Best Value Under \$500:**
• **Seiko**: Japanese reliability, automatic movement
• **Citizen**: Eco-Drive technology, never needs battery
• **Tissot**: Swiss quality, affordable luxury

Which style interests you most?''';
      }
    }

    // Default response
    return '''👋 **Welcome to LUXE TIME!**

I'm here to help you find the perfect luxury watch. Here's what I can assist with:

**🔍 Find Your Perfect Watch:**
• Brand recommendations (Rolex, Omega, etc.)
• Style suggestions (business, sport, casual)
• Budget-friendly options
• Technical specifications

**💎 Expert Advice:**
• Watch maintenance tips
• Movement types explained
• Water resistance guide
• Size recommendations

**📦 Order Support:**
• Track your order
• Shipping information
• Returns and exchanges
• Customer service

**🎯 Quick Start:**
Try asking about:
• "Best watches under \$1000"
• "Waterproof diving watches"
• "Business professional watches"
• "Rolex vs Omega comparison"

How can I help you today?''';
  }

  // Quick suggestions for common queries
  static const List<String> quickSuggestions = [
    'What are the best luxury watch brands?',
    'Recommend a watch for business meetings',
    'How to maintain my watch?',
    'What is the difference between quartz and automatic?',
    'Show me waterproof watches',
    'Best watches under \$500',
    'Track my order',
    'How to reset my password?',
  ];

  // Clear chat history
  void clearChat() {
    if (_model != null) {
      _chat = _model!.startChat();
    }
  }
}
