import 'package:flutter/material.dart';

/// Enhanced Prayer Card with modern styling and states
class PrayerCard extends StatelessWidget {
  final String label;
  final String time;
  final IconData? icon;
  final bool isNext;
  final bool isPassed;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final PrayerCardStyle style;

  const PrayerCard({
    super.key,
    required this.label,
    required this.time,
    this.icon,
    this.isNext = false,
    this.isPassed = false,
    this.isHighlighted = false,
    this.onTap,
    this.style = PrayerCardStyle.modern,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case PrayerCardStyle.modern:
        return _buildModernCard(context);
      case PrayerCardStyle.compact:
        return _buildCompactCard(context);
      case PrayerCardStyle.elevated:
        return _buildElevatedCard(context);
      case PrayerCardStyle.minimal:
        return _buildMinimalCard(context);
    }
  }

  /// Modern card style with icons and states
  Widget _buildModernCard(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final timeColor = _getTimeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: isNext && !isHighlighted
            ? Border.all(color: Colors.teal[300]!, width: 2)
            : null,
        boxShadow: _getShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Prayer name and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (isNext && !isHighlighted) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Next Prayer',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Time
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: timeColor,
                  ),
                ),
                
                // Status indicator
                if (isPassed && !isNext) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact card style
  Widget _buildCompactCard(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final timeColor = _getTimeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isNext && !isHighlighted
            ? Border.all(color: Colors.teal[300]!)
            : Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
          if (isPassed && !isNext) ...[
            const SizedBox(width: 8),
            Icon(Icons.check, color: Colors.grey[400], size: 16),
          ],
        ],
      ),
    );
  }

  /// Elevated card with prominent shadow
  Widget _buildElevatedCard(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final timeColor = _getTimeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getIconBackgroundColor(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getIconColor(),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (isNext && !isHighlighted) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Next Prayer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Minimal card style
  Widget _buildMinimalCard(BuildContext context) {
    final textColor = _getTextColor();
    final timeColor = _getTimeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (isNext && !isHighlighted) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.teal[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }

  // ===== HELPER METHODS =====

  IconData _getIcon() {
    if (icon != null) return icon!;
    
    // Default icons based on prayer name
    switch (label.toLowerCase()) {
      case 'fajr':
      case 'subuh':
        return Icons.wb_twilight;
      case 'sunrise':
      case 'syuruk':
        return Icons.wb_sunny;
      case 'dhuhr':
      case 'zohor':
        return Icons.wb_sunny_outlined;
      case 'asr':
      case 'asar':
        return Icons.wb_cloudy;
      case 'maghrib':
      case 'magrib':
        return Icons.wb_twilight;
      case 'isha':
      case 'isyak':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  Color _getBackgroundColor() {
    if (isHighlighted) {
      return Colors.teal[600]!;
    }
    if (isPassed) {
      return Colors.grey[50]!;
    }
    return Colors.white;
  }

  Color _getTextColor() {
    if (isHighlighted) {
      return Colors.white;
    }
    if (isPassed) {
      return Colors.grey[400]!;
    }
    return const Color(0xFF2E3A59);
  }

  Color _getTimeColor() {
    if (isHighlighted) {
      return Colors.white;
    }
    if (isPassed) {
      return Colors.grey[400]!;
    }
    return Colors.teal[600]!;
  }

  Color _getIconColor() {
    if (isHighlighted) {
      return Colors.white;
    }
    if (isPassed) {
      return Colors.grey[400]!;
    }
    return Colors.teal[600]!;
  }

  Color _getIconBackgroundColor() {
    if (isHighlighted) {
      return Colors.white.withOpacity(0.2);
    }
    if (isPassed) {
      return Colors.grey[100]!;
    }
    return Colors.teal[50]!;
  }

  List<BoxShadow> _getShadow() {
    if (isHighlighted) {
      return [
        BoxShadow(
          color: Colors.teal.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];
    }
    return [];
  }
}

/// Prayer card styles
enum PrayerCardStyle {
  /// Modern style with icons and rounded corners
  modern,
  
  /// Compact style with less padding
  compact,
  
  /// Elevated style with prominent shadow
  elevated,
  
  /// Minimal style with bottom border only
  minimal,
}

/// Prayer card builder for creating multiple cards
class PrayerCardBuilder {
  /// Build prayer cards from prayer times data
  static List<Widget> buildCards({
    required List<PrayerTime> prayers,
    PrayerCardStyle style = PrayerCardStyle.modern,
    VoidCallback? onCardTap,
  }) {
    final now = DateTime.now();
    String? nextPrayer;
    
    // Find next prayer
    for (var prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        nextPrayer = prayer.name;
        break;
      }
    }

    return prayers.map((prayer) {
      final isPassed = prayer.time.isBefore(now);
      final isNext = prayer.name == nextPrayer;

      return PrayerCard(
        label: prayer.name,
        time: prayer.formattedTime,
        icon: prayer.icon,
        isNext: isNext,
        isPassed: isPassed,
        style: style,
        onTap: onCardTap,
      );
    }).toList();
  }
}

/// Prayer time data model
class PrayerTime {
  final String name;
  final DateTime time;
  final IconData? icon;

  PrayerTime({
    required this.name,
    required this.time,
    this.icon,
  });

  String get formattedTime {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}