import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For hardware back button interception
import '../../color_constant/color_constant.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/CommunityListPage');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/maps');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.primary,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedFontSize: 0,
              unselectedFontSize: 0,
              elevation: 0,
              iconSize: 25,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_add),
                  activeIcon: Icon(Icons.group_add_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(icon: SizedBox(width: 50), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  activeIcon: Icon(Icons.location_on_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2),
                  activeIcon: Icon(Icons.person_2_outlined),
                  label: '',
                ),
              ],
            ),
            Positioned(
              bottom: 5,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chatbot',
                    ); // Redirect to Reminders page
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Icon(
                    Icons.chat_rounded,
                    color: Colors.blue,
                    size: 30, // Make the "add" icon larger as well
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
