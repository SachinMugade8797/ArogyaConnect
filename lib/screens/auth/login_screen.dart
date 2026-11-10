import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'patient_register_screen.dart';
import 'doctor_register_screen.dart';
import 'onboarding_screen.dart';
import '../doctor/doctor_navigation_screen.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String initialRole;

  const LoginScreen({super.key, this.initialRole = 'patient'});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late String _selectedRole; // 'doctor' or 'patient'
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isDirectLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _fillDefaultDemo(_selectedRole);
  }

  void _fillDefaultDemo(String role) {
    if (role == 'doctor') {
      _emailController.text = 'doctor@arogyanexus.com';
      _passwordController.text = 'doctor123';
    } else {
      _emailController.text = 'patient@arogyanexus.com';
      _passwordController.text = 'patient123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Direct 1-tap role-based login
  Future<void> _handleDirectRoleLogin(String role) async {
    setState(() {
      _selectedRole = role;
      _fillDefaultDemo(role);
      _isDirectLoggingIn = true;
    });

    final success = await ref.read(authProvider.notifier).loginDirectlyWithRole(role);

    if (mounted) {
      setState(() => _isDirectLoggingIn = false);
      if (success) {
        _showSuccessFeedback(role);
        // Ensure imperative route clearance if login screen was pushed
        if (Navigator.canPop(context)) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => role == 'doctor'
                  ? const DoctorNavigationScreen()
                  : const MainNavigationScreen(),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  /// Credential form submit login
  Future<void> _handleCredentialLogin() async {
    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (mounted && success) {
      _showSuccessFeedback(_selectedRole);
      if (Navigator.canPop(context)) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => _selectedRole == 'doctor'
                ? const DoctorNavigationScreen()
                : const MainNavigationScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  void _showSuccessFeedback(String role) {
    final isDoc = role == 'doctor';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDoc ? Icons.medical_services_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isDoc
                    ? 'Logged in as Doctor! Redirecting to Doctor Dashboard...'
                    : 'Logged in as User! Redirecting to Home Screen...',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: isDoc ? AppColors.primary700 : AppColors.accent600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDoctor = _selectedRole == 'doctor';
    final activeThemeColor = isDoctor ? AppColors.primary600 : AppColors.accent600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary600, AppColors.accent600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary600.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ArogyaNexus',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Healthcare Management Platform',
                            style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate500),
                    label: const Text(
                      'App Tour',
                      style: TextStyle(fontSize: 12, color: AppColors.slate600, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activeThemeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDoctor ? Icons.verified_user_rounded : Icons.person_pin_rounded,
                      size: 14,
                      color: activeThemeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Direct Role Authentication',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activeThemeColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Role-Based Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your portal role below to sign in directly. Doctor redirects to Doctor Dashboard; User/Patient redirects to Home Screen.',
                style: TextStyle(fontSize: 13, color: AppColors.slate600, height: 1.4),
              ),
              const SizedBox(height: 20),

              // SECTION 1: INSTANT DIRECT ROLE LOGIN CARDS
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.warningOrange, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'Direct 1-Tap Login by Role',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'FAST ACCESS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Direct Login Buttons Row
                    Row(
                      children: [
                        // Direct Doctor Button
                        Expanded(
                          child: _DirectRoleCard(
                            title: 'Doctor',
                            destination: 'Doctor Dashboard',
                            icon: Icons.medical_services_rounded,
                            color: AppColors.primary600,
                            badgeText: 'Physician',
                            isLoading: _isDirectLoggingIn && _selectedRole == 'doctor',
                            onTap: () => _handleDirectRoleLogin('doctor'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Direct Patient/User Button
                        Expanded(
                          child: _DirectRoleCard(
                            title: 'User / Patient',
                            destination: 'Home Screen',
                            icon: Icons.person_rounded,
                            color: AppColors.accent600,
                            badgeText: 'Patient',
                            isLoading: _isDirectLoggingIn && _selectedRole == 'patient',
                            onTap: () => _handleDirectRoleLogin('patient'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: ROLE SELECTOR TABS
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.slate200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR SIGN IN WITH CREDENTIALS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.slate200)),
                ],
              ),
              const SizedBox(height: 16),

              // Role Toggle Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _RoleTabButton(
                        title: 'Doctor Portal',
                        icon: Icons.medical_services_rounded,
                        isSelected: isDoctor,
                        activeColor: AppColors.primary700,
                        onTap: () {
                          setState(() {
                            _selectedRole = 'doctor';
                            _fillDefaultDemo('doctor');
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _RoleTabButton(
                        title: 'User / Patient',
                        icon: Icons.person_outline_rounded,
                        isSelected: !isDoctor,
                        activeColor: AppColors.accent600,
                        onTap: () {
                          setState(() {
                            _selectedRole = 'patient';
                            _fillDefaultDemo('patient');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Role Active Context Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDoctor ? AppColors.primary50 : AppColors.accent50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDoctor ? AppColors.primary200 : AppColors.accent200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDoctor ? Icons.local_hospital_rounded : Icons.shield_outlined,
                      size: 18,
                      color: isDoctor ? AppColors.primary700 : AppColors.accent700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDoctor
                                ? 'Target: Doctor Dashboard'
                                : 'Target: User Home Screen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDoctor ? AppColors.primary800 : AppColors.accent700,
                            ),
                          ),
                          Text(
                            isDoctor
                                ? 'Demo Account: Dr. Aditi Deshmukh (Cardiologist)'
                                : 'Demo Account: Sachin Shinde (Patient)',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDoctor ? AppColors.primary700 : AppColors.accent600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error banner if any
              if (authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Input Field
              const Text(
                'Email Address',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate800),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14, color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: isDoctor ? 'doctor@arogyanexus.com' : 'patient@arogyanexus.com',
                  hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
                  prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.slate50,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeThemeColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Password Input Field
              const Text(
                'Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate800),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 14, color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
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
                  filled: true,
                  fillColor: AppColors.slate50,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeThemeColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick Fill Action Chips
              Row(
                children: [
                  const Text('Quick Fill:', style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = 'doctor';
                        _fillDefaultDemo('doctor');
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary300),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flash_on_rounded, size: 12, color: AppColors.primary700),
                          SizedBox(width: 4),
                          Text('Doctor Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = 'patient';
                        _fillDefaultDemo('patient');
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flash_on_rounded, size: 12, color: AppColors.accent600),
                          SizedBox(width: 4),
                          Text('Patient Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Remember me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: activeThemeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember role',
                        style: TextStyle(fontSize: 12, color: AppColors.slate600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Demo Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          content: const Text(
                            'Doctor:\nEmail: doctor@arogyanexus.com\nPass: doctor123\n\nUser / Patient:\nEmail: patient@arogyanexus.com\nPass: patient123',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 12, color: activeThemeColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeThemeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                  onPressed: (authState.isLoading || _isDirectLoggingIn) ? null : _handleCredentialLogin,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isDoctor ? 'Sign In to Doctor Dashboard' : 'Sign In to Home Screen',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Redirection
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: AppColors.slate600)),
                    GestureDetector(
                      onTap: () {
                        if (isDoctor) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DoctorRegisterScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PatientRegisterScreen()),
                          );
                        }
                      },
                      child: Text(
                        isDoctor ? 'Register as Doctor' : 'Register as Patient',
                        style: TextStyle(
                          color: activeThemeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for 1-Tap Direct Login by Role
class _DirectRoleCard extends StatelessWidget {
  final String title;
  final String destination;
  final IconData icon;
  final Color color;
  final String badgeText;
  final bool isLoading;
  final VoidCallback onTap;

  const _DirectRoleCard({
    required this.title,
    required this.destination,
    required this.icon,
    required this.color,
    required this.badgeText,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.arrow_right_alt_rounded, size: 14, color: AppColors.slate500),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Direct Login',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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

/// Selector tab button for form role
class _RoleTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _RoleTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : AppColors.slate400,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
                color: isSelected ? AppColors.slate900 : AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
