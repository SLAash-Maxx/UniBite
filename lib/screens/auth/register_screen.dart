import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      studentId: _studentIdCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 0,
              AppSizes.screenPadding, AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Account', style: AppTextStyles.h1),
              const SizedBox(height: AppSizes.xs),
              Text('Join UniBite and start ordering',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.xl),
              CustomTextField(
                  controller: _nameCtrl,
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  validator: AppValidators.fullName,
                  prefixIcon: Icons.person_outline),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                  controller: _studentIdCtrl,
                  label: AppStrings.studentId,
                  hint: 'e.g. 2021CS001',
                  validator: AppValidators.studentId,
                  prefixIcon: Icons.badge_outlined),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                  controller: _emailCtrl,
                  label: AppStrings.email,
                  hint: 'Enter your university email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                  prefixIcon: Icons.email_outlined),
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _passCtrl,
                label: AppStrings.password,
                hint: 'Create a password',
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
              const SizedBox(height: AppSizes.xl),
              CustomButton(
                  label: AppStrings.signUp,
                  onPressed: _submit,
                  isLoading: auth.isLoading),
              const SizedBox(height: AppSizes.lg),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(AppStrings.hasAccount,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(AppStrings.signIn,
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
