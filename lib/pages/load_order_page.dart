import 'dart:convert';
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

  List<int> promptForColumn(List<dynamic> row) {
    final columns = row.asMap().entries.map((e) => '${e.key}: ${e.value}');

    return [0, 1, 2, 3, 4];
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

    final [name, room, preferences, price, quantity] =
        promptForColumn(sheet.rows.first);

    for (final row in sheet.rows.skip(1)) {
      final order = TeacherOrder(
        name: row[name]!.toString(),
        room: row[room]!.toString(),
        preferences: row[preferences]!.toString(),
        price: double.parse(row[price]!.toString()),
        quantity: int.parse(row[quantity]!.toString()),
      );

      setState(() {
        _orders.add(order);
      });
    }
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
              ElevatedButton(
                onPressed: _loadFile,
                child: const Text('Load Order File'),
              ),
              const SizedBox(height: 20),
              if (_orders.isNotEmpty) ...[
                Card(
                  child: ListTile(
                    title: const Text('Preview'),
                    subtitle: Text(
                        '${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'}'),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      return Card(
                        child: ListTile(
                          title: Text('${order.name} - ${order.room}'),
                          subtitle: Text(order.preferences),
                          trailing: Text('\$${order.price}'),
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
