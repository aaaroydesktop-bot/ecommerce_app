import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/demo_accounts.dart';

/// Quick-fill chips that pre-populate the username/password fields with one
/// of the bundled demo accounts.
class DemoAccountsBox extends StatelessWidget {
  const DemoAccountsBox({
    super.key,
    required this.selectedUsername,
    required this.onSelect,
  });

  final String selectedUsername;
  final ValueChanged<DemoAccount> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 16,
                color: scheme.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quick Demo Accounts (Tap to auto-fill)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final account in DemoAccounts.all)
                _DemoAccountChip(
                  account: account,
                  isSelected: account.username == selectedUsername,
                  onTap: () => onSelect(account),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoAccountChip extends StatelessWidget {
  const _DemoAccountChip({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final DemoAccount account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isSelected ? scheme.onPrimary : scheme.onSurface;
    final bg = isSelected ? scheme.primary : scheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.person_crop_circle_fill,
              size: 16,
              color: isSelected ? scheme.onPrimary : scheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              account.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.onPrimary.withValues(alpha: 0.20)
                    : scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                account.role,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? scheme.onPrimary : scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}