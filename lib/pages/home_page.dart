import 'package:flutter/material.dart';
import 'package:jhs_pop/main.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/teacher_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TeacherOrder> _orders = [];
  List<TeacherOrder> _filteredOrders = [];
  bool _loading = true;
  String _sort = 'default';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    dbReady.future.then((_) {
      db.query('orders').then((rows) {
        setState(() {
          _orders = rows.map((row) => TeacherOrder.fromMap(row)).toList();
          _filteredOrders = List.from(_orders);
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
            _filteredOrders.add(value);
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

  sort() {
    switch (_sort) {
      case 'name':
        _filteredOrders.sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));
        break;
      case 'room':
        _filteredOrders.sort((a, b) => (a.room ?? '')
            .toLowerCase()
            .compareTo((b.room ?? '').toLowerCase()));
        break;
      default:
        Set<TeacherOrder> original = Set.from(_orders);
        Set<TeacherOrder> filtered = Set.from(_filteredOrders);
        _filteredOrders = original.intersection(filtered).toList();
        break;
    }
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
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort),
                              title: const Text('Sort by default'),
                              trailing: _sort == 'default'
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _sort = 'default';
                                  sort();
                                });

                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort_by_alpha),
                              title: const Text('Sort by name'),
                              trailing: _sort == 'name'
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _sort = 'name';
                                  sort();
                                });

                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.sort_by_alpha),
                              title: const Text('Sort by room'),
                              trailing: _sort == 'room'
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _sort = 'room';
                                  sort();
                                });

                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Teacher Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Cashier Screen'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/cashier');
                    },
                  ),
                  ListTile(
                    title: const Text('Load Order'),
                    onTap: () async {
                      await openProductCreation();
                    },
                  ),
                  ListTile(
                    title: const Text('Delete All Orders'),
                    onTap: () async {
                      await context.showConfirmationDialog(
                        title: 'Confirm',
                        message: 'Are you sure you want to delete all orders?',
                        onConfirm: () {
                          db.delete('orders').then((value) {
                            setState(() {
                              _orders.clear();
                              _filteredOrders.clear();
                            });

                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Make Default Screen'),
                    onTap: () {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('default_screen', '/home');
                        context.showSnackBar(
                            message: 'Default screen set to cashier');
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              ),
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
                        child: Column(children: [
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search by name or room',
                              suffixIcon: Icon(Icons.search),
                            ),
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _filteredOrders = _orders
                                    .where((order) =>
                                        (order.name ?? '')
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ||
                                        (order.room ?? '')
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                    .toList();

                                sort();
                              });
                            },
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];

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
                                        _orders.remove(
                                            _filteredOrders.removeAt(index));
                                      });
                                    });
                                  },
                                  child: ListTile(
                                    title:
                                        Text(order.name ?? 'No name specified'),
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
                        ]),
                      ),
          );
  }
}
