import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/checkout_order.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/img_manager.dart';

class EditOptionsPage extends StatefulWidget {
  const EditOptionsPage({super.key, required this.buttons});

  final List<CheckoutOrder> buttons;

  @override
  State<EditOptionsPage> createState() => _EditOptionsPageState();
}

class _EditOptionsPageState extends State<EditOptionsPage> {
  late List<CheckoutOrder> _buttons;

  @override
  Widget build(BuildContext context) {
    _buttons = widget.buttons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Options'),
        actions: const [
          // TODO: Add button to add new item
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {
          //     setState(() {
          //       _buttons.add(CheckoutOrder(
          //         name: 'New Item',
          //         price: 0.0,
          //         image: 'assets/images/solid_blue.jpeg',
          //       ));
          //     });
          //     _showEditDialog(_buttons.length - 1);
          //   },
          // ),
        ],
      ),
      body: ListView.builder(
        itemCount: _buttons.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(
              _buttons[index].image,
              height: 40,
              width: 40,
            ),
            title: Text(_buttons[index].name),
            subtitle: Text('\$${_buttons[index].price.toStringAsFixed(2)}'),
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
        String originalName = _buttons[index].name;
        String newName = _buttons[index].name;
        double originalPrice = _buttons[index].price;
        double? newPrice = _buttons[index].price;
        bool uploadImage = false;
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setState) {
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
                        if (value.isEmpty) {
                          newName = originalName;
                        } else {
                          newName = value;
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          newPrice = originalPrice;
                        } else {
                          newPrice = double.tryParse(value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                saveImage(index, context).then((value) {
                                  if (!value) return;

                                  setState(() {
                                    uploadImage = true;
                                  });
                                });
                              },
                              child: const Text('Upload Image')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            uploadImage
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: uploadImage ? Colors.green : Colors.grey,
                          ),
                        )
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
                saving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (newName.isEmpty) {
                            context.showErrorSnackBar(
                                message: 'Name cannot be empty');
                            return;
                          }

                          if (newPrice == null) {
                            context.showErrorSnackBar(
                                message: 'Please enter a valid price');
                            return;
                          }

                          setState(() {
                            saving = true;
                          });

                          final updates = <String, dynamic>{
                            'name': newName,
                            'price': newPrice,
                          };

                          void updateDatabase() {
                            db.update(
                              'checkouts',
                              updates,
                              where: 'id = ?',
                              whereArgs: [_buttons[index].id],
                            ).then((value) {
                              setState(() {
                                _buttons[index].name = newName;
                                _buttons[index].price = newPrice!;
                              });
                            });

                            Navigator.of(context).pop();
                          }

                          if (uploadImage) {
                            getImagePath(index).then((value) {
                              updates['image'] = value;
                              updateDatabase();
                            });
                          } else {
                            updateDatabase();
                          }
                        },
                        child: const Text('Save'),
                      ),
              ],
            );
          },
        );
      },
    );
  }
}
