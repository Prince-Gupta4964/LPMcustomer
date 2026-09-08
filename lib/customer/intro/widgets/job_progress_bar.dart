import 'package:flutter/material.dart';

class JobProgressBar extends StatelessWidget {
  final List<bool> stepsStatus;
  final void Function(int index)? onStepToggle; // optional (manual mode)

  const JobProgressBar({
    super.key,
    required this.stepsStatus,
    this.onStepToggle,
  });

  static const _labels = [
    'Designing',
    'Laser Cutting',
    'Auto Bending',
    'Manual Bending',
    'Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔵 DOTS + LINES
        Row(
          children: List.generate(_labels.length, (index) {
            final isCompleted = stepsStatus[index];
            final isLast = index == _labels.length - 1;

            final dotColor = isCompleted
                ? (isLast ? Colors.green : Colors.blue)
                : Colors.grey.shade300;

            return Expanded(
              child: Row(
                children: [
                  // 🔘 DOT / CHECKBOX
                  GestureDetector(
                    onTap: onStepToggle == null
                        ? null
                        : () => onStepToggle!(index),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                      ),
                      child: isCompleted
                          ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),

                  // ─ LINE
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isCompleted
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // 🏷️ LABELS
        Row(
          children: List.generate(_labels.length, (index) {
            final isCompleted = stepsStatus[index];

            return Expanded(
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isCompleted
                      ? (index == _labels.length - 1
                      ? Colors.green
                      : Colors.blue)
                      : Colors.grey.shade500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
