import 'package:flutter/material.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';

/// Stock news description with expandable content
class StockDescription extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final VoidCallback? onMoreToggle;

  const StockDescription({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    this.onMoreToggle,
  });

  @override
  State<StockDescription> createState() => _StockDescriptionState();
}

class _StockDescriptionState extends State<StockDescription> {
  bool _isExpanded = false;
  static const int _collapsedLength = 100;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onMoreToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final shouldTruncate = widget.description.length > _collapsedLength;
    final displayText = _isExpanded || !shouldTruncate
        ? widget.description
        : '${widget.description.substring(0, _collapsedLength)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 3),
        // Description with "more" button
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
            children: [
              TextSpan(text: displayText),
              if (shouldTruncate) ...[
                const TextSpan(text: '  '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: _toggleExpanded,
                    child: Text(
                      _isExpanded ? 'less' : 'more',
                      style: AppTextStyles.labelSmall(
                        color: AppColors.textLabel,
                      ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Date
        Text(
          widget.date,
          style: AppTextStyles.labelSmall(color: AppColors.textLabel),
        ),
      ],
    );
  }
}
