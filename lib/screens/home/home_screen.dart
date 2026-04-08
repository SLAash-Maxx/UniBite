import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../models/canteen_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_widget.dart';
import 'widgets/greeting_header.dart';
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
      context.read<WalletProvider>().loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final food   = context.watch<FoodProvider>();
    final auth   = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: food.isLoading
            ? const ShimmerHomeLoader()
            : food.hasError
                ? ErrorStateWidget(onRetry: food.loadHome)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: food.loadHome,
                    child: CustomScrollView(slivers: [

                        // NSBM logo
                      SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding, AppSizes.lg,
                            AppSizes.screenPadding, AppSizes.sm),
                        child: Center(
                          child: Image.asset(
                            AppAssets.nsbmLogo,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )),

                      // Greeting
                      SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding, AppSizes.md,
                            AppSizes.screenPadding, 0),
                        child: GreetingHeader(
                          user: auth.currentUser,
                          walletBalance: wallet.balance,
                        ),
                      )),

                      // Wallet balance card
                      SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding, AppSizes.md,
                            AppSizes.screenPadding, 0),
                        child: _WalletCard(balance: wallet.balance),
                      )),

                      // FIX #8 #15 — All canteens section
                      SliverToBoxAdapter(child: _SectionHeader(
                        title: 'Canteens',
                        onSeeAll: () => context.go(RouteNames.shop),
                      )),
                      SliverToBoxAdapter(child: SizedBox(
                        height: 160,
                        child: ClipRect(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.screenPadding),
                            itemCount: food.canteens.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSizes.md),
                            itemBuilder: (_, i) => _CanteenCard(
                              canteen: food.canteens[i],
                              onTap: () => context.push(
                                  '/canteen/${food.canteens[i].id}'),
                            ),
                          ),
                        ),
                      )),


                      // Featured
                      SliverToBoxAdapter(child: _SectionHeader(
                          title: AppStrings.featured, onSeeAll: () {})),
                      SliverToBoxAdapter(child: food.featuredItems.isEmpty
                          ? const _EmptySection(msg: 'No featured items yet')
                          : SizedBox(
                              height: AppSizes.foodCardHeight + 2,
                              child: ClipRect(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.screenPadding),
                                  itemCount: food.featuredItems.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: AppSizes.md),
                                  itemBuilder: (_, i) =>
                                      FeaturedFoodCard(item: food.featuredItems[i]),
                                ),
                              ),
                            )),

                      // Popular
                      SliverToBoxAdapter(child: _SectionHeader(
                          title: AppStrings.popular, onSeeAll: () {})),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding, 0,
                            AppSizes.screenPadding, AppSizes.xl),
                        sliver: food.popularItems.isEmpty
                            ? const SliverToBoxAdapter(
                                child: _EmptySection(msg: 'No popular items yet'))
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, i) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSizes.md),
                                    child: PopularFoodTile(
                                        item: food.popularItems[i]),
                                  ),
                                  childCount: food.popularItems.length,
                                ),
                              ),
                      ),
                    ]),
                  ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double balance;
  const _WalletCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.wallet),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 32),
          const SizedBox(width: AppSizes.md),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Wallet Balance',
                style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
            Text('LKR ${balance.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(color: Colors.white)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text('Top Up',
                style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}

class _CanteenCard extends StatelessWidget {
  final CanteenModel canteen;
  final VoidCallback onTap;
  const _CanteenCard({required this.canteen, required this.onTap});

  Color get _crowdColor {
    switch (canteen.crowdLevel) {
      case CrowdLevel.low:    return AppColors.success;
      case CrowdLevel.medium: return AppColors.warning;
      case CrowdLevel.high:   return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const Spacer(),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: canteen.isOpen ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ]),
          const SizedBox(height: AppSizes.sm),
          Text(canteen.name,
              style: AppTextStyles.labelLg,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(canteen.isOpen ? 'Open Now' : 'Closed',
              style: AppTextStyles.caption.copyWith(
                color: canteen.isOpen ? AppColors.success : AppColors.error)),
          const SizedBox(height: 4),
          // ── Crowd level indicator ──────────────────────────────────
          Row(children: [
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                color: _crowdColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text('${canteen.crowdLevel.label} crowd',
                style: AppTextStyles.caption.copyWith(
                    color: _crowdColor,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star_rounded,
                color: AppColors.warning, size: 12),
            const SizedBox(width: 2),
            Text(canteen.rating.toStringAsFixed(1),
                style: AppTextStyles.caption),
          ]),
        ]),
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
          AppSizes.screenPadding, AppSizes.lg,
          AppSizes.screenPadding, AppSizes.sm),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: AppTextStyles.h4),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(AppStrings.seeAll,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
        ),
      ]),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String msg;
  const _EmptySection({required this.msg});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.screenPadding, vertical: AppSizes.md),
    child: Text(msg,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
  );
}
