import 'package:bookstore/features/admin/widgets/shimmer_container.dart';
import 'package:flutter/material.dart';

class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerContainer(width: 24, height: 24, isCircular: true),
          const SizedBox(height: 12),
          ShimmerContainer(width: 60, height: 24),
          const SizedBox(height: 4),
          ShimmerContainer(width: 80, height: 14),
        ],
      ),
    );
  }
}
