import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';
import '../../models/canteen_model.dart';
import '../../models/food_item_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../shop/widgets/food_grid_card.dart';
import '../shop/widgets/filter_chips.dart';

class CanteenDetailScreen extends StatefulWidget {
  final String canteenId;
  const CanteenDetailScreen({super.key, required this.canteenId});
  @override
  State<CanteenDetailScreen> createState() => _CanteenDetailScreenState();
}

class _CanteenDetailScreenState extends State<CanteenDetailScreen> {
  CanteenModel? _canteen;
  List<FoodItemModel> _items = [];
  bool _loading = true;
  String? _selectedCategory;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final food = context.read<FoodProvider>();
    // Find canteen
    CanteenModel? canteen;
    try { canteen = food.canteens.firstWhere((c) => c.id == widget.canteenId); } catch (_) {}
    // Get items for this canteen
    final all = [...food.featuredItems, ...food.popularItems, ...food.filteredItems,
      ...food.itemsByCanteen.values.expand((e) => e)];
    final seen = <String>{};
    final items = all.where((f) {
      if (f.canteenId != widget.canteenId) return false;
      return seen.add(f.id);
    }).toList();
    setState(() { _canteen = canteen; _items = items; _loading = false; });
  }

  List<FoodItemModel> get _filtered {
    if (_selectedCategory == null || _selectedCategory == '0') return _items;
    return _items.where((f) => f.categoryId == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final food       = context.watch<FoodProvider>();
    final canteen    = _canteen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          title: Text(canteen?.name ?? 'Canteen', style: AppTextStyles.h3),
          actions: [
            if (canteen != null)
              Container(
                margin: const EdgeInsets.only(right: AppSizes.md),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: canteen.isOpen ? AppColors.successSoft : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(canteen.isOpen ? 'Open' : 'Closed',
                    style: AppTextStyles.labelSm.copyWith(
                        color: canteen.isOpen ? AppColors.success : AppColors.error)),
              ),
          ],
        ),

        // Canteen info
        if (canteen != null)
          SliverToBoxAdapter(child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(canteen.location, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(canteen.hours, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: AppSizes.md),
                const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 2),
                Text(canteen.rating.toStringAsFixed(1), style: AppTextStyles.labelMd),
              ]),
            ]),
          )),

        // Category filter
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.only(top: AppSizes.md),
          child: ShopFilterChips(
            categories: food.categories,
            selected: _selectedCategory,
            onSelect: (id) => setState(() => _selectedCategory = id),
          ),
        )),

        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),

        // Items count
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
          child: Text('${_filtered.length} items', style: AppTextStyles.bodySm),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

        // Grid
        _filtered.isEmpty
            ? const SliverFillRemaining(child: Center(child: Text('No items available')))
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding, 0,
                    AppSizes.screenPadding, AppSizes.xl),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FoodGridCard(item: _filtered[i]),
                    childCount: _filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: AppSizes.md,
                    crossAxisSpacing: AppSizes.md, childAspectRatio: 0.75,
                  ),
                ),
              ),
      ]),
    );
  }
}
