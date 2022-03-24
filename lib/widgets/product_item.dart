import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
        },
        child: GridTile(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          footer: GridTileBar(
            leading: buildFavoriteButton(context),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: buildCartButton(context, product),
            backgroundColor: Colors.black87,
          ),
        ),
      ),
    );
  }

  IconButton buildCartButton(BuildContext context, Product product) {
    final Cart cart = Provider.of<Cart>(context, listen: false);
    return IconButton(
      onPressed: () {
        cart.addItem(product.id, product.price, product.title);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item added to cart!'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              cart.removeSingleItem(product.id);
            },
          ),
        ));
        // Scaffold.of(context)
        //     .showSnackBar(SnackBar(content: Text('data'))); // Connects to the nearest Scaffold
      },
      icon: Icon(Icons.shopping_cart),
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Consumer<Product> buildFavoriteButton(BuildContext context) {
    final token = Provider.of<Auth>(context).token;
    final userId = Provider.of<Auth>(context).userId;

    return Consumer<Product>(
      builder: (context, product, _) {
        return IconButton(
          onPressed: () => product.toggleFavoriteStatus(token, userId),
          icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
          color: Theme.of(context).colorScheme.secondary,
        );
      },
    );
  }
}
