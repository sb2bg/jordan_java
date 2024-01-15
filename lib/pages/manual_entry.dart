import 'package:flutter/material.dart';
import 'package:jhs_pop/util/constants.dart';
import 'package:jhs_pop/util/teacher_order.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _additionalController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _creamerController = TextEditingController();
  bool _sweetener = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Teacher Name',
              icon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 2.0),
          TextField(
            controller: _roomController,
            decoration: const InputDecoration(
              hintText: 'Room Number',
              icon: Icon(Icons.room),
            ),
          ),
          const SizedBox(height: 2.0),
          TextField(
            controller: _additionalController,
            decoration: const InputDecoration(
              hintText: 'Additional Information',
              icon: Icon(Icons.info),
            ),
          ),
          const SizedBox(height: 2.0),
          TextField(
            controller: _creamerController,
            decoration: const InputDecoration(
              hintText: 'Creamer',
              icon: Icon(Icons.coffee),
            ),
          ),
          const SizedBox(height: 2.0),
          // dropdown for frequency
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Frequency',
              icon: Icon(Icons.calendar_today),
            ),
            onChanged: (value) {
              setState(() {
                _frequencyController.text = value!;
              });
            },
            items: frequencyOptions
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8.0),
          ListTile(
            leading: Transform.translate(
              offset: const Offset(-15, 0),
              child: const Icon(Icons.coffee),
            ),
            title: Transform.translate(
              offset: const Offset(-15, 0),
              child: const Text('Sweetener'),
            ),
            minLeadingWidth: 0,
            trailing: ToggleButtons(
              constraints: const BoxConstraints(minWidth: 75, minHeight: 40),
              isSelected: [_sweetener, !_sweetener],
              onPressed: (index) {
                setState(() {
                  _sweetener = index == 0;
                });
              },
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: _sweetener ? Colors.green : Colors.red,
              splashColor: _sweetener ? Colors.red : Colors.green,
              highlightColor: Colors.green,
              renderBorder: true,
              borderColor: Colors.black,
              borderWidth: 0.5,
              borderRadius: BorderRadius.circular(10),
              selectedBorderColor: Colors.black,
              children: const [
                Text('Yes'),
                Text('No'),
              ],
            ),
          ),
          const SizedBox(height: 2.0),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _roomController.text.isEmpty ||
                  _additionalController.text.isEmpty ||
                  _frequencyController.text.isEmpty ||
                  _creamerController.text.isEmpty) {
                context.showErrorSnackBar(
                    message: 'Please complete all fields before submitting');

                return;
              }

              Navigator.pop(
                  context,
                  TeacherOrder.fromMap({
                    'name': _nameController.text,
                    'room': _roomController.text,
                    'additional': _additionalController.text,
                    'frequency': _frequencyController.text,
                    'creamer': _creamerController.text,
                    'sweetener': _sweetener ? 'Yes' : 'No',
                  }));
            },
            child: const Text('Create Order'),
          ),
        ],
      ),
    );
  }
}
