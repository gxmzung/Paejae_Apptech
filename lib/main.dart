import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/app/root/root_screen.dart';

import 'package:apptech_flutter/features/timetable/data/timetable_repo.dart';
import 'package:apptech_flutter/features/timetable/presentation/timetable_screen.dart';
import 'package:apptech_flutter/features/timetable/presentation/full_timetable_quick_view_screen.dart';

import 'package:apptech_flutter/features/more/presentation/campus_guide_web_screen.dart';
import 'package:apptech_flutter/features/more/presentation/widget_settings_screen.dart';
import 'package:apptech_flutter/features/clubs/presentation/club_all_screen.dart';

import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/auth/screens/login_screen.dart';
import 'package:apptech_flutter/auth/screens/signup_screen.dart';
import 'package:apptech_flutter/auth/screens/student_profile_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runZonedGuarded(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      debugPrint('🧨 FlutterError: ${details.exception}');
      if (details.stack != null) {
        debugPrint(details.stack.toString());
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('🧨 PlatformError: $error');
      debugPrint(stack.toString());
      return true;
    };

    runApp(const App());
  }, (e, st) {
    debugPrint('🧨 ZoneError: $e');
    debugPrint(st.toString());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    _bindWidgetClicks();
  }

  Future<void> _bindWidgetClicks() async {
    if (kIsWeb) return;

    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleWidgetUri(uri);
    }

    _sub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        _handleWidgetUri(uri);
      }
    });
  }

  void _handleWidgetUri(Uri uri) {
    String path = uri.path;
    if (path.isEmpty) path = '/';
    if (!path.startsWith('/')) path = '/$path';

    if (path == FullTimetableQuickViewScreen.routeName) {
      navigatorKey.currentState?.pushNamed(
        FullTimetableQuickViewScreen.routeName,
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeTableRepo()..init()),
        ChangeNotifierProvider(create: (_) => AuthState()..boot()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: '배재Pick',
        theme: ThemeData(useMaterial3: true),
        home: const AuthGate(),
        routes: {
          RootScreen.routeName: (_) => const RootScreen(),
          TimeTableScreen.routeName: (_) => const TimeTableScreen(),
          FullTimetableQuickViewScreen.routeName: (_) =>
          const FullTimetableQuickViewScreen(),
          CampusGuideWebScreen.routeName: (_) => const CampusGuideWebScreen(),
          WidgetSettingsScreen.routeName: (_) => const WidgetSettingsScreen(),
          ClubAllScreen.routeName: (_) => const ClubAllScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignupScreen.routeName: (_) => const SignupScreen(),
          StudentProfileScreen.routeName: (_) => const StudentProfileScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, auth, _) {
        if (!auth.isBooted) {
          return const _SplashScreen();
        }

        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        if (!auth.isProfileCompleted) {
          return const StudentProfileScreen();
        }

        return const RootScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}