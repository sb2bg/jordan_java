import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      await _loadDataFrame(File(result.files.single.path!));
    }
  }

  Future<void> _loadDataFrame(File file) async {
    final input = file.openRead();

    
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
