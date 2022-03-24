import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formState = GlobalKey<FormState>();
  var isInit = false;
  Product _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;
  var _errorOccured = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty) return;
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) return;
      if (!_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('.jpeg'))
        return;

      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId == null) return;

      _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
      _initValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price.toString(),
        'imageUrl': '',
      };
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    isInit = true;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    if (!_formState.currentState.validate()) return;
    _formState.currentState.save();
    setState(() {
      _isLoading = true;
    });
    bool existingProductEditOccured = _editedProduct.id != null;

    try {
      if (existingProductEditOccured) {
        await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct);
      } else {
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      }

      Navigator.of(context).pop();
    } catch (error) {
      _errorOccured = true;
      return showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occured!'),
                content: Text(error.toString()),
                actions: [
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ));
    } finally {
      if (_errorOccured) {
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl; // Closes AlertDialog
        _errorOccured = false;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _formState,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter a title.';
                            else
                              return null;
                          },
                          decoration: InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: value,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          validator: (value) {
                            if (value.isEmpty || double.tryParse(value) == null)
                              return 'Please enter a valid price.';
                            else if (double.parse(value) <= 0)
                              return 'Please enter a price above 0.';
                            else
                              return null;
                          },
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_descriptionFocusNode);
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                price: double.parse(value),
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter a description.';
                            else
                              return null;
                          },
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: value,
                                imageUrl: _editedProduct.imageUrl);
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration:
                                  BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  final imageUrl =
                                      RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)');

                                  if (!imageUrl.hasMatch(value))
                                    return 'Please enter a valid image URL.';

                                  return null;
                                },
                                decoration: InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                toolbarOptions: ToolbarOptions(
                                    paste: true, selectAll: true, copy: true, cut: true),
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                onFieldSubmitted: (_) => _saveForm,
                                onSaved: (value) {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      isFavorite: _editedProduct.isFavorite,
                                      title: _editedProduct.title,
                                      price: _editedProduct.price,
                                      description: _editedProduct.description,
                                      imageUrl: value);
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            ),
    );
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
