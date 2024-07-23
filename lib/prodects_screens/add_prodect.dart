import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;  // Using alias 'path' to avoid conflict

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = path.basename(imageFile.path);  // Using alias 'path'
    Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      String imageUrl = await _uploadImage(_imageFile!);
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'image_url': imageUrl,
      });
      Navigator.pop(context);  // 'context' now correctly refers to BuildContext
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _imageFile == null
                  ? Column(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.image),
                          label: Text('Pick from Gallery'),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.camera),
                          label: Text('Take a Photo'),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ],
                    )
                  : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
