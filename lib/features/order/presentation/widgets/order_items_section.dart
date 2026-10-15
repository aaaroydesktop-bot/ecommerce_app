import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../cart/models/cart_item.dart';
import '../../../cart/presentation/widgets/cart_item_tile.dart';

/// Review-list block on the checkout screen showing every cart line that
/// will be charged. Pulled out of CheckoutPage to keep that file focused on
/// orchestration.
class OrderItemsSection extends StatelessWidget {
  const OrderItemsSection({super.key, required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          CartItemTile(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}