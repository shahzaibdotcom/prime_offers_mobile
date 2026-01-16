import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens (Placeholder imports)
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/offers/offers_screen.dart';
import '../features/offers/offer_detail_screen.dart';
import '../features/cards/my_cards_screen.dart';
import '../features/cards/add_card_screen.dart';
import '../features/main/main_navigation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/my-cards',
            builder: (context, state) => const MyCardsScreen(),
          ),
          GoRoute(
            path: '/add-card',
            builder: (context, state) => const AddCardScreen(),
          ),
          GoRoute(
            path: '/offers',
            builder: (context, state) {
              final categoryId = state.uri.queryParameters['category_id'];
              return OffersScreen(categoryId: categoryId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/offer/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OfferDetailScreen(offerId: id);
        },
      ),
    ],
  );
});
