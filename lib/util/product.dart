class Product {
  int id;
  String name;
  String description;
  double price;
  String image;

  Product(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.image});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        price: map['price'],
        image: map['image']);
  }
}
