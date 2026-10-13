import 'package:flutter/material.dart';

/// Enhanced Countdown Timer with modern styling and animations
class CountdownTimer extends StatelessWidget {
  final Duration duration;
  final bool showLabels;
  final bool showHours;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final CountdownStyle style;

  const CountdownTimer({
    super.key,
    required this.duration,
    this.showLabels = false,
    this.showHours = true,
    this.fontSize = 28,
    this.textColor,
    this.backgroundColor,
    this.style = CountdownStyle.modern,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case CountdownStyle.modern:
        return _buildModernStyle(context);
      case CountdownStyle.compact:
        return _buildCompactStyle(context);
      case CountdownStyle.card:
        return _buildCardStyle(context);
      case CountdownStyle.gradient:
        return _buildGradientStyle(context);
    }
  }

  /// Modern style with separated time units
  Widget _buildModernStyle(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final color = textColor ?? Colors.teal[600]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHours && hours > 0) ...[
          _buildTimeUnit(
            hours.toString().padLeft(2, '0'),
            'Hours',
            color,
          ),
          _buildSeparator(color),
        ],
        _buildTimeUnit(
          minutes.toString().padLeft(2, '0'),
          'Minutes',
          color,
        ),
        _buildSeparator(color),
        _buildTimeUnit(
          seconds.toString().padLeft(2, '0'),
          'Seconds',
          color,
        ),
      ],
    );
  }

  /// Compact style with simple display
  Widget _buildCompactStyle(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final color = textColor ?? Colors.teal[600]!;

    String timeString;
    if (showHours && hours > 0) {
      timeString = '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      timeString = '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return Text(
      timeString,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  /// Card style with background boxes
  Widget _buildCardStyle(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final color = textColor ?? Colors.white;
    final bgColor = backgroundColor ?? Colors.teal[600]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHours && hours > 0) ...[
          _buildTimeCard(
            hours.toString().padLeft(2, '0'),
            showLabels ? 'Hours' : null,
            color,
            bgColor,
          ),
          const SizedBox(width: 8),
          _buildCardSeparator(color),
          const SizedBox(width: 8),
        ],
        _buildTimeCard(
          minutes.toString().padLeft(2, '0'),
          showLabels ? 'Min' : null,
          color,
          bgColor,
        ),
        const SizedBox(width: 8),
        _buildCardSeparator(color),
        const SizedBox(width: 8),
        _buildTimeCard(
          seconds.toString().padLeft(2, '0'),
          showLabels ? 'Sec' : null,
          color,
          bgColor,
        ),
      ],
    );
  }

  /// Gradient style with beautiful background
  Widget _buildGradientStyle(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? Colors.teal[400]!,
            backgroundColor?.withOpacity(0.8) ?? Colors.teal[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? Colors.teal[600]!).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHours && hours > 0) ...[
            _buildGradientTimeUnit(
              hours.toString().padLeft(2, '0'),
              showLabels ? 'Hours' : null,
            ),
            _buildGradientSeparator(),
          ],
          _buildGradientTimeUnit(
            minutes.toString().padLeft(2, '0'),
            showLabels ? 'Min' : null,
          ),
          _buildGradientSeparator(),
          _buildGradientTimeUnit(
            seconds.toString().padLeft(2, '0'),
            showLabels ? 'Sec' : null,
          ),
        ],
      ),
    );
  }

  // ===== BUILDING BLOCKS =====

  Widget _buildTimeUnit(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize * 0.35,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    String value,
    String? label,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.5,
        vertical: fontSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize * 0.3,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardSeparator(Color color) {
    return Text(
      ':',
      style: TextStyle(
        fontSize: fontSize * 0.8,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildGradientTimeUnit(String value, String? label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize * 0.35,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGradientSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }
}

/// Animated countdown timer with tick updates
class AnimatedCountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final CountdownStyle style;
  final bool showLabels;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onComplete;

  const AnimatedCountdownTimer({
    super.key,
    required this.targetTime,
    this.style = CountdownStyle.modern,
    this.showLabels = false,
    this.fontSize = 28,
    this.textColor,
    this.backgroundColor,
    this.onComplete,
  });

  @override
  State<AnimatedCountdownTimer> createState() => _AnimatedCountdownTimerState();
}

class _AnimatedCountdownTimerState extends State<AnimatedCountdownTimer> {
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.targetTime.difference(now);
    
    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });

      if (remaining.isNegative && widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateRemaining();
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CountdownTimer(
      duration: _remaining,
      style: widget.style,
      showLabels: widget.showLabels,
      fontSize: widget.fontSize,
      textColor: widget.textColor,
      backgroundColor: widget.backgroundColor,
    );
  }
}

/// Countdown timer styles
enum CountdownStyle {
  /// Modern style with separated time units
  modern,
  
  /// Compact style with simple colon-separated display
  compact,
  
  /// Card style with background boxes for each unit
  card,
  
  /// Gradient style with beautiful background
  gradient,
}

/// Helper extension for creating countdown timers
extension CountdownTimerExtension on Duration {
  /// Create a countdown timer widget from this duration
  Widget toCountdownTimer({
    CountdownStyle style = CountdownStyle.modern,
    bool showLabels = false,
    double fontSize = 28,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return CountdownTimer(
      duration: this,
      style: style,
      showLabels: showLabels,
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
  }
}