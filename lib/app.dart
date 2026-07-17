import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class HbsApp extends StatelessWidget {
  const HbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hafsh Business Suite',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}