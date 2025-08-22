import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/theme.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/providers/auth_provider.dart';
import 'package:baty_bites/providers/recipe_provider.dart';
import 'package:baty_bites/providers/cart_provider.dart';

void main() {
  AppRouter.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        title: 'Baty Food',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
