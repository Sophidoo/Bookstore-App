import 'package:bookstore/features/admin/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircular;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius:
            isCircular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(4),
      ),
      child: const ShimmerEffect(),
    );
  }
}
