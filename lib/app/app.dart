import 'package:flutter/material.dart';

import 'package:good_eating/app/router/app_router.dart';
import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Good Eating',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.shell,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
