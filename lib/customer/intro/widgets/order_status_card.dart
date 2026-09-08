import 'package:flutter/material.dart';
import '../models/order_status.dart';

class OrderStatusCard extends StatelessWidget {
  final Map<OrderStatus, bool> stepStatus;

  const OrderStatusCard({
    super.key,
    required this.stepStatus,
  });

  @override
  Widget build(BuildContext context) {
    // 👈 done steps first, then pending
    final doneSteps = stepStatus.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    final pendingSteps = stepStatus.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();

    // With this:
    final deliveryDone = stepStatus[OrderStatus.delivered] == true;
    final orderedSteps = deliveryDone
        ? doneSteps  // 👈 hide pending if delivered
        : [...doneSteps, ...pendingSteps];
    return Column(
      children: [
        // 🔹 LINE + DOTS
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 PROGRESS LINE
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: List.generate(orderedSteps.length - 1, (index) {
                    final isLineActive =
                        stepStatus[orderedSteps[index]] == true;
                    return Expanded(
                      child: Container(
                        height: 5,
                        color: isLineActive
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),

              // 🔹 DOTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: orderedSteps.map((step) {
                  final isCompleted = stepStatus[step] == true;
                  final isLastDone = isCompleted &&
                      step == doneSteps.lastOrNull;

                  return _buildDot(
                    isCompleted: isCompleted,
                    isLastDone: isLastDone,
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 LABELS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: orderedSteps.map((step) {
            return SizedBox(
              width: 60,
              child: Text(
                _label(step),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDot({
    required bool isCompleted,
    required bool isLastDone,
  }) {
    double size = 20;
    Color color = Colors.grey.shade300;

    if (isLastDone) {
      size = 30;
      color = Colors.green;
    } else if (isCompleted) {
      size = 24;
      color = Colors.blue;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(
        Icons.check,
        size: isLastDone ? 18 : 14,
        color: Colors.white,
      )
          : null,
    );
  }

  String _label(OrderStatus status) {
    switch (status) {
      case OrderStatus.designing:
        return 'Designing';
      case OrderStatus.laserCutting:
        return 'Laser\nCutting';
      case OrderStatus.autoBending:
        return 'Auto\nBending';
      case OrderStatus.manualBending:
        return 'Manual\nBending';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}