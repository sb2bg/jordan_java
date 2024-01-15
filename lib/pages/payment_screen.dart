import 'package:flutter/material.dart';
import 'package:jhs_pop/util/checkout_order.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/order_aggregator.dart';
import 'package:jhs_pop/util/teacher_order.dart';
import 'package:nfc_manager/nfc_manager.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen(
      {super.key,
      TeacherOrder? teacherOrder,
      Map<CheckoutOrder, int>? checkoutOrder}) {
    orderAggregator = OrderAggregator(
      teacherOrder: teacherOrder,
      checkoutOrder: checkoutOrder,
    );
  }

  late final OrderAggregator orderAggregator;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isComplete = false;

  void completePayment() {
    setState(() {
      _isComplete = true;
    });

    Navigator.pop(context);
  }

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
            // TODO: Handle tag data
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
              widget.orderAggregator.name,
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Total: \$${widget.orderAggregator.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 50.0),
            _isComplete
                ? Container() // TODO: This should trigger into an animation of a checkmark
                : const Card(
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
                  showOrderDialog(widget.orderAggregator.fields,
                      widget.orderAggregator.price);
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

  void showOrderDialog(Map<String, dynamic> fields, double price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Total'),
              subtitle: Text('\$${price.toStringAsFixed(2)}'),
            ),
            ...fields.entries
                .map(
                  (e) => ListTile(
                    title: Text(e.key.capitalize()),
                    subtitle: Text(e.value.toString()),
                  ),
                )
                .toList()
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
  }
}
