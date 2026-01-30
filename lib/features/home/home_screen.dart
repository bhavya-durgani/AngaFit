import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  static const List<String> categories = ["Men", "Women", "Kids"];

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("AR STYLE HUB", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilter(context)),
          ],
        ),
        body: TabBarView(
          children: categories.map((cat) => Center(child: Text("$cat Collection coming soon"))).toList(),
        ),
      ),
    );
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // ignore: deprecated_member_use
            ListTile(title: const Text("Price: Low to High"), leading: Radio(value: 1, groupValue: 1, onChanged: (v){})),
            const ListTile(title: Text("Size: M, L, XL"), leading: Icon(Icons.check_box_outline_blank)),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Apply"))
          ],
        ),
      ),
    );
  }
}
