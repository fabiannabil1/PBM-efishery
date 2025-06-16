import 'package:flutter/material.dart';

class ContinueButton extends StatefulWidget {
  final bool isEnabled;
  final Future<void> Function()? onPressed;
  final String label;
  final IconData? icon;
  final Color? primaryColor;
  final Color? disabledColor;
  final double? width;
  final double? height;
  final bool showLoadingOnPress;

  const ContinueButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.label,
    this.icon,
    this.primaryColor,
    this.disabledColor,
    this.width,
    this.height = 56,
    this.showLoadingOnPress = true,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Default colors
  static const Color defaultPrimaryColor = Color(0xFF1E88E5);
  static const Color defaultDisabledColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (!widget.isEnabled || _isLoading || widget.onPressed == null) return;

    // Animation feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.showLoadingOnPress) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await widget.onPressed!();
    } finally {
      if (mounted && widget.showLoadingOnPress) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? defaultPrimaryColor;
    final disabledColor = widget.disabledColor ?? defaultDisabledColor;
    final isInteractable = widget.isEnabled && !_isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient:
                  isInteractable
                      ? LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                      : null,
              color: !isInteractable ? disabledColor : null,
              boxShadow:
                  isInteractable
                      ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handlePress,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child:
                        _isLoading
                            ? _buildLoadingContent()
                            : _buildButtonContent(isInteractable),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent(bool isInteractable) {
    final textColor = isInteractable ? Colors.white : Colors.grey[600];

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(widget.icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// Variant khusus untuk primary actions
class PrimaryContinueButton extends ContinueButton {
  const PrimaryContinueButton({
    super.key,
    required super.isEnabled,
    required super.onPressed,
    required super.label,
    super.icon,
    super.width,
    super.height,
    super.showLoadingOnPress,
  }) : super(primaryColor: const Color(0xFF1E88E5));
}

// Variant khusus untuk success actions
class SuccessContinueButton extends ContinueButton {
  const SuccessContinueButton({
    super.key,
    required super.isEnabled,
    required super.onPressed,
    required super.label,
    super.icon,
    super.width,
    super.height,
    super.showLoadingOnPress,
  }) : super(primaryColor: const Color(0xFF4CAF50));
}

// Variant khusus untuk warning actions
class WarningContinueButton extends ContinueButton {
  const WarningContinueButton({
    super.key,
    required super.isEnabled,
    required super.onPressed,
    required super.label,
    super.icon,
    super.width,
    super.height,
    super.showLoadingOnPress,
  }) : super(primaryColor: const Color(0xFFFF9800));
}

// Variant khusus untuk danger actions
class DangerContinueButton extends ContinueButton {
  const DangerContinueButton({
    super.key,
    required super.isEnabled,
    required super.onPressed,
    required super.label,
    super.icon,
    super.width,
    super.height,
    super.showLoadingOnPress,
  }) : super(primaryColor: const Color(0xFFF44336));
}
