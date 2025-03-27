import 'package:flutter/material.dart';
import 'package:map_prototype/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Maps App',
      initialRoute: '/', // Initial route

      home: Scaffold(
        appBar: AppBar(
          title: Text('My Maps App'),
        ),
        body: Center(
          child: HomePage(),
        ),
      ),
    );
  }
}
