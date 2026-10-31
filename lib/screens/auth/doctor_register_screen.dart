import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  ConsumerState<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _registrationController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _feeController = TextEditingController(text: '600');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedSpeciality = 'General Medicine';
  bool _obscurePassword = true;
  String? _localError;

  static const List<String> specialities = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Gynecology & Obstetrics',
    'Oncology',
    'Endocrinology',
    'Pulmonology',
    'Ophthalmology'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _registrationController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _feeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Doctor Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join ArogyaNexus Provider Network',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage patient consultations, digital health records, and AI-assisted diagnoses in clinic or on the move.',
                style: TextStyle(fontSize: 13, color: AppColors.slate600),
              ),
              const SizedBox(height: 20),

              if (_localError != null || authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Text(
                    _localError ?? authState.error!,
                    style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),

              // Full Name
              const Text('Full Professional Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Dr. Rajesh Patil',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Medical Speciality Dropdown
              const Text('Medical Speciality', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedSpeciality,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
                items: specialities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSpeciality = val);
                },
              ),
              const SizedBox(height: 14),

              // Registration License Number
              const Text('Medical Council / License Registration #', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _registrationController,
                decoration: InputDecoration(
                  hintText: 'e.g. MCI-2016-92841',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Clinic Name
              const Text('Hospital / Clinic Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _clinicNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Patil Healthcare Clinic',
                  prefixIcon: const Icon(Icons.local_hospital_outlined, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Clinic Address
              const Text('Clinic Address & City', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _clinicAddressController,
                decoration: InputDecoration(
                  hintText: 'e.g. FC Road, Shivaji Nagar, Pune',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Consultation Fee
              const Text('Standard Consultation Fee (₹ INR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _feeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 600',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Email
              const Text('Professional Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. doctor@hospital.com',
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Phone
              const Text('Contact Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +91 98222 00202',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Password
              const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Minimum 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.slate400, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 14),

              // Confirm Password
              const Text('Confirm Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Re-enter password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.slate400, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.slate50,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
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
                          setState(() => _localError = null);
                          if (_nameController.text.trim().isEmpty) {
                            setState(() => _localError = 'Please enter your professional name.');
                            return;
                          }
                          if (_registrationController.text.trim().isEmpty) {
                            setState(() => _localError = 'Please enter your medical license number.');
                            return;
                          }
                          if (_clinicNameController.text.trim().isEmpty) {
                            setState(() => _localError = 'Please enter your clinic/hospital name.');
                            return;
                          }
                          if (_passwordController.text.length < 6) {
                            setState(() => _localError = 'Password must be at least 6 characters.');
                            return;
                          }
                          if (_passwordController.text != _confirmPasswordController.text) {
                            setState(() => _localError = 'Passwords do not match.');
                            return;
                          }

                          final fee = double.tryParse(_feeController.text.trim()) ?? 600.0;

                          final navigator = Navigator.of(context);
                          final success = await ref.read(authProvider.notifier).registerDoctor(
                                fullName: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                speciality: _selectedSpeciality,
                                registrationNumber: _registrationController.text,
                                clinicName: _clinicNameController.text,
                                clinicAddress: _clinicAddressController.text,
                                consultationFee: fee,
                                password: _passwordController.text,
                              );

                          if (success && mounted) {
                            navigator.popUntil((r) => r.isFirst);
                          }
                        },
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Complete Doctor Onboarding', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: 'doctor')),
                    );
                  },
                  child: const Text(
                    'Already have a doctor account? Sign In',
                    style: TextStyle(color: AppColors.primary700, fontWeight: FontWeight.bold, fontSize: 13),
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
