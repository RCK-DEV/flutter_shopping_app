import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
        ),
        footer: GridTileBar(
          leading: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.favorite,
            ),
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.shopping_cart,
            ),
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }
}
