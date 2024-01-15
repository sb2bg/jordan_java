class TeacherOrder {
  final int? id;
  final String? name;
  final String? room;
  final String? additional;
  final String? frequency;
  final String? creamer;
  final String? sweetener;

  const TeacherOrder({
    required this.id,
    required this.name,
    required this.room,
    required this.additional,
    required this.frequency,
    required this.creamer,
    required this.sweetener,
  });

  factory TeacherOrder.fromMap(Map<String, dynamic> map) {
    return TeacherOrder(
      id: map['id'],
      name: map['name'],
      room: map['room'],
      additional: map['additional'],
      frequency: map['frequency'],
      creamer: map['creamer'],
      sweetener: map['sweetener'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'additional': additional,
      'frequency': frequency,
      'creamer': creamer,
      'sweetener': sweetener,
    };
  }

  @override
  String toString() {
    return 'TeacherOrder(name: $name, room: $room, additional: $additional, frequency: $frequency, creamer: $creamer, sweetener: $sweetener)';
  }
}
