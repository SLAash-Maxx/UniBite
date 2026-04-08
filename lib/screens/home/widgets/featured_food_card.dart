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

class FeaturedFoodCard extends StatelessWidget {
  final FoodItemModel item;
  const FeaturedFoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty  = cart.quantityOf(item.id);

    return GestureDetector(
      onTap: () => context.push('/food/${item.id}'),
      child: Container(
        width: AppSizes.foodCardWidth,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
            child: SizedBox(height: AppSizes.foodImageHeight, width: double.infinity,
              child: item.imageUrl != null
                  ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover,
                      placeholder: (_, __) => _Placeholder(), errorWidget: (_, __, ___) => _Placeholder())
                  : _Placeholder()),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item.name, style: AppTextStyles.labelLg, maxLines: 2, overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                const SizedBox(width: 2),
                Text(item.ratingLabel, style: AppTextStyles.labelSm),
                const SizedBox(width: 4),
                Text('(${item.reviewCount})', style: AppTextStyles.caption),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(AppFormatters.formatPriceShort(item.price), style: AppTextStyles.priceSm),
                qty == 0
                    ? GestureDetector(
                        onTap: () => context.read<CartProvider>().add(item),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
                          child: const Icon(Icons.add, color: AppColors.textOnPrimary, size: 18),
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
    child: const Center(child: Icon(Icons.fastfood_outlined, color: AppColors.textHint, size: 36)),
  );
}
