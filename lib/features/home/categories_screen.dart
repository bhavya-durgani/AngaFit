import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'sub_categories_screen.dart'; // Screen to open when category is clicked

// Stateless widget (UI does not change dynamically)
class CategoriesScreen extends StatelessWidget {

  // List of categories (each has name + image)
  final List<Map<String, String>> categories = [

    // Category 1
    {
      "name": "Women",
      "image": "https://images.unsplash.com/photo-1525507119028-ed4c629a60a3"
    },

    // Category 2
    {
      "name": "Men",
      "image": "https://images.unsplash.com/photo-1490578474895-699cd4e2cf59"
    },

    // Category 3
    {
      "name": "Kids",
      "image": "https://images.unsplash.com/photo-1519238263530-99bdd11df2ea"
    },
  ];

  CategoriesScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Top app bar
      appBar: AppBar(
        title: const Text("Categories"), // Title
        centerTitle: true // Center the title
      ),

      // BODY
      body: ListView.builder(

        padding: const EdgeInsets.all(16), // Space around list

        itemCount: categories.length, // Total categories

        itemBuilder: (context, index) {

          return GestureDetector(

            // When user taps a category
            onTap: () => Navigator.push(

              context,

              // Navigate to SubCategoriesScreen and pass category name
              MaterialPageRoute(
                builder: (_) => SubCategoriesScreen(
                  categoryName: categories[index]['name']!
                )
              ),
            ),

            child: Container(

              height: 100, // Height of each category card

              margin: const EdgeInsets.only(bottom: 16), // Space between cards

              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(8) // Rounded corners
              ),

              child: Row(
                children: [

                  // LEFT SIDE → CATEGORY NAME
                  Expanded(
                    child: Center(
                      child: Text(
                        categories[index]['name']!, // Category name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ),

                  // RIGHT SIDE → CATEGORY IMAGE
                  ClipRRect(

                    // Round only right side corners
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(8)
                    ),

                    child: Image.network(
                      categories[index]['image']!, // Image URL
                      width: 150,
                      fit: BoxFit.cover // Fill image properly
                    )
                  )
                ]
              ),
            ),
          );
        },
      ),
    );
  }
}
