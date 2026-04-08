import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/food_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/food_quantity_control.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  const FoodDetailScreen({super.key, required this.foodId});
  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  FoodItemModel? _item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // First check provider cache
    final food = context.read<FoodProvider>();
    FoodItemModel? found;
    try {
      found = [...food.featuredItems, ...food.popularItems, ...food.filteredItems]
          .firstWhere((f) => f.id == widget.foodId);
    } catch (_) {}
    if (found == null) {
      // Fetch from Firestore
      final svc = food.itemsByCanteen.values.expand((e) => e);
      try { found = svc.firstWhere((f) => f.id == widget.foodId); } catch (_) {}
    }
    setState(() { _item = found; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }

    final item = _item!;
    final qty  = cart.quantityOf(item.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // Image header
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _Placeholder(),
                  )
                : _Placeholder(),
          ),
        ),

        SliverToBoxAdapter(child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Name + price
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(item.name, style: AppTextStyles.h2)),
                Text(AppFormatters.formatPriceShort(item.price), style: AppTextStyles.price),
              ]),
              const SizedBox(height: AppSizes.sm),

              // Rating + prep time
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(item.ratingLabel, style: AppTextStyles.labelMd),
                Text(' (${item.reviewCount} reviews)', style: AppTextStyles.bodySm),
                const SizedBox(width: AppSizes.md),
                const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(item.prepTimeLabel, style: AppTextStyles.bodySm),
              ]),
              const SizedBox(height: AppSizes.lg),

              // Availability badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isAvailable ? AppColors.successSoft : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  item.isAvailable ? '✓ Available' : '✗ Unavailable',
                  style: AppTextStyles.labelSm.copyWith(
                      color: item.isAvailable ? AppColors.success : AppColors.error),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Description
              Text('Description', style: AppTextStyles.h4),
              const SizedBox(height: AppSizes.sm),
              Text(item.description, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.6)),
              const SizedBox(height: AppSizes.lg),

              // Tags
              if (item.tags.isNotEmpty) ...[
                Text('Tags', style: AppTextStyles.h4),
                const SizedBox(height: AppSizes.sm),
                Wrap(spacing: AppSizes.sm, children: item.tags.map((t) => Chip(
                  label: Text(t, style: AppTextStyles.labelSm),
                  backgroundColor: AppColors.surfaceGrey,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                )).toList()),
                const SizedBox(height: AppSizes.lg),
              ],

              const SizedBox(height: 80),
            ]),
          ),
        )),
      ]),

      // Bottom add to cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding, AppSizes.md,
            AppSizes.screenPadding, AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: item.isAvailable
            ? (qty == 0
                ? CustomButton(
                    label: 'Add to Cart — ${AppFormatters.formatPriceShort(item.price)}',
                    onPressed: () {
                      // Check canteen mismatch
                      if (!cart.canAddFromCanteen(item.canteenId)) {
                        _showMixedCanteenDialog(context, cart, item);
                        return;
                      }
                      context.read<CartProvider>().add(item);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Added to cart!'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 1),
                      ));
                    },
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('In Cart', style: AppTextStyles.h4),
                    FoodQuantityControl(
                      quantity: qty, size: ControlSize.medium,
                      onIncrement: () => context.read<CartProvider>().add(item),
                      onDecrement: () => context.read<CartProvider>().remove(item),
                    ),
                  ]))
            : CustomButton(label: 'Not Available', onPressed: null),
      ),
    );
  }

  void _showMixedCanteenDialog(BuildContext context, CartProvider cart, FoodItemModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Different Canteen'),
        content: Text(
            'Your cart has items from ${cart.canteenName}. Clear cart and add this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              cart.clear();
              cart.add(item);
              Navigator.pop(context);
            },
            child: const Text('Clear & Add', style: TextStyle(color: Colors.white)),
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
    child: const Center(child: Icon(Icons.fastfood_outlined, color: AppColors.textHint, size: 64)),
  );
}
