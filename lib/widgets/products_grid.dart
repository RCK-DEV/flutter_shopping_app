import 'package:flutter/material.dart';
import 'package:flutter_shopping_app/providers/products.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _isFavorite;

  ProductsGrid(this._isFavorite);

  @override
  Widget build(BuildContext context) {
    final Products productsData = Provider.of<Products>(context);
    final List<Product> products = _isFavorite
        ? productsData.items.where((product) => product.isFavorite).toList()
        : productsData.items;

    return _buildGridView(products);
  }

  GridView _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      // Here i added a nested Provider of Product (not Products) to
      // listen to updates for a single product. For example when the isFavorite
      // field is changed. This is not tracked inside the Products provider.
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
    );
  }
}
