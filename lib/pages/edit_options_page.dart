import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/checkout_order.dart';
import 'package:jhs_pop/util/img_manager.dart';

class EditOptionsPage extends StatefulWidget {
  const EditOptionsPage({super.key, required this.buttons});

  final List<CheckoutOrder> buttons;

  @override
  State<EditOptionsPage> createState() => _EditOptionsPageState();
}

class _EditOptionsPageState extends State<EditOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Options'),
        actions: const [
          // TODO: Add button to add new item
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {
          //     setState(() {
          //       widget.buttons.add(CheckoutOrder(
          //         name: 'New Item',
          //         price: 0.0,
          //         image: 'assets/images/solid_blue.jpeg',
          //       ));
          //     });
          //     _showEditDialog(widget.buttons.length - 1);
          //   },
          // ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.buttons.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.buttons[index].name),
            subtitle:
                Text('\$${widget.buttons[index].price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(index);
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String newName = widget.buttons[index].name;
        double newPrice = widget.buttons[index].price;

        return StatefulBuilder(
          builder: (context, setState) {
            bool uploadImage = false;

            return AlertDialog(
              title: const Text('Edit Option'),
              content: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      onChanged: (value) {
                        newName = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        newPrice = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                saveImage(index, context).then((value) {
                                  setState(() {
                                    uploadImage = true;
                                  });
                                });
                              },
                              child: const Text('Upload Image')),
                        ),
                        IconButton(
                            onPressed: null,
                            icon: uploadImage
                                ? const Icon(Icons.check)
                                : const Icon(Icons.close)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    db.update(
                      'checkouts',
                      {
                        'name': newName,
                        'price': newPrice,
                      },
                      where: 'id = ?',
                      whereArgs: [widget.buttons[index].id],
                    );

                    setState(() {
                      widget.buttons[index].name = newName;
                      widget.buttons[index].price = newPrice;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
