import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/checkout_order.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/widgets/counter.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<CheckoutOrder> _buttons = [];
  final Map<CheckoutOrder, int> _orders = {};
  final List<Color> fonts = List.generate(9, (index) {
    return Colors.black;
  });

  @override
  void initState() {
    super.initState();

    dbReady.future.then((_) {
      db.query('checkouts').then((rows) {
        setState(() {
          _buttons = rows.map((row) => CheckoutOrder.fromMap(row)).toList();
        });
      });
    });
  }

  updateFont(ImageProvider image, int index) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(image);

    if (mounted) {
      setState(() {
        fonts[index] =
            getTextColor(paletteGenerator.dominantColor?.color ?? Colors.black);
      });
    }
  }

  Color getTextColor(Color color) {
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Point of Payment'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: List.generate(_buttons.length, (index) {
                  final button = _buttons[index];
                  final background = DecorationImage(
                    image: AssetImage(button.image),
                    fit: BoxFit.cover,
                  );

                  updateFont(background.image, index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _orders.update(button, (value) => value + 1,
                            ifAbsent: () => 1);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: background,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              button.name,
                              style: TextStyle(
                                color: fonts[index],
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '\$${button.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: fonts[index],
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Complete Order')),
                  const SizedBox(width: 20),
                  TextButton.icon(
                      onPressed: () async {
                        await context.showConfirmationDialog(
                          title: 'Restart Order',
                          message:
                              'Are you sure you want to restart the order?',
                          confirmText: 'Restart',
                          onConfirm: () {
                            setState(() {
                              _orders.clear();
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Restart Order')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders.keys.elementAt(index);

                    return Row(
                      children: [
                        Expanded(
                          child: ListTileCounter(
                            price: order.price,
                            title: order.name,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              context.showConfirmationDialog(
                                title: 'Remove Item',
                                message:
                                    'Are you sure you want to remove this item?',
                                confirmText: 'Remove',
                                onConfirm: () {
                                  _orders.remove(order);
                                },
                              );
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Point of Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Teacher Orders Screen'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                title: const Text('Edit Options'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/edit_options',
                      arguments: _buttons);
                },
              ),
              ListTile(
                title: const Text('Make Default Screen'),
                onTap: () {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString('default_screen', '/cashier');
                    context.showSnackBar(
                        message: 'Default screen set to cashier mode');
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ));
  }
}
