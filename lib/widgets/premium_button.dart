import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

enum PremiumButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final PremiumButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final double? width;
  final Color? customColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = PremiumButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.width,
    this.customColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getButtonColors();
    final buttonHeight = widget.height ?? 56.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : widget.width,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: colors.borderColor != null
                    ? Border.all(color: colors.borderColor!, width: 2)
                    : null,
                boxShadow: colors.shadowColor != null
                    ? [
                        BoxShadow(
                          color: colors.shadowColor!,
                          blurRadius: _isPressed ? 8 : 12,
                          offset: Offset(0, _isPressed ? 2 : 4),
                          spreadRadius: _isPressed ? -1 : 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? _buildLoadingSpinner(colors.textColor)
                    : _buildButtonContent(colors.textColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSpinner(Color textColor) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(textColor),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: GoogleFonts.inter(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  _ButtonColors _getButtonColors() {
    switch (widget.type) {
      case PremiumButtonType.primary:
        return _ButtonColors(
          backgroundColor: widget.customColor ?? AppColors.accent,
          textColor: Colors.white,
          shadowColor: (widget.customColor ?? AppColors.accent).withValues(alpha:0.3),
        );
      
      case PremiumButtonType.secondary:
        return _ButtonColors(
          backgroundColor: Colors.white,
          textColor: widget.customColor ?? AppColors.accent,
          borderColor: widget.customColor ?? AppColors.accent,
          shadowColor: Colors.black.withValues(alpha:0.1),
        );
      
      case PremiumButtonType.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: widget.customColor ?? AppColors.accent,
          borderColor: widget.customColor ?? AppColors.accent,
        );
      
      case PremiumButtonType.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: widget.customColor ?? Colors.white,
        );
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color? shadowColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.shadowColor,
  });
}

/// Floating Action Button with premium styling
class PremiumFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const PremiumFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final fabColor = backgroundColor ?? AppColors.accent;
    final fabIconColor = iconColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: fabColor.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: fabColor,
        elevation: 0,
        child: Icon(
          icon,
          color: fabIconColor,
          size: 24,
        ),
      ),
    );
  }
}
