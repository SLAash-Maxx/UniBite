import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

// ── Shimmer base ─────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = AppSizes.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _shimmerWrap(Widget child) => Shimmer.fromColors(
      baseColor:     AppColors.surfaceGrey,
      highlightColor: AppColors.surface,
      child: child,
    );

// ── Home screen shimmer ───────────────────────────────────────
class ShimmerHomeLoader extends StatelessWidget {
  const ShimmerHomeLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              _ShimmerBox(width: 48, height: 48,
                  radius: AppSizes.radiusMd),
              const SizedBox(width: AppSizes.md),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 80, height: 12),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 120, height: 16),
                ]),
            ]),
            const SizedBox(height: AppSizes.lg),
            // Banner
            _ShimmerBox(width: double.infinity, height: 160,
                radius: AppSizes.radiusXl),
            const SizedBox(height: AppSizes.lg),
            // Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ShimmerBox(width: 72, height: 32,
                    radius: AppSizes.radiusFull),
              ))),
            ),
            const SizedBox(height: AppSizes.lg),
            // Cards
            Row(children: List.generate(2, (i) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.md),
              child: _ShimmerBox(
                  width: AppSizes.foodCardWidth,
                  height: AppSizes.foodCardHeight,
                  radius: AppSizes.radiusLg),
            ))),
          ],
        ),
      ),
    );
  }
}

// ── Shop grid shimmer ─────────────────────────────────────────
class ShimmerGridLoader extends StatelessWidget {
  const ShimmerGridLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      GridView.builder(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          mainAxisSpacing:  AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            radius: AppSizes.radiusLg),
      ),
    );
  }
}

// ── List shimmer ──────────────────────────────────────────────
class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      ListView.separated(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSizes.md),
        itemBuilder: (_, __) => _ShimmerBox(
            width: double.infinity,
            height: 100,
            radius: AppSizes.radiusLg),
      ),
    );
  }
}
