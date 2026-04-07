import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/food_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_widget.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_chips.dart';
import 'widgets/food_grid_card.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/search_not_found.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadShop();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => SortBottomSheet(
        current: context.read<FoodProvider>().sortOption,
        onSelect: (opt) {
          context.read<FoodProvider>().setSortOption(opt);
          Navigator.pop(context);
        },
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
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.screenPadding),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(AppStrings.sortBy,
                      style: AppTextStyles.labelSm),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding, AppSizes.sm,
                AppSizes.screenPadding, 0),
            child: FoodSearchBar(
              controller: _searchCtrl,
              onChanged: food.search,
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.md),
            child: ShopFilterChips(
              categories: food.categories,
              selected: food.selectedCategoryId,
              onSelect: food.selectCategory,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Results count
          if (!food.isLoading && !food.hasError)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${food.filteredItems.length} items found',
                  style: AppTextStyles.bodySm,
                ),
              ),
            ),

          const SizedBox(height: AppSizes.sm),

          // Content
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
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSizes.screenPadding, 0,
                                  AppSizes.screenPadding, AppSizes.xl),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSizes.md,
                                crossAxisSpacing: AppSizes.md,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: food.filteredItems.length,
                              itemBuilder: (_, i) => FoodGridCard(
                                item: food.filteredItems[i],
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
