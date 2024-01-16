import 'package:flutter/material.dart';
import 'package:jhs_pop/util/checkout_order.dart';

class ListTileCounter extends StatefulWidget {
  final CheckoutOrder order;
  final Map<CheckoutOrder, int> count;

  const ListTileCounter({super.key, required this.order, required this.count});

  @override
  State<ListTileCounter> createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileCounter> {
  updateCount(int count) {
    if (count < 1) return;
    if (count > 25) return;

    setState(() {
      widget.count
          .update(widget.order, (value) => count, ifAbsent: () => count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '\$${(widget.order.price * widget.count[widget.order]!).toStringAsFixed(2)}',
      ),
      title: Text(widget.order.name),
      trailing: Container(
        height: 40,
        width: 80,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.grey[800]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () {
                  updateCount(widget.count[widget.order]! - 1);
                },
                child: const Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 16,
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey[800]),
              child: Text(
                widget.count[widget.order]!.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            InkWell(
                onTap: () {
                  updateCount(widget.count[widget.order]! + 1);
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                )),
          ],
        ),
      ),
    );
  }
}
