import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Account Page'))),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text('Click this button to logout', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 30),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  null;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SplashPage()),
                    (route) => false,
                  );
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
