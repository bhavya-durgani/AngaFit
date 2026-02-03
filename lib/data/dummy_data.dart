class Product {
  final String name;
  final String brand;
  final String price;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    this.rating = 4.5,
    this.reviewCount = 10,
  });
}

final List<Product> appProducts = [
  Product(
    name: "Evening Dress",
    brand: "Dorothy Perkins",
    price: "USD 15.00",
    imageUrl: "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446",
  ),
  Product(
    name: "Pullover",
    brand: "Mango",
    price: "USD 51.00",
    imageUrl: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea",
  ),
  Product(
    name: "T-Shirt Spanish",
    brand: "Mango",
    price: "USD 9.00",
    imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab",
  ),
  Product(
    name: "Blouse",
    brand: "Lime",
    price: "USD 30.00",
    imageUrl: "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a",
  ),
  Product(
    name: "Leather Jacket",
    brand: "H&M",
    price: "USD 120.00",
    imageUrl: "https://images.unsplash.com/photo-1551028719-00167b16eac5",
  ),
  Product(
    name: "Denim Jeans",
    brand: "Levi's",
    price: "USD 45.00",
    imageUrl: "https://images.unsplash.com/photo-1542272604-787c3835535d",
  ),
];
