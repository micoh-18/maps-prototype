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
      title: 'Maps Prototype',
      initialRoute: '/',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Prototype'),
        ),
        body: Center(
          child: HomePage(),
        ),
      ),
    );
  }
}
