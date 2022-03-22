import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> products = Provider.of<Products>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: Platform.isAndroid
          ? RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                      children: products.map((product) {
                    return UserProductItem(product.id, product.title, product.imageUrl);
                  }).toList()),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(8),
              child: CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: () => _refreshProducts(context)),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(((context, index) {
                    return UserProductItem(
                        products[index].id, products[index].title, products[index].imageUrl);
                  }), childCount: products.length))
                ],
              ),
            ),
    );
  }
}
