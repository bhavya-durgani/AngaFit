import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../catalog/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});
  @override State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  int _currentIndex = 0;
  final _pages = [const HomeScreen(), const ProductListScreen(), const CartScreen(), const FavoritesScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryRed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Bag"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
