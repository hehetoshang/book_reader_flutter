import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final bool showPercentage;
  final Color? backgroundColor;
  final Color? progressColor;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    this.showPercentage = false,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[300];
    final fgColor = progressColor ?? Theme.of(context).colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(
              height: height,
              color: bgColor,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clampedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: fgColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(width: 8),
          Text(
            '${(clampedProgress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

class CircularReadingProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;

  const CircularReadingProgress({
    super.key,
    required this.progress,
    this.size = 48,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[300];
    final fgColor = progressColor ?? Theme.of(context).colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: clampedProgress,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            strokeWidth: strokeWidth,
          ),
          if (showPercentage)
            Center(
              child: Text(
                '${(clampedProgress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
