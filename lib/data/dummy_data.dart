class Product {
  final String name, brand, price, imageUrl, description, composition, care;
  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.composition,
    required this.care,
  });
}

class Order {
  final String id, date, status, amount, imageUrl;
  Order({required this.id, required this.date, required this.status, required this.amount, required this.imageUrl});
}

// Updated categories: Removed Accessories
final List<String> appCategories = ["All", "Women", "Men", "Kids"];

final List<Product> appProducts = [
  Product(
      name: "Evening Dress",
      brand: "Dorothy Perkins",
      price: "₹1,599",
      imageUrl: "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446",
      description: "A stunning evening dress featuring a slim-fit silhouette and elegant neckline. Perfect for formal gatherings and cocktail parties.",
      composition: "Main: 95% Polyester, 5% Elastane. Lining: 100% Polyester.",
      care: "Machine wash at 30°C. Do not bleach. Iron on low heat."
  ),
  Product(
      name: "Pullover",
      brand: "Mango",
      price: "₹2,499",
      imageUrl: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea",
      description: "Cozy knit pullover made from premium wool blend. Features a relaxed fit and ribbed cuffs for ultimate comfort.",
      composition: "70% Wool, 30% Acrylic.",
      care: "Hand wash only. Dry flat. Do not tumble dry."
  ),
  Product(
      name: "T-Shirt Spanish",
      brand: "Mango",
      price: "₹799",
      imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab",
      description: "Classic cotton t-shirt with a modern fit. Breathable fabric perfect for daily wear.",
      composition: "100% Cotton.",
      care: "Machine wash cold."
  ),
  Product(
      name: "Blouse",
      brand: "Lime",
      price: "₹1,299",
      imageUrl: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a",
      description: "Elegant blouse with a delicate pattern. Light and airy, ideal for summer days.",
      composition: "100% Viscose.",
      care: "Hand wash cold. Do not wring."
  ),
];

final List<Order> userOrders = [
  Order(id: "1947034", date: "05-12-2025", status: "Delivered", amount: "₹4,112", imageUrl: "https://images.unsplash.com/photo-1539109136881-3be0616acf4b"),
];
