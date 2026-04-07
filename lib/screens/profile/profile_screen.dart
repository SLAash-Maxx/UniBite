import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profile, style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.lg,
                  AppSizes.screenPadding,
                  AppSizes.xl),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: AppSizes.avatarLg,
                    height: AppSizes.avatarLg,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ??
                            'U',
                        style: AppTextStyles.displayMd
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(user?.fullName ?? 'Student',
                      style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      'ID: ${user?.studentId ?? '—'}',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // Menu sections
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.editProfile,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: AppStrings.myOrders,
                  onTap: () => context.go(RouteNames.orders),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.sm),

            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: AppStrings.settings,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: AppStrings.helpSupport,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.aboutUs,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSizes.sm),

            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: AppStrings.logout,
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(
                height: 1, color: AppColors.divider,
                indent: 52, endIndent: 16);
          }
          return items[i ~/ 2];
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor ?? AppColors.textSecondary,
          size: AppSizes.iconMd),
      title: Text(label,
          style: AppTextStyles.labelLg
              .copyWith(color: labelColor ?? AppColors.textPrimary)),
      trailing: iconColor == null
          ? const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs),
    );
  }
}
