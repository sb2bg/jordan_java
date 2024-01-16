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
            leading: Image.asset(
              widget.buttons[index].image,
              height: 40,
              width: 40,
            ),
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
        String originalName = widget.buttons[index].name;
        String newName = widget.buttons[index].name;
        double originalPrice = widget.buttons[index].price;
        double? newPrice = widget.buttons[index].price;
        bool uploadImage = false;
        bool showSave = false;
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            void calculateShowSave() {
              if (newName != originalName ||
                  newPrice != originalPrice ||
                  uploadImage) {
                setState(() {
                  showSave = true;
                });
              } else {
                setState(() {
                  showSave = false;
                });
              }
            }

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

                        calculateShowSave();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        newPrice = double.tryParse(value);
                        calculateShowSave();
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

                                  calculateShowSave();
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
                        onPressed: showSave
                            ? () {
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
                                    whereArgs: [widget.buttons[index].id],
                                  ).then((value) {
                                    setState(() {
                                      widget.buttons[index].name = newName;
                                      widget.buttons[index].price = newPrice!;
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
                              }
                            : null,
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
