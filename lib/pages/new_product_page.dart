import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_android/custom_widgets/custom_progress_dialog.dart';
import 'package:ecom_android/models/purchase_model.dart';
import 'package:ecom_android/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/helper_function.dart';

class NewProductPage extends StatefulWidget {
  static const String routeName = '/new_product';

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  late ProductProvider _productProvider;
  final _formKey = GlobalKey<FormState>();
  String? _category;
  DateTime? _dateTime;
  ProductModel _productModel = ProductModel();
  PurchaseModel _purchaseModel = PurchaseModel(purchaseDate: Timestamp.fromDate(DateTime.now()));
  ImageSource _imageSource = ImageSource.camera;
  String? _imagePath;
  bool isSaving = false;

  void didChangeDependencies() {
    _productProvider = Provider.of<ProductProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProduct,
          )
        ],
      ),
      body: Stack(
        children: [
          if(isSaving) Center(child: CustomProgressDialog(title: 'please wait',),),
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                TextFormField(
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _productModel.name = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  //maxLines: 10,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _productModel.description = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Product Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _purchaseModel.purchasePrice = num.parse(value!);
                  },
                  decoration: InputDecoration(
                    labelText: ' Purchase Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _productModel.price = num.parse(value!);
                  },
                  decoration: InputDecoration(
                    labelText: ' Sale Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _purchaseModel.qty = num.parse(value!);
                  },
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10,),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                   border: OutlineInputBorder(),
                  ),
                  hint: Text('Select Category'),
                  value: _category,
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                  onSaved: (value){
                    _productModel.category = value;
                  },
                  items: _productProvider.categoryList.map((cat) => DropdownMenuItem(
                    child: Text(cat),
                    value: cat,
                  )).toList(),
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                Card(
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          onPressed: _showDatePicker,
                          icon: Icon(Icons.date_range),
                          label: Text('Select Date')
                      ),
                      Text(_dateTime == null ? 'No date chosen' : getFormattedDate(_dateTime!, 'MMM, dd, yyyy')),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2)
                        ),
                        child: _imagePath == null ? Image.asset('images/imageplaceholder.png')
                            : Image.file(File(_imagePath!), width: 100, height: 100, fit: BoxFit.cover,),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Text('Camera'),
                            onPressed: () {
                              _imageSource = ImageSource.camera;
                              _pickImage();
                            },
                          ),
                          SizedBox(width: 10,),
                          ElevatedButton(
                            child: Text('Gallery'),
                            onPressed: () {
                              _imageSource = ImageSource.gallery;
                              _pickImage();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct() async {
    final isConnected = await isConnectedToInternet();
    if(isConnected) {
      if(_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        if (_dateTime == null) {
          showMessage(context, 'Please a select a date');
          return;
        }
        if (_imagePath == null) {
          showMessage(context, 'Please a select an image');
          return;
        }
        setState(() {
          isSaving = true;
        });

        _uploadImageAndSaveProduct();

      }
    }else {
      showMessage(context, 'No internet connection detected.');
    }

  }

  void _showDatePicker() async {
    final dt = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime.now());
    if(dt != null) {
      setState(() {
        _dateTime = dt;
        _purchaseModel.purchaseDate = Timestamp.fromDate(_dateTime!);
      });
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: _imageSource, imageQuality: 60);
    if(pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _uploadImageAndSaveProduct() async {
    final imageName = '${_productModel.name}_${DateTime.now().millisecondsSinceEpoch}';
    _productModel.imageName = imageName;
    final photoref = FirebaseStorage.instance.ref().child('$photoDirectory/$imageName');
    final uploadTask = photoref.putFile(File(_imagePath!));
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    _productModel.imageDownloadUrl = downloadUrl;
    _productProvider.insertNewProduct(_productModel, _purchaseModel)
        .then((value) {
          setState(() {
            isSaving = false;
          });
          Navigator.pop(context);
    }).catchError((erroe){
     showMessage(context, 'Could not save');
    });
  }
}