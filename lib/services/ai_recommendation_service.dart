import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/watch.dart';
import 'package:logger/logger.dart';

class WristAnalysis {
  final double wristWidth;
  final double wristHeight;
  final String skinTone;
  final String wristSize;
  final Map<String, double> stylePreferences;

  WristAnalysis({
    required this.wristWidth,
    required this.wristHeight,
    required this.skinTone,
    required this.wristSize,
    required this.stylePreferences,
  });
}

class RecommendationResult {
  final List<Watch> recommendedWatches;
  final String explanation;
  final double confidence;
  final Map<String, String> reasons;

  RecommendationResult({
    required this.recommendedWatches,
    required this.explanation,
    required this.confidence,
    required this.reasons,
  });
}

class AIRecommendationService {
  late final GenerativeModel _model;
  bool _isInitialized = false;
  final Logger _logger = Logger();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Note: You'll need to set up your API key
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      _isInitialized = true;
      _logger.d('AI recommendation service initialized');
    } catch (e) {
      _logger.d('AI initialization error: $e');
      // Fallback to mock recommendations if API fails
      _isInitialized = true;
    }
  }

  Future<RecommendationResult> getRecommendations(
    WristAnalysis analysis,
    List<Watch> availableWatches,
    String userFeedback,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final prompt = _buildPrompt(analysis, availableWatches, userFeedback);

      if (_isInitialized &&
          String.fromEnvironment('GEMINI_API_KEY').isNotEmpty) {
        final response = await _model.generateContent([Content.text(prompt)]);
        return _parseAIResponse(response.text, availableWatches);
      } else {
        // Fallback to rule-based recommendations
        return _getRuleBasedRecommendations(
          analysis,
          availableWatches,
          userFeedback,
        );
      }
    } catch (e) {
      _logger.d('AI recommendation error: $e');
      return _getRuleBasedRecommendations(
        analysis,
        availableWatches,
        userFeedback,
      );
    }
  }

  String _buildPrompt(
    WristAnalysis analysis,
    List<Watch> watches,
    String feedback,
  ) {
    // Add variety based on different factors
    final currentTime = DateTime.now().hour;
    String timeContext = currentTime < 12
        ? 'morning'
        : currentTime < 17
        ? 'afternoon'
        : 'evening';

    return '''
You are an expert watch stylist and AI recommendation system for a luxury watch e-commerce app. 
Provide DIVERSE and PERSONALIZED recommendations based on multiple factors.

USER ANALYSIS:
- Wrist Size: ${analysis.wristSize} (${analysis.wristWidth}mm x ${analysis.wristHeight}mm)
- Skin Tone: ${analysis.skinTone}
- Style Preferences: ${analysis.stylePreferences.entries.map((e) => '${e.key}: ${(e.value * 100).toInt()}%').join(', ')}
- User Feedback: "$feedback"
- Current Time Context: $timeContext

AVAILABLE WATCHES:
${watches.map((watch) => '''
- ${watch.name} (${watch.brand})
  Price: \$${watch.price}
  Style: ${watch.style}
  Case Size: ${watch.caseSize}mm
  Color: ${watch.colors.join(', ')}
  Description: ${watch.description}
''').join('\n')}

TASK:
1. Analyze the user's wrist characteristics, preferences, and feedback
2. Recommend 3-5 BEST MATCHING watches with VARIETY in:
   - Different price ranges (budget, mid-range, premium)
   - Different styles (casual, formal, sport, luxury)
   - Different brands (don't recommend all from same brand)
   - Different occasions (daily wear, business, special events)
3. For each recommendation, provide SPECIFIC reasons:
   - How the case size fits their wrist
   - How the color complements their skin tone
   - How the style matches their preferences
   - How it addresses their previous feedback
4. Consider the current time context for relevant suggestions
5. Include at least one unexpected but suitable recommendation

RESPONSE FORMAT:
RECOMMENDATIONS:
1. [Watch Name] - [Brand] - [\$Price]
   REASON: [Detailed explanation including fit, color, style, and occasion]
   CONFIDENCE: [0-100%]
   BEST_FOR: [Daily wear/Business/Special occasions]
   
2. [Watch Name] - [Brand] - [\$Price]
   REASON: [Different perspective - focus on different aspect]
   CONFIDENCE: [0-100%]
   BEST_FOR: [Different occasion]
   
3. [Watch Name] - [Brand] - [\$Price]
   REASON: [Highlight unique feature or benefit]
   CONFIDENCE: [0-100%]
   BEST_FOR: [Specific use case]

OVERALL_EXPLANATION: [Personalized advice considering all factors]
STYLE_TIP: [Additional styling suggestion for the user]
''';
  }

  RecommendationResult _parseAIResponse(String? response, List<Watch> watches) {
    if (response == null) {
      return _getRuleBasedRecommendations(
        WristAnalysis(
          wristWidth: 50,
          wristHeight: 60,
          skinTone: 'medium',
          wristSize: 'medium',
          stylePreferences: {},
        ),
        watches,
        '',
      );
    }

    // Enhanced parsing with more realistic and personalized suggestions
    final recommendedWatches = <Watch>[];
    final reasons = <String, String>{};
    double totalConfidence = 0;

    final lines = response.split('\n');
    String currentWatchName = '';

    // Enhanced analysis for more realistic recommendations
    Map<String, dynamic> userProfile = {
      'skinTone': 'medium',
      'wristSize': 'medium',
      'preferredStyles': ['casual', 'sport'],
      'budgetRange': '\$500-\$2000',
      'previousPurchases': [],
    };

    for (final line in lines) {
      if (line.startsWith('1.') ||
          line.startsWith('2.') ||
          line.startsWith('3.')) {
        final parts = line.split(' - ');
        if (parts.length >= 2) {
          final watchName = parts[0].substring(2).trim();
          final brand = parts[1].trim();

          // Enhanced matching algorithm
          final matchingWatch = _findBestMatch(
            watchName,
            brand,
            watches,
            userProfile,
          );
          recommendedWatches.add(matchingWatch);
        }
      }

      // Extract additional personalized advice
      if (line.startsWith('STYLE_TIP:')) {
        final styleTip = line.substring(11).trim();
        reasons['styleAdvice'] = styleTip;
      }

      if (line.startsWith('BEST_FOR:')) {
        final bestFor = line.substring(11).trim();
        reasons['bestFor'] = bestFor;
      }
    }

    return RecommendationResult(
      recommendedWatches: recommendedWatches.take(5).toList(),
      explanation: response,
      confidence: recommendedWatches.isNotEmpty
          ? totalConfidence / recommendedWatches.length
          : 0,
      reasons: reasons,
    );
  }

  // Find best matching watch based on user profile
  Watch _findBestMatch(
    String watchName,
    String brand,
    List<Watch> watches,
    Map<String, dynamic> userProfile,
  ) {
    double bestScore = 0;
    Watch? bestMatch;

    for (final watch in watches) {
      double score = 0;

      // Name match (40%)
      if (watch.name.toLowerCase().contains(watchName.toLowerCase())) {
        score += 40;
      }

      // Brand match (30%)
      if (watch.brand.toLowerCase() == brand.toLowerCase()) {
        score += 30;
      }

      // Style preference match (20%)
      if (userProfile['preferredStyles'].contains(watch.style.toLowerCase())) {
        score += 20;
      }

      // Price range match (10%)
      final priceRange = userProfile['budgetRange'];
      if (priceRange.contains('\$500-\$2000') && watch.price <= 2000)
        score += 10;
      if (priceRange.contains('\$2000-\$5000') &&
          watch.price > 2000 &&
          watch.price <= 5000)
        score += 10;
      if (priceRange.contains('\$5000+') && watch.price > 5000) score += 10;

      // Skin tone compatibility (5%)
      if (_isSkinToneCompatible(watch.style, userProfile['skinTone'])) {
        score += 5;
      }

      // Wrist size compatibility (5%)
      if (_isWristSizeCompatible(watch.caseSize, userProfile['wristSize'])) {
        score += 5;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = watch;
      }
    }

    return bestMatch ?? watches.first;
  }

  // Helper methods for compatibility checking
  bool _isSkinToneCompatible(String watchStyle, String userSkinTone) {
    // Enhanced skin tone compatibility logic
    if (userSkinTone == 'fair') {
      return ['silver', 'gold', 'rose gold'].contains(watchStyle);
    }
    if (userSkinTone == 'medium') {
      return ['silver', 'gold', 'black', 'blue'].contains(watchStyle);
    }
    if (userSkinTone == 'dark') {
      return ['black', 'silver', 'gold', 'gunmetal'].contains(watchStyle);
    }
    return true; // Default to compatible
  }

  bool _isWristSizeCompatible(double watchCaseSize, String userWristSize) {
    // Enhanced wrist size compatibility
    if (userWristSize == 'small' && watchCaseSize <= 38) return true;
    if (userWristSize == 'medium' && watchCaseSize >= 38 && watchCaseSize <= 44)
      return true;
    if (userWristSize == 'large' && watchCaseSize >= 44 && watchCaseSize <= 50)
      return true;
    return false;
  }

  RecommendationResult _getRuleBasedRecommendations(
    WristAnalysis analysis,
    List<Watch> watches,
    String feedback,
  ) {
    final recommendedWatches = <Watch>[];
    final reasons = <String, String>{};

    // Rule-based recommendations based on wrist size
    for (final watch in watches) {
      double score = 0;

      // Size compatibility
      if (analysis.wristSize == 'small' && watch.caseSize <= 38) score += 30;
      if (analysis.wristSize == 'medium' &&
          watch.caseSize >= 38 &&
          watch.caseSize <= 42)
        score += 30;
      if (analysis.wristSize == 'large' && watch.caseSize >= 42) score += 30;

      // Style preferences
      analysis.stylePreferences.forEach((style, preference) {
        if (watch.style.toLowerCase().contains(style.toLowerCase())) {
          score += preference * 40;
        }
      });

      // Color compatibility (simple rules)
      if (analysis.skinTone.toLowerCase().contains('light')) {
        if (watch.colors.any(
          (color) =>
              color.toLowerCase().contains('silver') ||
              color.toLowerCase().contains('gold'),
        )) {
          score += 20;
        }
      }

      if (score >= 50) {
        recommendedWatches.add(watch);
        reasons[watch.name] = _generateReason(watch, analysis, score);
      }
    }

    // Sort by score and take top 5
    recommendedWatches.sort(
      (a, b) => (reasons[b.name]?.length ?? 0).compareTo(
        reasons[a.name]?.length ?? 0,
      ),
    );

    return RecommendationResult(
      recommendedWatches: recommendedWatches.take(5).toList(),
      explanation:
          'Based on your wrist analysis and preferences, I\'ve selected watches that complement your features.',
      confidence: 75.0,
      reasons: reasons,
    );
  }

  String _generateReason(Watch watch, WristAnalysis analysis, double score) {
    final reasons = <String>[];

    if (analysis.wristSize == 'small' && watch.caseSize <= 38) {
      reasons.add('perfect size for smaller wrists');
    } else if (analysis.wristSize == 'medium' &&
        watch.caseSize >= 38 &&
        watch.caseSize <= 42) {
      reasons.add('ideal proportions for medium wrists');
    } else if (analysis.wristSize == 'large' && watch.caseSize >= 42) {
      reasons.add('substantial presence for larger wrists');
    }

    if (watch.style.toLowerCase().contains('luxury')) {
      reasons.add('elegant luxury design');
    }
    if (watch.style.toLowerCase().contains('sport')) {
      reasons.add('versatile sporty look');
    }

    return reasons.join(', ');
  }

  WristAnalysis analyzeWrist(
    double wristWidth,
    double wristHeight,
    String skinTone,
  ) {
    // Determine wrist size category
    String wristSize;
    if (wristWidth < 45) {
      wristSize = 'small';
    } else if (wristWidth < 55) {
      wristSize = 'medium';
    } else {
      wristSize = 'large';
    }

    // Default style preferences (could be enhanced with user data)
    final stylePreferences = <String, double>{
      'luxury': 0.7,
      'casual': 0.6,
      'sport': 0.4,
      'formal': 0.5,
    };

    return WristAnalysis(
      wristWidth: wristWidth,
      wristHeight: wristHeight,
      skinTone: skinTone,
      wristSize: wristSize,
      stylePreferences: stylePreferences,
    );
  }
}
