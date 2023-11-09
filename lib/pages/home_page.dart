import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    dbReady.future.then((_) {
      db.query('products').then((rows) {
        setState(() {
          _products = rows.map((row) => Product.fromMap(row)).toList();
          _loading = false;
        });
      });
    });
  }

  Future<Product> insertProduct(Map<String, dynamic> map) async {
    final id = await db.insert('products', map);

    return Product.fromMap({
      'id': id,
      ...map,
    });
  }

  Future<void> openProductCreation() async {
    final result = await Navigator.pushNamed(context, '/load_order');

    if (result != null) {
      final product = await insertProduct(result as Map<String, dynamic>);

      setState(() {
        _products.add(product);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? spinner
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await openProductCreation();
              },
              backgroundColor: Colors.red[300],
              child: const Icon(Icons.admin_panel_settings),
            ),
            appBar: AppBar(
              title: const Text('Select Items'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment');
                  },
                  icon: const Icon(Icons.payment),
                ),
              ],
            ),
            body: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No products found',
                                style: TextStyle(fontSize: 24.0)),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: () async {
                                await openProductCreation();
                              },
                              child: const Text('Add Product'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];

                          return Dismissible(
                            key: Key(product.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: const Icon(Icons.delete),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text(
                                        'Are you sure you want to delete this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              db.delete('products',
                                  where: 'id = ?',
                                  whereArgs: [
                                    product.id,
                                  ]).then((value) {
                                setState(() {
                                  _products.removeAt(index);
                                });
                              });
                            },
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Text(product.description),
                              trailing:
                                  Text('\$${product.price.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      ),
          );
  }
}
