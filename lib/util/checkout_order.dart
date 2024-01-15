class CheckoutOrder {
  int? id;
  String name;
  String image;
  double price;

  CheckoutOrder({
    this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  factory CheckoutOrder.fromMap(Map<String, dynamic> map) {
    return CheckoutOrder(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'CheckoutOrder(id: $id, name: $name, image: $image, price: $price)';
  }
}
