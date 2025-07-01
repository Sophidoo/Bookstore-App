import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isEnabled;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled || widget.isLoading) return;

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: widget.isEnabled && !widget.isLoading ? _handleTap : null,
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            enableFeedback: false,
            foregroundColor: widget.isEnabled ? Colors.white : Colors.grey[400],
            backgroundColor:
                widget.isEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.4),
          ),
          child:
              widget.isLoading
                  ? Transform.scale(
                    scale: 0.7,
                    child: const CircularProgressIndicator(color: Colors.white),
                  )
                  : Text(
                    widget.buttonText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.isEnabled ? Colors.white : Colors.grey[600],
                    ),
                  ),
        ),
      ),
    );
  }
}
