import 'package:flutter/material.dart';

class HbsApp extends StatelessWidget {
  const HbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hafsh Business Suite',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Hafsh Business Suite'),
        ),
      ),
    );
  }
}