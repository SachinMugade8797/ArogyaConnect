import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'patient_register_screen.dart';
import 'doctor_register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String initialRole;

  const LoginScreen({super.key, this.initialRole = 'patient'});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late String _selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _fillDefaultDemo(_selectedRole);
  }

  void _fillDefaultDemo(String role) {
    if (role == 'patient') {
      _emailController.text = 'patient@arogyanexus.com';
      _passwordController.text = 'patient123';
    } else {
      _emailController.text = 'doctor@arogyanexus.com';
      _passwordController.text = 'doctor123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary700, size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to your ArogyaNexus account to access records, appointments and clinical tools.',
                style: TextStyle(fontSize: 13, color: AppColors.slate600),
              ),
              const SizedBox(height: 24),

              // Role Selector Toggle (Matches Web RoleSelector)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = 'patient';
                            _fillDefaultDemo('patient');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'patient' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedRole == 'patient'
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: _selectedRole == 'patient' ? AppColors.primary700 : AppColors.slate500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Patient Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _selectedRole == 'patient' ? AppColors.primary800 : AppColors.slate600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = 'doctor';
                            _fillDefaultDemo('doctor');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'doctor' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedRole == 'doctor'
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services_rounded,
                                size: 16,
                                color: _selectedRole == 'doctor' ? AppColors.primary700 : AppColors.slate500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Doctor Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _selectedRole == 'doctor' ? AppColors.primary800 : AppColors.slate600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Error banner if any
              if (authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Input
              const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. name@domain.com',
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.slate400, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.slate400,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Quick Demo Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary700),
                    label: const Text('Auto-fill Patient Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.primary50,
                    side: const BorderSide(color: AppColors.primary200),
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'patient';
                        _fillDefaultDemo('patient');
                      });
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.accent600),
                    label: const Text('Auto-fill Doctor Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.accent50,
                    side: const BorderSide(color: AppColors.accent500),
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'doctor';
                        _fillDefaultDemo('doctor');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final success = await ref.read(authProvider.notifier).login(
                                email: _emailController.text,
                                password: _passwordController.text,
                                role: _selectedRole,
                              );

                          if (success && mounted) {
                            navigator.popUntil((route) => route.isFirst);
                          }
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Sign In as ${_selectedRole == "doctor" ? "Doctor" : "Patient"}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Registration redirect
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: AppColors.slate600)),
                    GestureDetector(
                      onTap: () {
                        if (_selectedRole == 'patient') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PatientRegisterScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const DoctorRegisterScreen()),
                          );
                        }
                      },
                      child: Text(
                        'Register as ${_selectedRole == "doctor" ? "Doctor" : "Patient"}',
                        style: const TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
