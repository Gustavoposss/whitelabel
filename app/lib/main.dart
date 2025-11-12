import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/products_provider.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
          create: (_) => ThemeProvider(apiService: apiService),
          update: (context, authProvider, previous) {
            final provider = previous ?? ThemeProvider(apiService: apiService);
            apiService.setToken(authProvider.token);
            if (authProvider.isAuthenticated && !provider.isLoading) {
              provider.refreshTheme();
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(apiService: apiService),
          update: (context, authProvider, previous) {
            final provider = previous ?? ProductsProvider(apiService: apiService);
            apiService.setToken(authProvider.token);
            return provider;
          },
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'E-commerce Whitelabel',
            theme: themeProvider.theme ?? ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.primaryColor,
              ),
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/products': (context) => const ProductsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const ProductsScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
