import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_scope.dart';
import '../../widgets/baghbani_logo.dart';
import '../../widgets/primary_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final user = UserProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
      isGuest: false,
    );
    await AuthScope.of(context).register(user, _password.text);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            children: [
              const BaghbaniLogo(size: 42),
              const SizedBox(height: 18),
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join the Baghbani growing ecosystem',
                style: TextStyle(color: AppColors.muted, fontSize: 14.5),
              ),
              const SizedBox(height: 24),
              _field(
                controller: _name,
                label: 'Full name',
                hint: 'e.g. Faizan Umar',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _email,
                label: 'Email address',
                hint: 'name@example.com',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
                validateEmail: true,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _password,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _phone,
                label: 'Phone number',
                hint: '0300 1234567',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _location,
                label: 'City or location',
                hint: 'e.g. Lahore, Punjab',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Create account',
                busy: auth.isLoading,
                onPressed: auth.isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    bool validateEmail = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.muted),
      suffixIcon: suffix,
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter your $label';
      }
      if (validateEmail && (!value.contains('@') || !value.contains('.'))) {
        return 'Enter a valid email address';
      }
      if (obscure && value.length < 6) {
        return 'Use at least 6 characters';
      }
      return null;
    },
  );
}
