import 'package:flutter/material.dart';

/// Sticky bottom panel showing cart subtotal/tax/total and the primary
/// checkout CTA. Used by [CartScreen] and (conceptually) by any future
/// checkout summary.
class CartSummaryPanel extends StatelessWidget {
  const CartSummaryPanel({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.ctaLabel,
    required this.onCheckout,
  });

  final double subtotal;
  final double tax;
  final double total;
  final String ctaLabel;
  final VoidCallback onCheckout;

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SummaryRow(label: 'Subtotal', value: _money(subtotal)),
              const SizedBox(height: 6),
              _SummaryRow(label: 'Estimated Tax (8%)', value: _money(tax)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _money(total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}