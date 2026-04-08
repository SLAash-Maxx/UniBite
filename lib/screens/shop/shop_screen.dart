import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../models/canteen_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_widget.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_chips.dart';
import 'widgets/food_grid_card.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/search_not_found.dart';



  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl))),
      builder: (_) => SortBottomSheet(
        current: context.read<FoodProvider>().sortOption,
        onSelect: (opt) { context.read<FoodProvider>().setSortOption(opt); Navigator.pop(context); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.shop, style: AppTextStyles.h3),
        actions: [
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.screenPadding),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
              decoration: BoxDecoration(color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
              child: Row(children: [
                const Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(AppStrings.sortBy, style: AppTextStyles.labelSm),
              ]),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.sm, AppSizes.screenPadding, 0),
          child: FoodSearchBar(controller: _searchCtrl, onChanged: food.search),
        ),

        // FIX #8 — Canteen filter row
        if (food.canteens.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.sm, AppSizes.screenPadding, 0),
              children: [
                _CanteenChip(label: 'All', isSelected: food.selectedCanteen == null, onTap: () => food.selectCanteen(null)),
                ...food.canteens.map((c) => _CanteenChip(
                  label: c.name,
                  isSelected: food.selectedCanteen?.id == c.id,
                  onTap: () => food.selectCanteen(c),
                  isOpen: c.isOpen,
                )),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(top: AppSizes.sm),
          child: ShopFilterChips(categories: food.categories, selected: food.selectedCategoryId, onSelect: food.selectCategory),
        ),

        const SizedBox(height: AppSizes.sm),

        if (!food.isLoading && !food.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
            child: Align(alignment: Alignment.centerLeft,
              child: Text('${food.filteredItems.length} items found', style: AppTextStyles.bodySm)),
          ),

        const SizedBox(height: AppSizes.sm),

        Expanded(
          child: food.isLoading
              ? const ShimmerGridLoader()
              : food.hasError
                  ? ErrorStateWidget(onRetry: food.loadShop)
                  : food.filteredItems.isEmpty
                      ? SearchNotFound(query: food.searchQuery)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: food.loadShop,
                          child: food.searchQuery.isEmpty && food.selectedCanteen == null
                              // FIX #15 — Group by canteen when no filter
                              ? _GroupedView(food: food)
                              : _GridView(food: food),
                        ),
        ),
      ]),
    );
  }
}

class _GroupedView extends StatelessWidget {
  final FoodProvider food;
  const _GroupedView({required this.food});

  @override
  Widget build(BuildContext context) {
    final grouped = food.itemsByCanteen;
    if (grouped.isEmpty) return SearchNotFound(query: food.searchQuery);
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSizes.xl),
      children: grouped.entries.map((entry) {
        final canteen = entry.key;
        final items   = entry.value;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Canteen header
          GestureDetector(
            onTap: () => context.push('/canteen/${canteen.id}'),
            child: Container(
              margin: const EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.md, AppSizes.screenPadding, AppSizes.sm),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(canteen.name, style: AppTextStyles.h4),
                  Text(canteen.location, style: AppTextStyles.caption),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: canteen.isOpen ? AppColors.successSoft : AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(canteen.isOpen ? 'Open' : 'Closed',
                      style: AppTextStyles.labelSm.copyWith(
                          color: canteen.isOpen ? AppColors.success : AppColors.error)),
                ),
                const SizedBox(width: AppSizes.sm),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ]),
            ),
          ),
          // Items horizontal scroll
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
              itemCount: items.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (_, i) => SizedBox(
                width: 150,
                child: FoodGridCard(item: items[i]),
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }
}

class _GridView extends StatelessWidget {
  final FoodProvider food;
  const _GridView({required this.food});

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding, 0, AppSizes.screenPadding, AppSizes.xl),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, mainAxisSpacing: AppSizes.md,
      crossAxisSpacing: AppSizes.md, childAspectRatio: 0.75,
    ),
    itemCount: food.filteredItems.length,
    itemBuilder: (_, i) => FoodGridCard(item: food.filteredItems[i]),
  );
}

class _CanteenChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool? isOpen;
  final VoidCallback onTap;
  const _CanteenChip({required this.label, required this.isSelected, required this.onTap, this.isOpen});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(right: AppSizes.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isOpen != null) Container(
          width: 6, height: 6, margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: isOpen! ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: AppTextStyles.labelSm.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary)),
      ]),
    ),
  );
}
