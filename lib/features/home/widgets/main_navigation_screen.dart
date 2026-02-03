// import 'package:flutter/material.dart';
// import '../../cart/cart_screen.dart';
// import '../../ar_view/ar_try_on_screen.dart';
// import '../home_screen.dart';
// import '../../profile/profile_screen.dart';
// import '../../../core/constants/app_colors.dart';
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = [
//     HomeScreen(),
//     ARTryOnScreen(),
//     CartScreen(),
//     ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.grey,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.camera_alt),
//             label: 'Try On',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag),
//             label: 'Bag',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
