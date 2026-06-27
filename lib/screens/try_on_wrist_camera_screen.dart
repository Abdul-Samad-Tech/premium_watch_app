import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../models/watch.dart';
import '../core/constants/colors.dart';
import '../services/wrist_detection_service.dart';
import '../services/ai_recommendation_service.dart';
import '../widgets/try_on_feedback_popup.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class TryOnWristCameraScreen extends StatefulWidget {
  final Watch watch;

  const TryOnWristCameraScreen({super.key, required this.watch});

  @override
  State<TryOnWristCameraScreen> createState() => _TryOnWristCameraScreenState();
}

class _TryOnWristCameraScreenState extends State<TryOnWristCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  Uint8List? _capturedImage;
  bool _showWatchOverlay = true;
  double _watchScale = 1.0;
  double _watchRotation = 0;
  Offset _watchPosition = Offset.zero;
  final ImagePicker _imagePicker = ImagePicker();
  final Logger _logger = Logger();

  // AI Services
  final WristDetectionService _wristDetectionService = WristDetectionService();
  final AIRecommendationService _aiRecommendationService =
      AIRecommendationService();

  // Wrist detection results
  WristDetectionResult? _wristDetectionResult;
  bool _isDetectingWrist = false;
  bool _isAutoPositioning = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (kIsWeb) {
        // On web, we'll use image picker instead of camera
        setState(() {
          _isCameraInitialized = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        _logger.d('Camera not available on web');
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } catch (e) {
      _logger.d('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _capturedImage = bytes;
        });
        _detectWristAndPosition();
      }
    } catch (e) {
      _logger.d('Image capture error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _capturedImage = bytes;
      });

      // Detect wrist in the captured image
      await _detectWristAndPosition();

      // Show feedback dialog
      if (mounted) {
        _showFeedbackDialog();
      }
    } catch (e) {
      _logger.d('Picture taking error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
    }
  }

  Future<void> _detectWristAndPosition() async {
    if (_capturedImage == null) return;

    setState(() {
      _isDetectingWrist = true;
    });

    try {
      final result = await _wristDetectionService.detectWrist(_capturedImage!);

      if (result.isDetected && result.wristRegion != null) {
        // Validate detection quality
        if (_wristDetectionService.isWristDetectionGood(result)) {
          setState(() {
            _wristDetectionResult = result;
            _autoPositionWatch(result);
          });
        } else {
          // Detection quality is poor, try again or show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please ensure your wrist is clearly visible'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrist not detected. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.d('Wrist detection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detection failed. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isDetectingWrist = false;
      });
    }
  }

  void _autoPositionWatch(WristDetectionResult wristResult) {
    if (!mounted) return;

    setState(() {
      _isAutoPositioning = true;

      // Use enhanced position calculation
      final positionData = _wristDetectionService.calculateWatchPosition(
        wristResult,
      );

      // Adjust position for screen coordinates
      // The detected position needs to be mapped to screen coordinates
      final detectedPosition = positionData['position'] as Offset;

      // Map the detected position to screen center area
      // Since we're simulating wrist detection, we'll position it in a natural place
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Position watch in upper center area (where wrist would naturally be)
      final adjustedPosition = Offset(
        screenWidth * 0.5 +
            (detectedPosition.dx - 160) * 0.5, // Center with adjustment
        screenHeight * 0.35 + (detectedPosition.dy - 240) * 0.3, // Upper area
      );

      _watchPosition = adjustedPosition;
      _watchScale =
          positionData['scale'] * 0.8; // Slightly smaller for captured image
      _watchRotation = positionData['rotation'];

      _isAutoPositioning = false;
    });
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TryOnFeedbackPopup(
        watch: widget.watch,
        onAddToCart: () {
          Navigator.of(context).pop(); // Close feedback dialog
          _addToCart();
        },
        onRequestRecommendations: () {
          Navigator.of(context).pop(); // Close feedback dialog
          _getRecommendations();
        },
      ),
    );
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(widget.watch);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.watch.name} added to cart!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(); // Go back to previous screen
  }

  void _getRecommendations() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(width: 16),
            Text(
              'Finding perfect watches for you...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Analyze wrist if detection result is available
      final analysis = _wristDetectionResult != null
          ? _aiRecommendationService.analyzeWrist(
              _wristDetectionResult!.wristWidth ?? 50,
              _wristDetectionResult!.wristHeight ?? 60,
              'medium', // Could be enhanced with skin tone detection
            )
          : _aiRecommendationService.analyzeWrist(50, 60, 'medium');

      // Get recommendations (you'll need to pass all available watches)
      final recommendations = await _aiRecommendationService.getRecommendations(
        analysis,
        [], // Pass all available watches here
        'not_good', // User feedback
      );

      Navigator.of(context).pop(); // Close loading dialog

      // Navigate to recommendations screen
      // TODO: Create recommendations screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Found ${recommendations.recommendedWatches.length} recommendations!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error getting recommendations: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleWatchOverlay() {
    setState(() {
      _showWatchOverlay = !_showWatchOverlay;
    });
  }

  void _resetWatchPosition() {
    setState(() {
      _watchScale = 1.0;
      _watchRotation = 0;
      _watchPosition = Offset.zero;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Try On: ${widget.watch.name}',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showWatchOverlay ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: _toggleWatchOverlay,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetWatchPosition,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview or Captured Image
          if (_capturedImage != null)
            Center(
              child: Image.memory(
                _capturedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else if (_isCameraInitialized && _cameraController != null)
            Center(child: CameraPreview(_cameraController!))
          else if (kIsWeb)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Click the camera button below\nto capture your wrist',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            Center(child: CircularProgressIndicator(color: AppColors.accent)),

          // Watch Overlay - show on both preview and captured image
          if (_showWatchOverlay)
            Center(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    _watchScale = details.scale.clamp(0.5, 3.0);
                    _watchRotation = details.rotation;
                    _watchPosition += details.focalPointDelta;
                  });
                },
                child: Transform.translate(
                  offset: _watchPosition,
                  child: Transform.scale(
                    scale: _watchScale,
                    child: Transform.rotate(
                      angle: _watchRotation,
                      child: Container(
                        width: _capturedImage != null
                            ? 180
                            : 200, // Slightly smaller on captured image
                        height: _capturedImage != null ? 180 : 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                            if (_capturedImage !=
                                null) // Add shadow for AR effect
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: Offset(5, 5),
                              ),
                          ],
                        ),
                        child: ClipOval(
                          child: widget.watch.images.isNotEmpty
                              ? Image.asset(
                                  widget.watch.images[0],
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: Icon(Icons.watch, size: 100),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Size Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlButton(
                      icon: Icons.remove,
                      label: 'Smaller',
                      onPressed: () {
                        setState(() {
                          _watchScale = (_watchScale - 0.1).clamp(0.5, 3.0);
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    _ControlButton(
                      icon: Icons.add,
                      label: 'Larger',
                      onPressed: () {
                        setState(() {
                          _watchScale = (_watchScale + 0.1).clamp(0.5, 3.0);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Capture Button
                GestureDetector(
                  onTap: _capturedImage == null
                      ? (kIsWeb ? _pickImage : _takePicture)
                      : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _capturedImage == null
                          ? Colors.white
                          : Colors.grey,
                    ),
                    child: Icon(
                      _capturedImage == null ? Icons.camera : Icons.check,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (_capturedImage != null)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Photo Captured! Adjust watch position',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Reset Button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _capturedImage = null;
                            _watchPosition = Offset.zero;
                            _watchScale = 1.0;
                            _watchRotation = 0;
                          });
                        },
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 30),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: EdgeInsets.all(15),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
