import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.total});

  final double total;

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
              'Total: \$${widget.total.toStringAsFixed(2)}',
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
            ElevatedButton(
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
