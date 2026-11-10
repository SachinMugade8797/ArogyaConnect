import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arogyanexus_app/main.dart';
import 'package:arogyanexus_app/screens/auth/login_screen.dart';
import 'package:arogyanexus_app/screens/doctor/doctor_navigation_screen.dart';
import 'package:arogyanexus_app/screens/main_navigation_screen.dart';
import 'package:arogyanexus_app/providers/auth_provider.dart';
import 'package:arogyanexus_app/models/user_model.dart';

void main() {
  testWidgets('App displays LoginScreen directly on launch when unauthenticated', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        // Provide unauthenticated initial state without async loading hang in test
        authProvider.overrideWith((ref) => _MockAuthNotifier(const AuthState(isLoading: false))),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ArogyaNexusApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Role-Based Login'), findsOneWidget);
    expect(find.text('Direct 1-Tap Login by Role'), findsOneWidget);
  });

  testWidgets('Doctor direct login redirects to Doctor Dashboard / DoctorNavigationScreen', (WidgetTester tester) async {
    final notifier = _MockAuthNotifier(const AuthState(isLoading: false));
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => notifier),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ArogyaNexusApp(),
      ),
    );
    await tester.pump();

    // Verify initially on LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Trigger Doctor direct login
    await notifier.loginDirectlyWithRole('doctor');
    await tester.pump();

    // Verify redirected to DoctorNavigationScreen
    expect(find.byType(DoctorNavigationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('User direct login redirects to Home Screen / MainNavigationScreen', (WidgetTester tester) async {
    final notifier = _MockAuthNotifier(const AuthState(isLoading: false));
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => notifier),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ArogyaNexusApp(),
      ),
    );
    await tester.pump();

    // Verify initially on LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Trigger Patient/User direct login
    await notifier.loginDirectlyWithRole('patient');
    await tester.pump();

    // Verify redirected to MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier(AuthState initial) : super() {
    state = initial;
  }

  @override
  Future<bool> loginDirectlyWithRole(String role) async {
    final mockUser = UserModel(
      id: role == 'doctor' ? 'mock-doc' : 'mock-patient',
      fullName: role == 'doctor' ? 'Dr. Aditi Deshmukh' : 'Sachin Shinde',
      email: role == 'doctor' ? 'doctor@arogyanexus.com' : 'patient@arogyanexus.com',
      role: role,
    );
    state = state.copyWith(user: mockUser, isLoading: false, error: null);
    return true;
  }
}
