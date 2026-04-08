import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/food_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/food_quantity_control.dart';

class PopularFoodTile extends StatelessWidget {
  final FoodItemModel item;
  const PopularFoodTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty  = cart.quantityOf(item.id);

    return GestureDetector(
      onTap: () => context.push('/food/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppSizes.radiusLg)),
            child: SizedBox(width: 90, height: 90,
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder())
                  : _Placeholder()),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(item.prepTimeLabel, style: AppTextStyles.caption),
                const SizedBox(width: AppSizes.sm),
                const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
                const SizedBox(width: 3),
                Text(item.ratingLabel, style: AppTextStyles.caption),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(AppFormatters.formatPriceShort(item.price), style: AppTextStyles.price),
                qty == 0
                    ? GestureDetector(
                        onTap: () => context.read<CartProvider>().add(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
                          child: Text('+ Add', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
                        ),
                      )
                    : FoodQuantityControl(
                        quantity: qty, size: ControlSize.small,
                        onIncrement: () => context.read<CartProvider>().add(item),
                        onDecrement: () => context.read<CartProvider>().remove(item),
                      ),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceGrey,
    child: const Center(child: Icon(Icons.fastfood_outlined, color: AppColors.textHint, size: 28)),
  );
}
