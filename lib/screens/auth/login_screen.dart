import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
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
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? AppStrings.error),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xxl),

                // Header
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSizes.xs),
                Text('Welcome back! Sign in to continue.',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSizes.xl),

                // Email
                CustomTextField(
                  controller: _emailCtrl,
                  label: AppStrings.email,
                  hint: 'Enter your university email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: AppSizes.md),

                // Password
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

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(AppStrings.forgotPassword,
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Login button
                CustomButton(
                  label: AppStrings.signIn,
                  onPressed: _submit,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: AppSizes.lg),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount,
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go(RouteNames.register),
                      child: Text(AppStrings.signUp,
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
