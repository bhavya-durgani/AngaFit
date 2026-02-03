// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
//
// class FiltersScreen extends StatefulWidget {
//   const FiltersScreen({super.key});
//
//   @override
//   State<FiltersScreen> createState() => _FiltersScreenState();
// }
//
// class _FiltersScreenState extends State<FiltersScreen> {
//   RangeValues priceRange = const RangeValues(500, 3000);
//   String selectedSize = 'M';
//   String selectedCategory = 'Women';
//
//   final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
//   final List<String> categories = ['Women', 'Men', 'Kids'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Filters')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Price Range',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             RangeSlider(
//               values: priceRange,
//               min: 0,
//               max: 5000,
//               divisions: 10,
//               activeColor: AppColors.primary,
//               labels: RangeLabels(
//                 '₹${priceRange.start.toInt()}',
//                 '₹${priceRange.end.toInt()}',
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   priceRange = value;
//                 });
//               },
//             ),
//
//             const SizedBox(height: 24),
//             const Text(
//               'Size',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: sizes.map((size) {
//                 return ChoiceChip(
//                   label: Text(size),
//                   selected: selectedSize == size,
//                   selectedColor: AppColors.primary,
//                   onSelected: (_) {
//                     setState(() {
//                       selectedSize = size;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//
//             const SizedBox(height: 24),
//             const Text(
//               'Category',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: categories.map((cat) {
//                 return ChoiceChip(
//                   label: Text(cat),
//                   selected: selectedCategory == cat,
//                   selectedColor: AppColors.primary,
//                   onSelected: (_) {
//                     setState(() {
//                       selectedCategory = cat;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//
//             const Spacer(),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         priceRange = const RangeValues(500, 3000);
//                         selectedSize = 'M';
//                         selectedCategory = 'Women';
//                       });
//                     },
//                     child: const Text('RESET'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text('APPLY'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
