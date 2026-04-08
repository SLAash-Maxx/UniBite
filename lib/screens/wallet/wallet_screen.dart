

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('My Wallet', style: AppTextStyles.h3)),
      body: wallet.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  ),
                  child: Column(children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 48),
                    const SizedBox(height: AppSizes.md),
                    Text('Available Balance', style: AppTextStyles.bodyMd.copyWith(color: Colors.white70)),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'LKR ${(wallet.wallet?.balance ?? 0).toStringAsFixed(2)}',
                      style: AppTextStyles.displayMd.copyWith(color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSizes.lg),

                // Top up info banner
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(child: Text(
                      'To top up your wallet, visit the Admin Building at the university. '
                      'Present your Student ID to the cashier.',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.info),
                    )),
                  ]),
                ),
                const SizedBox(height: AppSizes.lg),

                // Transactions
                Text('Transaction History', style: AppTextStyles.h4),
                const SizedBox(height: AppSizes.sm),
                if (wallet.wallet?.transactions.isEmpty ?? true)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Column(children: [
                      const Text('💳', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSizes.md),
                      Text('No transactions yet', style: AppTextStyles.h4),
                      Text('Your transaction history will appear here.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                    ]),
                  ))
                else
                  ...( wallet.wallet!.transactions.map((tx) => _TxTile(tx: tx))),
              ]),
            ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final WalletTransaction tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isCredit ? AppColors.successSoft : AppColors.errorSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isCredit ? AppColors.success : AppColors.error, size: 20,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.type.label, style: AppTextStyles.labelLg),
          Text(tx.note ?? '', style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(AppFormatters.formatDateTime(tx.createdAt), style: AppTextStyles.caption),
        ])),
        Text(
          '${isCredit ? '+' : '-'} LKR ${tx.amount.toStringAsFixed(2)}',
          style: AppTextStyles.labelLg.copyWith(
              color: isCredit ? AppColors.success : AppColors.error),
        ),
      ]),
    );
  }
}
