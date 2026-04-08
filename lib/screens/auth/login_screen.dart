import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.read<WalletProvider>().loadWallet();
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? AppStrings.error),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter your email and we\'ll send a reset link.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              final ok = await auth.sendPasswordReset(ctrl.text.trim());
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? '✅ Reset link sent! Check your email.'
                    : auth.errorMessage ?? 'Failed to send.'),
                backgroundColor: ok ? AppColors.success : AppColors.error,
              ));
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: AppSizes.xxl),
              Center(
                child: Image.asset(
                  AppAssets.logo,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Welcome back! Sign in to continue.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.xl),
              CustomTextField(
                controller: _emailCtrl,
                label: AppStrings.email,
                hint: 'Enter your university email',
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.email,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _passCtrl,
                label: AppStrings.password,
                hint: 'Enter your password',
                obscureText: _obscure,
                validator: AppValidators.password,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: Text(AppStrings.forgotPassword,
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              CustomButton(
                  label: AppStrings.signIn,
                  onPressed: _submit,
                  isLoading: auth.isLoading),
              const SizedBox(height: AppSizes.lg),
              // FIX #13 — context.push keeps back button working
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(AppStrings.noAccount,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () => context.push(RouteNames.register),
                  child: Text(AppStrings.signUp,
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.primary)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
