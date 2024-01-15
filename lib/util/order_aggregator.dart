import 'package:jhs_pop/util/checkout_order.dart';
import 'package:jhs_pop/util/teacher_order.dart';

class OrderAggregator {
  final TeacherOrder? teacherOrder;
  final Map<CheckoutOrder, int>? checkoutOrder;

  OrderAggregator({this.teacherOrder, this.checkoutOrder});

  String get name {
    if (teacherOrder != null) {
      return teacherOrder!.name ?? 'No name specified';
    } else if (checkoutOrder != null) {
      return 'Customer Checkout';
    } else {
      return 'No name specified';
    }
  }

  double get price {
    if (teacherOrder != null) {
      return 12.50; // TODO: Don't hardcode this
    } else if (checkoutOrder != null) {
      return checkoutOrder!.keys
          .map((e) => e.price * checkoutOrder![e]!)
          .reduce((value, element) => value + element);
    } else {
      return 0.0;
    }
  }

  Map<String, dynamic> get fields {
    if (teacherOrder != null) {
      return {
        'room': teacherOrder!.room,
        'additional': teacherOrder!.additional,
        'frequency': teacherOrder!.frequency,
        'creamer': teacherOrder!.creamer,
        'sweetener': teacherOrder!.sweetener,
      };
    } else if (checkoutOrder != null) {
      return checkoutOrder!.keys
          .map((e) => MapEntry(e.name, checkoutOrder![e]))
          .fold<Map<String, dynamic>>({}, (previousValue, element) {
        previousValue[element.key] = element.value;
        return previousValue;
      });
    } else {
      return {};
    }
  }

  TeacherOrder? get teacher {
    return teacherOrder;
  }

  Map<CheckoutOrder, int>? get checkout {
    return checkoutOrder;
  }
}
