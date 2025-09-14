import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:calorie_tracking_app/pages/meal_upload_page.dart';
import 'package:calorie_tracking_app/pages/meal_history_page.dart';
import 'package:calorie_tracking_app/pages/account_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );
  static final List<Widget> _widgetOptions = <Widget>[
    const MealUploadPage(),
    const MealHistoryPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withAlpha(25)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.deepPurple.withAlpha(102),
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineAwesomeIcons.camera_retro_solid,
                  text: 'Upload',
                ),
                GButton(
                  icon: LineAwesomeIcons.clock,
                  text: 'History',
                ),
                GButton(icon: LineAwesomeIcons.user, text: 'Account'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}