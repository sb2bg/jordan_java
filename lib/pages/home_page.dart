import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/order.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TeacherOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    dbReady.future.then((_) {
      db.query('orders').then((rows) {
        setState(() {
          _orders = rows.map((row) => TeacherOrder.fromMap(row)).toList();
          _loading = false;
        });
      });
    });
  }

  Future<void> openProductCreation() async {
    final result = await Navigator.pushNamed(context, '/load_order');

    if (result != null) {
      final orders = result as List<TeacherOrder>;

      for (final order in orders) {
        await insertProduct(order.toMap()).then((value) {
          setState(() {
            _orders.add(value);
          });
        });
      }
    }
  }

  Future<TeacherOrder> insertProduct(Map<String, dynamic> map) async {
    final id = await db.insert('orders', map);

    return TeacherOrder.fromMap({
      'id': id,
      ...map,
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? spinner
        : Scaffold(
            appBar: AppBar(
              title: const Text('Teacher Orders'),
              actions: [
                IconButton(
                  onPressed: () async {
                    await openProductCreation();
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/filter');
                  },
                  icon: const Icon(Icons.filter_alt_outlined),
                ),
                IconButton(
                  onPressed: () async {
                    await context.showConfirmationDialog(
                        title: 'Confirm',
                        message: 'Are you sure you want to delete all orders?',
                        onConfirm: () {
                          db.delete('orders').then((value) {
                            setState(() {
                              _orders.clear();
                            });
                          });
                        },
                        confirmText: "Delete");
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                )
              ],
            ),
            body: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No orders found',
                                style: TextStyle(fontSize: 24.0)),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: () async {
                                await openProductCreation();
                              },
                              child: const Text('Load Order File'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];

                            return Dismissible(
                              key: Key(order.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                db.delete('orders',
                                    where: 'id = ?',
                                    whereArgs: [
                                      order.id,
                                    ]).then((value) {
                                  setState(() {
                                    _orders.removeAt(index);
                                  });
                                });
                              },
                              child: ListTile(
                                title: Text(order.name ?? 'No name specified'),
                                subtitle:
                                    Text(order.room ?? 'No room specified'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.credit_card),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/payment',
                                        arguments: order);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          );
  }
}
