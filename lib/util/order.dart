class TeacherOrder {
  final String name;
  final String room;
  final String preferences;
  final double price;
  final int quantity;

  const TeacherOrder({
    required this.name,
    required this.preferences,
    required this.room,
    required this.price,
    required this.quantity,
  });

  factory TeacherOrder.fromMap(Map<String, dynamic> map) {
    return TeacherOrder(
      name: map['name'] as String,
      preferences: map['preferences'] as String,
      room: map['room'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'preferences': preferences,
      'room': room,
      'price': price,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'TeacherOrder(name: $name, preferences: $preferences, room: $room, price: $price, quantity: $quantity)';
  }
}
