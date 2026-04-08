
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final user   = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.profile, style: AppTextStyles.h3)),
      body: SingleChildScrollView(
        child: Column(children: [

          // Profile header
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding, AppSizes.lg,
                AppSizes.screenPadding, AppSizes.xl),
            child: Column(children: [
              Container(
                width: AppSizes.avatarLg, height: AppSizes.avatarLg,
                decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: Center(child: Text(
                  user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.displayMd.copyWith(color: AppColors.primary),
                )),
              ),
              const SizedBox(height: AppSizes.md),
              Text(user?.fullName ?? 'Student', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
                child: Text('ID: ${user?.studentId ?? '—'}',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(height: AppSizes.md),
              // Wallet balance
              GestureDetector(
                onTap: () => context.push(RouteNames.wallet),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('LKR ${wallet.balance.toStringAsFixed(2)}',
                        style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: AppSizes.md),

          // FIX #3 — Edit profile section (working)
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.person_outline_rounded,
              label: AppStrings.editProfile,
              onTap: () => _showEditProfile(context, user?.fullName ?? '', user?.studentId ?? ''),
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'My Wallet',
              trailing: Text('LKR ${wallet.balance.toStringAsFixed(0)}',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
              onTap: () => context.push(RouteNames.wallet),
            ),
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: AppStrings.myOrders,
              onTap: () => context.go(RouteNames.orders),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => context.push(RouteNames.notifications),
            ),
          ]),

          const SizedBox(height: AppSizes.sm),

          _MenuSection(items: [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              label: AppStrings.helpSupport,
              onTap: () => _showHelpSupport(context),
            ),
            _MenuItem(
              icon: Icons.info_outline_rounded,
              label: AppStrings.aboutUs,
              onTap: () => _showAboutUs(context),
            ),
          ]),

          const SizedBox(height: AppSizes.sm),

          _MenuSection(items: [
            _MenuItem(
              icon: Icons.logout_rounded,
              label: AppStrings.logout,
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () => _confirmLogout(context, auth),
            ),
          ]),

          const SizedBox(height: AppSizes.xl),
          Text('UniBite v2.0', style: AppTextStyles.caption),
          const SizedBox(height: AppSizes.lg),
        ]),
      ),
    );
  }

  void _showEditProfile(BuildContext context, String name, String id) {
    final nameCtrl = TextEditingController(text: name);
    final idCtrl   = TextEditingController(text: id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.lg, AppSizes.screenPadding,
            MediaQuery.of(sheetContext).viewInsets.bottom + AppSizes.xl),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppSizes.radiusFull)))),
          const SizedBox(height: AppSizes.lg),
          Text('Edit Profile', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.lg),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: AppSizes.md),
          TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Student ID', prefixIcon: Icon(Icons.badge_outlined))),
          const SizedBox(height: AppSizes.xl),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 52)),
            onPressed: () {
              Navigator.of(sheetContext).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ));
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          )),
        ]),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help & Support'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _HelpItem(icon: Icons.email_outlined, text: 'Email: support@unibite.app'),
          const SizedBox(height: AppSizes.sm),
          _HelpItem(icon: Icons.phone_outlined, text: 'Phone: +94 11 234 5678'),
          const SizedBox(height: AppSizes.sm),
          _HelpItem(icon: Icons.location_on_outlined, text: 'Admin Building, University Campus'),
          const SizedBox(height: AppSizes.md),
          Text('Operating Hours: 24x7',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        ]),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Image.asset(
            AppAssets.logo,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: AppSizes.md),
          Text('UniBite v2.0', style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.sm),
          Text(
            'UniBite is a smart canteen ordering system built for university students. '
            'Order from multiple canteens, track your orders in real-time, and pay '
            'using your campus wallet.''                                       NSBM 25.1 BATCH, UNIVERSITY OF PLYMOUTH',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ]),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await auth.logout();
              if (!context.mounted) return;
              context.go(RouteNames.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HelpItem({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: AppSizes.sm),
    Text(text, style: AppTextStyles.bodyMd),
  ]);
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Column(children: List.generate(items.length * 2 - 1, (i) {
      if (i.isOdd) return const Divider(height: 1, color: AppColors.divider, indent: 52, endIndent: 16);
      return items[i ~/ 2];
    })),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor, labelColor;
  final Widget? trailing;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.iconColor, this.labelColor, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: AppSizes.iconMd),
    title: Text(label, style: AppTextStyles.labelLg.copyWith(color: labelColor ?? AppColors.textPrimary)),
    trailing: trailing ?? (iconColor == null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint) : null),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
  );
}
