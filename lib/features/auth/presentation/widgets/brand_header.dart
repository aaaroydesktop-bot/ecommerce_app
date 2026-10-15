import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Brand header shown on the SignInPage (and any future auth/marketing
/// screens). Centralises the logo mark + welcome copy so theming tweaks
/// only happen in one place.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.title = 'Welcome to Evira',
    this.subtitle = 'Sign in to sync your cart, orders, and favorites',
    this.logoSize = 36,
  });

  final String title;
  final String subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              CupertinoIcons.bag_fill,
              color: scheme.onPrimary,
              size: logoSize,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}