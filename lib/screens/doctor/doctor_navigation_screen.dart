import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_patient_records_screen.dart';

class DoctorNavigationScreen extends StatefulWidget {
  const DoctorNavigationScreen({super.key});

  @override
  State<DoctorNavigationScreen> createState() => _DoctorNavigationScreenState();
}

class _DoctorNavigationScreenState extends State<DoctorNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DoctorDashboardScreen(),
      const _DoctorPatientSearchScreen(),
      const _DoctorSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate200, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary700,
          unselectedItemColor: AppColors.slate400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Patient Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_shared_outlined),
              activeIcon: Icon(Icons.folder_shared_rounded),
              label: 'Patient Dossiers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Doctor Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorPatientSearchScreen extends StatelessWidget {
  const _DoctorPatientSearchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('Patient Dossier Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search patient by name or phone...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Recent Clinic Patients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slate900)),
          const SizedBox(height: 8),

          _PatientSearchCard(
            name: 'Sachin Shinde',
            details: 'Male • 34 yrs • Blood Group: B+',
            allergies: 'Penicillin',
            condition: 'Stage 1 Hypertension',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorPatientRecordsScreen(profileId: 'profile-self'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _PatientSearchCard(
            name: 'Sunita Shinde',
            details: 'Female • 32 yrs • Blood Group: O+',
            allergies: 'Dust',
            condition: 'None',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorPatientRecordsScreen(profileId: 'profile-spouse'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PatientSearchCard extends StatelessWidget {
  final String name;
  final String details;
  final String allergies;
  final String condition;
  final VoidCallback onTap;

  const _PatientSearchCard({
    required this.name,
    required this.details,
    required this.allergies,
    required this.condition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary100,
              child: Text(
                name[0],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary800),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slate900)),
                  Text(details, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                        child: Text('Allergies: $allergies', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(4)),
                        child: Text(condition, style: const TextStyle(fontSize: 10, color: AppColors.slate700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}

class _DoctorSettingsScreen extends ConsumerWidget {
  const _DoctorSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('Doctor Profile & Clinic Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary100,
                  child: const Icon(Icons.person, size: 40, color: AppColors.primary700),
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? 'Dr. Aditi Deshmukh', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.email ?? 'doctor@arogyanexus.com', style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Speciality: Cardiologist • HeartCare Clinic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Role Switcher & Sign Out
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary700),
                  title: const Text('Switch to Patient Portal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Test the app from patient perspective', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ref.read(authProvider.notifier).switchDemoRole('patient');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.errorRed)),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
