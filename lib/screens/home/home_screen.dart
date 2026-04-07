import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_widget.dart';
import 'widgets/greeting_header.dart';
import 'widgets/canteen_banner.dart';
import 'widgets/category_chips.dart';
import 'widgets/featured_food_card.dart';
import 'widgets/popular_food_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: food.isLoading
            ? const ShimmerHomeLoader()
            : food.hasError
                ? ErrorStateWidget(onRetry: () => food.loadHome())
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => food.loadHome(),
                    child: CustomScrollView(
                      slivers: [
                        // ── Greeting header ──────────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSizes.screenPadding,
                                AppSizes.md,
                                AppSizes.screenPadding,
                                0),
                            child: GreetingHeader(user: auth.currentUser),
                          ),
                        ),

                        // ── Banner ───────────────────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSizes.screenPadding,
                                AppSizes.md,
                                AppSizes.screenPadding,
                                0),
                            child: CanteenBanner(canteen: food.featuredCanteen),
                          ),
                        ),

                        // ── Categories ───────────────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSizes.lg),
                            child: CategoryChips(
                              categories: food.categories,
                              selected: food.selectedCategoryId,
                              onSelect: food.selectCategory,
                            ),
                          ),
                        ),

                        // ── Featured section title ────────────────────
                        SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: AppStrings.featured,
                            onSeeAll: () {},
                          ),
                        ),

                        // ── Featured horizontal scroll ────────────────
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: AppSizes.foodCardHeight,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.screenPadding),
                              itemCount: food.featuredItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppSizes.md),
                              itemBuilder: (_, i) => FeaturedFoodCard(
                                item: food.featuredItems[i],
                              ),
                            ),
                          ),
                        ),

                        // ── Popular section title ─────────────────────
                        SliverToBoxAdapter(
                          child: _SectionHeader(
                            title: AppStrings.popular,
                            onSeeAll: () {},
                          ),
                        ),

                        // ── Popular vertical list ─────────────────────
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSizes.screenPadding,
                              0,
                              AppSizes.screenPadding,
                              AppSizes.xl),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSizes.md),
                                child: PopularFoodTile(
                                    item: food.popularItems[i]),
                              ),
                              childCount: food.popularItems.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding, AppSizes.lg, AppSizes.screenPadding, AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h4),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              AppStrings.seeAll,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
