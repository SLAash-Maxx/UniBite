import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/food_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/food_quantity_control.dart';

class FoodGridCard extends StatelessWidget {
  final FoodItemModel item;

  const FoodGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty  = cart.quantityOf(item.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusLg)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _Placeholder(),
                            errorWidget: (_, __, ___) => _Placeholder(),
                          )
                        : _Placeholder(),
                  ),
                ),
                // Popular badge
                if (item.isPopular)
                  Positioned(
                    top: AppSizes.sm,
                    left: AppSizes.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '🔥 Popular',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: AppTextStyles.labelLg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 12),
                      const SizedBox(width: 2),
                      Text(item.ratingLabel,
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      Text('· ${item.prepTimeLabel}',
                          style: AppTextStyles.caption),
                    ],
                  ),

                  // Price + add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppFormatters.formatPriceShort(item.price),
                        style: AppTextStyles.priceSm,
                      ),
                      qty == 0
                          ? _AddButton(
                              onTap: () =>
                                  context.read<CartProvider>().add(item),
                            )
                          : FoodQuantityControl(
                              quantity: qty,
                              size: ControlSize.small,
                              onIncrement: () =>
                                  context.read<CartProvider>().add(item),
                              onDecrement: () =>
                                  context.read<CartProvider>().remove(item),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.surfaceGrey,
        child: const Center(
          child: Icon(Icons.fastfood_outlined,
              color: AppColors.textHint, size: 32),
        ),
      );
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: const Icon(Icons.add,
            color: AppColors.textOnPrimary, size: 18),
      ),
    );
  }
}
