import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/food_quantity_control.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Dismissible(
      key: Key(item.foodItem.id),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(),
      onDismissed: (_) => cart.removeAll(item.foodItem),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Food image
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusMd),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.foodItem.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.foodItem.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _Placeholder(),
                        errorWidget: (_, __, ___) => _Placeholder(),
                      )
                    : _Placeholder(),
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodItem.name,
                    style: AppTextStyles.labelLg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatPriceShort(item.foodItem.price),
                    style: AppTextStyles.priceSm,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.sm),

            // Qty control + subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FoodQuantityControl(
                  quantity: item.quantity,
                  size: ControlSize.medium,
                  onIncrement: () => cart.add(item.foodItem),
                  onDecrement: () => cart.remove(item.foodItem),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.formatPriceShort(item.subtotal),
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: const Icon(Icons.delete_outline_rounded,
          color: AppColors.error, size: AppSizes.iconLg),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.surfaceGrey,
        child: const Center(
          child: Icon(Icons.fastfood_outlined,
              color: AppColors.textHint, size: 28),
        ),
      );
}
