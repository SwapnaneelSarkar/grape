import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grape/presentation/screens/appointments/bloc.dart';
import 'package:grape/presentation/screens/edit%20profile/bloc.dart';
import 'package:grape/presentation/screens/heath%20record%20add/bloc.dart';
import 'package:grape/presentation/screens/profile/bloc.dart';
import 'firebase_options.dart';
import 'presentation/color_constant/color_constant.dart';
import 'presentation/screens/home_screen/bloc.dart';
import 'presentation/screens/medicines/bloc.dart';
import 'router/router.dart';
import 'presentation/screens/login_screen/bloc.dart';
import 'presentation/screens/login_screen/event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized Successfully");

    runApp(const MyApp());
  } catch (e) {
    print("❌ Firebase Initialization Failed: ${e.toString()}");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  String? authToken;

  // Initialize notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      _loadAuthToken,
    ); // ✅ Ensures plugins are registered first

    _initializeNotifications();
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load auth token from secure storage
  Future<void> _loadAuthToken() async {
    try {
      authToken = await _secureStorage.read(key: 'authToken');
      print("🔑 Retrieved Secure Token: $authToken");
    } catch (e) {
      print("❌ Secure Storage Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check reminders and trigger notifications
  Future<void> _checkReminders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('meds_reminder')
            .doc(userId)
            .collection('reminders')
            .get();

    final currentTime = DateTime.now();

    // Loop through all reminders and check if any reminder's time matches the current time
    for (var reminder in snapshot.docs) {
      final time = (reminder['time'] as Timestamp).toDate();
      final reminderTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        time.hour,
        time.minute,
      );

      if (currentTime.isAtSameMomentAs(reminderTime)) {
        _showNotification(reminder['medicineName'], reminder['time']);
      }
    }
  }

  // Show local notification
  Future<void> _showNotification(String medicineName, Timestamp time) async {
    const android = AndroidNotificationDetails(
      'reminder_channel', // Channel ID
      'Medicine Reminders', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
    );

    const platform = NotificationDetails(android: android);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Time for $medicineName!',
      'It\'s time to take your medicine.',
      platform,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ), // Show loading until Secure Storage is ready
        ),
      );
    }

    // Call _checkReminders() periodically, or whenever necessary
    _checkReminders();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc()..add(CheckLoginStatus()),
        ),
        BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
        BlocProvider<MedicationBloc>(create: (context) => MedicationBloc()),
        BlocProvider<AppointmentBloc>(create: (context) => AppointmentBloc()),
        BlocProvider<HealthRecordBloc>(create: (context) => HealthRecordBloc()),
      ],
      child: MaterialApp(
        title: 'Grape App',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: TextTheme(
            displayLarge: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.buttonText,
              backgroundColor: AppColors.primary,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
        ),
        initialRoute: authToken != null ? '/medShow' : Routes.loginPage,
        onGenerateRoute: RouteGenerator.getRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
