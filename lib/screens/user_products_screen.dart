import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
          future: _refreshProducts(context), // fetches data on load
          builder: (ctx, snapshot) {
            return Consumer<Products>(builder: (ctx, products, _) {
              // listener attached every time after data is fetched
              return snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : products.items.length == 0
                      ? Center(child: Text('No products yet.'))
                      : Platform.isAndroid
                          ? RefreshIndicator(
                              onRefresh: () => _refreshProducts(context),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: ListView.builder(
                                    itemCount: products.items.length,
                                    itemBuilder: ((context, index) {
                                      return Column(
                                        children: [
                                          UserProductItem(
                                              products.items[index].id,
                                              products.items[index].title,
                                              products.items[index].imageUrl)
                                        ],
                                      );
                                    })),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(8),
                              child: CustomScrollView(
                                slivers: [
                                  CupertinoSliverRefreshControl(
                                      onRefresh: () => _refreshProducts(context)),
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(((context, index) {
                                    return UserProductItem(
                                        products.items[index].id,
                                        products.items[index].title,
                                        products.items[index].imageUrl);
                                  }), childCount: products.items.length))
                                ],
                              ),
                            );
            });
          }),
    );
  }
}
