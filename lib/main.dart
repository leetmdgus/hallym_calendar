import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setting.dart';
import 'calendar.dart';
import 'todo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController controller;
  bool isChecked = false;

  late SharedPreferences prefs;
  String? loginPlatform = null;

  getInitState() async {
    prefs = await SharedPreferences.getInstance();
    loginPlatform = prefs.getString('loginPlatform') ?? null;
    userEmail = prefs.getString('userEmail') ?? null;
    isSunnyMode = prefs.getBool('isSunnyMode') ?? true;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInitState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginPlatform != null ? _mainWidget() : _loginWidget(),
    );
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      setState(() {
        userEmail = googleUser.email;
        loginPlatform = 'google';
        prefs.setString('loginPlatform', 'google');
        prefs.setString('userEmail', googleUser.email);
      });
    }
  }

  void signInWithGuest() async {
    setState(() {
      userEmail = 'guest';
      loginPlatform = 'guest';
      prefs.setString('loginPlatform', 'guest');
      prefs.setString('userEmail', 'guest');
    });
  }

  void signOut() async {
    await GoogleSignIn().signOut();

    setState(() {
      userEmail = null;
      loginPlatform = null;
      prefs.remove('loginPlatform');
      prefs.remove('userEmail');
    });
  }

  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: Text('로그아웃'),
    );
  }

  Widget _loginWidget() {
    return Scaffold(
        body: Container(
      color: isSunnyMode ? Colors.white : Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/googleimg.png',
              width: 100,
            ),
            Container(
              height: 20,
            ),
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('구글 계정으로 로그인'),
            ),
            ElevatedButton(
              onPressed: signInWithGuest,
              child: Text('게스트로 로그인'),
            )
          ],
        ),
      ),
    ));
  }

  Widget _mainWidget() {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: isSunnyMode ? Colors.black : Colors.grey),
        backgroundColor: isSunnyMode ? Colors.white : Colors.black87,
        title: Row(children: [
          Text(
            '20245223 이승현',
            style: TextStyle(color: isSunnyMode ? Colors.black : Colors.grey),
          ),
          Spacer(),
        ]),
        bottom: TabBar(
          controller: controller,
          tabs: [
            Tab(text: 'To do'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(controller: controller, children: [
        ToDoScreen(),
        // Container(),
        CalendarScreen(),
      ]),
      drawer: Drawer(
        backgroundColor: isSunnyMode ? Colors.white : Colors.black,
        child: Column(
          children: [
            Container(color: Colors.deepPurple, height: 30),
            Container(height: 150),
            Container(color: Colors.deepPurple, height: 5),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isSunnyMode = !isSunnyMode;
                });
                prefs.setBool('isSunnyMode', isSunnyMode);
              },
              child: Icon(isSunnyMode ? Icons.light_mode : Icons.dark_mode),
            ),
            Container(height: 10),
            _logoutButton(),
            Container(height: 30)
          ],
        ),
      ),
    );
  }
}
