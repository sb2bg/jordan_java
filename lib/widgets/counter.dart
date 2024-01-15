import 'package:flutter/material.dart';

class ListTileCounter extends StatefulWidget {
  final String title;
  final double price;

  const ListTileCounter({Key? key, required this.title, required this.price})
      : super(key: key);

  @override
  State<ListTileCounter> createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileCounter> {
  int _itemCount = 1;

  updateCount(int count) {
    if (count < 1) return;
    if (count > 25) return;

    setState(() {
      _itemCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '\$${(widget.price * _itemCount).toStringAsFixed(2)}',
      ),
      title: Text(widget.title),
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
                  updateCount(_itemCount - 1);
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
                _itemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            InkWell(
                onTap: () {
                  updateCount(_itemCount + 1);
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
