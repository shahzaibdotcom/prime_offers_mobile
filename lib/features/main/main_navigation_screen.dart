import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../home/home_screen.dart';
import '../offers/offers_screen.dart';
import '../profile/profile_screen.dart';
import '../cards/my_cards_screen.dart';
import '../cards/add_card_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainNavigationScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTap(BuildContext context, int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/offers');
        break;
      case 2:
        context.go('/my-cards');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current index detection based on location
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) _currentIndex = 0;
    if (location.startsWith('/offers')) _currentIndex = 1;
    if (location.startsWith('/my-cards')) _currentIndex = 2;
    if (location.startsWith('/profile')) _currentIndex = 3;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _onTap(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.grid_view_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.grid_view_rounded, size: 26),
                ),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.local_offer_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.local_offer, size: 26),
                ),
                label: 'Hot Deals',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.credit_card_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.credit_card_rounded, size: 26),
                ),
                label: 'My Cards',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.person_outline, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.person_rounded, size: 26),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
