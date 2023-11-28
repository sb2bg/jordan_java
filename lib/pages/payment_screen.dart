import 'package:flutter/material.dart';
import 'package:jhs_pop/util/order.dart';
import 'package:nfc_manager/nfc_manager.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.order});

  final TeacherOrder order;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();

    NfcManager.instance.isAvailable().then((available) {
      if (!available) {
        return;
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          tag.data.forEach((key, value) {
            print('$key: ${value.toString()}');
          });
        },
      );
    });
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.order.name ?? 'No name specified',
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Total: \$${12.34.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 50.0),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(75.0),
                child: Text(
                  'Tap your card to pay',
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Order Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Name'),
                            subtitle:
                                Text(widget.order.name ?? 'No name specified'),
                          ),
                          ListTile(
                            title: const Text('Room'),
                            subtitle:
                                Text(widget.order.room ?? 'No room specified'),
                          ),
                          ListTile(
                            title: const Text('Additional'),
                            subtitle: Text(widget.order.additional ??
                                'No additional specified'),
                          ),
                          ListTile(
                            title: const Text('Frequency'),
                            subtitle: Text(widget.order.frequency ??
                                'No frequency specified'),
                          ),
                          ListTile(
                            title: const Text('Creamer'),
                            subtitle: Text(
                                widget.order.creamer ?? 'No creamer specified'),
                          ),
                          ListTile(
                            title: const Text('Sweetener'),
                            subtitle: Text(widget.order.sweetener ??
                                'No sweetener specified'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('View Order Details')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
