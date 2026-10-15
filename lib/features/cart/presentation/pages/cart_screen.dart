import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../models/sync_status.dart';
import '../../provider/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_panel.dart';
import '../widgets/cart_sync_indicator.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _handleProceedCheckout(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Please sign in to proceed to checkout'),
            action: SnackBarAction(
              label: 'Sign In',
              onPressed: () => context.push(AppRouter.signinPath),
            ),
          ),
        );
      return;
    }

    context.push(AppRouter.checkoutPath);
  }

  void _confirmClear(BuildContext context, CartProvider cartProvider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          const CartSyncIndicator(),
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.trash),
              tooltip: 'Clear Cart',
              onPressed: () => _confirmClear(context, cartProvider),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.cart,
              title: 'Your cart is empty',
              message:
                  "Looks like you haven't added any items to your cart yet.",
              actionLabel: 'Start Shopping',
              onAction: () => context.go('/'),
            )
          : _CartList(cartProvider: cartProvider),
      bottomNavigationBar: cartProvider.items.isEmpty
          ? null
          : CartSummaryPanel(
              subtotal: cartProvider.subtotal,
              tax: cartProvider.tax,
              total: cartProvider.total,
              ctaLabel: 'Proceed to Checkout',
              onCheckout: () => _handleProceedCheckout(context),
            ),
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        if (cartProvider.syncStatus == SyncStatus.offline)
          _OfflineBanner(cartProvider: cartProvider),
        Expanded(
          child: RefreshIndicator(
            onRefresh: cartProvider.syncNow,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartProvider.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) =>
                      cartProvider.removeItem(item.product.id),
                  child: CartItemTile(item: item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Container(
      color: semantic.ratingStar.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.wifi_slash,
            size: 16,
            color: semantic.ratingStar,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Working offline. Changes will sync when online.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: cartProvider.syncNow,
            child: const Text('Sync', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}