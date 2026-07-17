import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class HbsApp extends StatelessWidget {
  const HbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hafsh Business Suite',
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hafsh Business Suite',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}