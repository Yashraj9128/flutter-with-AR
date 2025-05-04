import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:ar_shop/models/product.dart';
import 'package:provider/provider.dart';
import 'package:ar_shop/shared/cart_provider.dart';

class ProductWithAugmentedRealityScreen extends StatelessWidget {
  final Product product;

  const ProductWithAugmentedRealityScreen({Key? key, required this.product}) : super(key: key);

  bool get isARSupported {
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: const Text("Product added to cart successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: product.modelPath,
              alt: "3D model of ${product.name}",
              ar: isARSupported,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).addItem(product);
                    _showAddToCartDialog(context);
                  },
                  icon: const Icon(Icons.shopping_cart_checkout_outlined),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
