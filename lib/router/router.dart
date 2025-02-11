import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:grape/presentation/screens/login_screen/view.dart';
import 'package:grape/presentation/screens/add_reminder/event.dart';
import 'package:grape/presentation/screens/show_reminder/showReminders_view.dart';
import 'package:grape/presentation/screens/add_reminder/view.dart';
import 'package:grape/presentation/screens/signup_screen/view.dart';
import 'package:grape/presentation/screens/symptom%20tracker/view.dart';
import '../presentation/screens/maps/maps.dart';

class Routes {
  static const String loginPage = '/auth';
  static const String signup = '/signup';
  static const String maps = '/maps';
  static const String reminder = "/reminder";
  static const String reminderShow = "/reminderShow";
  static const String symptomTracker = "/tracker";
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
