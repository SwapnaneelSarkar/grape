import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:grape/presentation/screens/home_screen/view.dart';
import 'package:grape/presentation/screens/login_screen/view.dart';
import 'package:grape/presentation/screens/medicines/view.dart';
import 'package:grape/presentation/screens/show_reminder/showReminders_view.dart';
import 'package:grape/presentation/screens/add_reminder/view.dart';
import 'package:grape/presentation/screens/signup_screen/view.dart';
import 'package:grape/presentation/screens/symptom%20tracker/view.dart';
import 'package:grape/presentation/screens/terms%20and%20conditions/view.dart';
import '../presentation/screens/maps/maps.dart';
import '../presentation/screens/profile/view.dart';

class Routes {
  static const String loginPage = '/auth';
  static const String signup = '/signup';
  static const String maps = '/maps';
  static const String reminder = "/reminder";
  static const String reminderShow = "/reminderShow";
  static const String symptomTracker = "/tracker";
  static const String Profile = "/profile";
  static const String terms = "/tnc";

  static const String home = "/home";
  static const String meds = "/meds";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.loginPage:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupView());

      case Routes.maps:
        return MaterialPageRoute(builder: (_) => MapView());

      case Routes.reminder:
        return MaterialPageRoute(builder: (_) => const MedicineReminderView());

      case Routes.reminderShow:
        return MaterialPageRoute(builder: (_) => const ViewRemindersPage());

      case Routes.symptomTracker:
        return MaterialPageRoute(builder: (_) => const HealthSymptomView());

      case Routes.Profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());

      case Routes.terms:
        return MaterialPageRoute(builder: (_) => TermsAndConditionsPage());

      case Routes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case Routes.meds:
        return MaterialPageRoute(builder: (_) => MedicationPage());

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(
            body: SizedBox(child: Center(child: Text("Page Not Found"))),
          ),
    );
  }
}
