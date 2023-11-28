import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/order.dart';

class LoadOrderPage extends StatefulWidget {
  const LoadOrderPage({super.key});

  @override
  State<LoadOrderPage> createState() => _LoadOrderPageState();
}

class _LoadOrderPageState extends State<LoadOrderPage> {
  final List<TeacherOrder> _orders = [];

  Future<void> _loadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      await _loadDataFrame(excel);
    }
  }

  static const fields = [
    'name',
    'room',
    'additional items',
    'frequency',
    'creamer',
    'sweetener',
  ];

  Future<List<int>?> promptForColumn(List<Data> row) async {
    final columns = row.asMap().entries.map((e) => '${e.value.value}');

    List<int> mappedFields = [];

    for (final field in fields) {
      final index = await openDialog(columns, field);

      if (index == -1) {
        return null;
      }

      mappedFields.add(index);
    }

    return mappedFields;
  }

  Future<int> openDialog(Iterable<String> columns, String columnName) async {
    return await showDialog<int>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Select $columnName column'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: columns.length,
                  itemBuilder: (context, index) {
                    final column = columns.elementAt(index);

                    return ListTile(
                      title: Text(column),
                      onTap: () {
                        Navigator.of(context).pop(index);
                      },
                    );
                  },
                ),
              ),
            );
          },
        ) ??
        -1;
  }

  _loadDataFrame(Excel excel) async {
    int sheetIndex = 0;

    if (excel.tables.length > 1) {
      bool confirmed = false;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Sheet'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: excel.tables.length,
                itemBuilder: (context, index) {
                  final sheet = excel.tables.values.elementAt(index);

                  return ListTile(
                    title: Text(sheet.sheetName),
                    onTap: () {
                      sheetIndex = index;
                      confirmed = true;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (!confirmed) {
        return;
      }
    }

    final sheet = excel.tables.values.elementAt(sheetIndex);

    List<Data> header = [];

    for (final cell in sheet.rows.first) {
      if (cell != null) {
        header.add(cell);
      }
    }

    final columnMapping = await promptForColumn(header);

    if (columnMapping == null) {
      return;
    }

    final indexes = columnMapping;

    for (final row in sheet.rows.skip(1)) {
      final orderMap = fields.asMap().map((index, field) {
        final value = row[indexes[index]];

        return MapEntry(field, value?.value.toString());
      });

      final order = TeacherOrder.fromMap(orderMap);

      setState(() {
        _orders.add(order);
      });
    }
  }

  Future<bool> deleteAt(int index) async {
    return await context.showConfirmationDialog(
        title: 'Confirm',
        message: 'Are you sure you want to delete this order?',
        onConfirm: () {
          setState(() {
            _orders.removeAt(index);
          });
        },
        confirmText: "Delete");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Order File'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Select an option to load teacher orders',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadFile,
                    child: const Text('Select File'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () async {
                        final order =
                            await Navigator.pushNamed(context, '/manual')
                                as TeacherOrder?;

                        if (order != null) {
                          setState(() {
                            _orders.add(order);
                          });
                        }
                      },
                      child: const Text('Manual Entry')),
                ],
              ),
              const SizedBox(height: 20),
              if (_orders.isNotEmpty) ...[
                Card(
                  child: ListTile(
                      title: const Text('Submit'),
                      subtitle: Text(
                          '${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          Navigator.pop(context, _orders);
                        },
                      )),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Order Details'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      ListTile(
                                        title: const Text('Name'),
                                        subtitle: Text(
                                            order.name ?? 'No name specified'),
                                      ),
                                      ListTile(
                                        title: const Text('Room'),
                                        subtitle: Text(
                                            order.room ?? 'No room specified'),
                                      ),
                                      ListTile(
                                        title: const Text('Additional Items'),
                                        subtitle: Text(order.additional ??
                                            'No additional items specified'),
                                      ),
                                      ListTile(
                                        title: const Text('Frequency'),
                                        subtitle: Text(order.frequency ??
                                            'No frequency specified'),
                                      ),
                                      ListTile(
                                        title: const Text('Creamer'),
                                        subtitle: Text(order.creamer ??
                                            'No creamer specified'),
                                      ),
                                      ListTile(
                                        title: const Text('Sweetener'),
                                        subtitle: Text(order.sweetener ??
                                            'No sweetener specified'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Dismissible(
                          key: Key(order.toString()),
                          confirmDismiss: (direction) async {
                            return await deleteAt(index);
                          },
                          background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.red),
                              child: const Icon(Icons.delete)),
                          child: Card(
                            child: ListTile(
                                title: Text(order.name ?? 'No name specified'),
                                subtitle:
                                    Text(order.room ?? 'No room specified'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    deleteAt(index);
                                  },
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
