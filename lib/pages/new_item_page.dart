import 'package:flutter/material.dart';
import 'package:jhs_pop/util/constants.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

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
              hintText: 'Name',
              icon: Icon(Icons.shopping_bag),
            ),
          ),
          const SizedBox(height: 2.0),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description',
              icon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 2.0),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: _priceController,
            decoration: const InputDecoration(
              hintText: 'Price',
              icon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 2.0),
          TextButton.icon(
            onPressed: () async {
              // final image = await context.pickImage();

              // if (image == null) {
              //   return;
              // }

              // _imageController.text = image.path;
            },
            icon: const Icon(Icons.image),
            label: const Text('Select Image'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _descriptionController.text.isEmpty ||
                  _priceController.text.isEmpty) {
                context.showErrorSnackBar(
                    message: 'Please complete all fields before submitting');

                return;
              }

              try {
                double.parse(_priceController.text);
              } catch (e) {
                context.showErrorSnackBar(
                    message: 'Please enter a valid price');
                return;
              }

              Navigator.pop(context, {
                'name': _nameController.text,
                'description': _descriptionController.text,
                'price': double.parse(_priceController.text),
                'image': 'https://picsum.photos/200',
              });
            },
            child: const Text('Add Item to Store'),
          ),
        ],
      ),
    );
  }
}
