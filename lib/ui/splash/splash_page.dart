import 'package:flutter/material.dart';
import 'package:getapps/main.dart';
import 'package:getapps/ui/home/view_models/home_viewmodel.dart';
import 'package:getapps/ui/splash/view_models/splash_viewmodel.dart';
import 'package:routefly/routefly.dart';

import '../../config/dependencies.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final homeViewmodel = injector.get<HomeViewmodel>();
  final splashViewModel = injector.get<SplashViewmodel>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await splashViewModel.addThisAppInformationCommand.execute();
    await Future.wait([
      homeViewmodel.fetchAppsCommand.execute(),
      Future.delayed(const Duration(milliseconds: 2000)),
    ]).then((_) {
      Routefly.navigate(routePaths.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone do app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.get_app_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Nome do app
            Text(
              'GetApps',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Gerenciador de APKs',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),

            const SizedBox(height: 48),

            // Progress indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading text
            Text(
              'Carregando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
