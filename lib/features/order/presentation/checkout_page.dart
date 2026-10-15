import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../auth/provider/auth_provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../../payment/models/payment_result.dart';
import '../models/payment_method.dart';
import '../models/shipping_address_model.dart';
import '../providers/order_provider.dart';
import 'widgets/order_items_section.dart';
import 'widgets/payment_option.dart';
import 'widgets/shipping_address_form.dart';

/// Checkout screen.
///
/// The page itself is just orchestration — it owns the form state and the
/// place-order pipeline; every visual block (address form, items, payment
/// picker, summary) lives under `widgets/`.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthProvider>().user;
    final initialAddress = context
        .read<OrderProvider>()
        .getInitialShippingAddress(authUser);

    _nameController = TextEditingController(text: initialAddress.fullName);
    _addressController.text = initialAddress.addressLine;
    _cityController.text = initialAddress.city;
    _postalController.text = initialAddress.postalCode;
    _phoneController.text = initialAddress.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Order placement pipeline
  // ---------------------------------------------------------------------------

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = context.read<CartProvider>();
    if (cartProvider.items.isEmpty) {
      _showSnack('Your cart is empty.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final address = _buildAddress();

    final txn = await _processPayment(
      cartProvider: cartProvider,
      orderProvider: orderProvider,
      authProvider: authProvider,
      address: address,
    );

    if (txn == null || !mounted) return;

    await _submitOrder(
      cartProvider: cartProvider,
      orderProvider: orderProvider,
      authProvider: authProvider,
      address: address,
      paymentStatus: txn.status,
      transactionId: txn.transactionId,
    );
  }

  ShippingAddressModel _buildAddress() => ShippingAddressModel(
        fullName: _nameController.text.trim(),
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalController.text.trim(),
        phone: _phoneController.text.trim(),
      );

  Future<_PaymentOutcome?> _processPayment({
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
    required AuthProvider authProvider,
    required ShippingAddressModel address,
  }) async {
    if (orderProvider.selectedPaymentMethod != PaymentMethod.amarpay) {
      // Cash-on-delivery path: no gateway call.
      return const _PaymentOutcome(status: 'pending', transactionId: null);
    }

    final txnId = orderProvider.generateTransactionId();
    try {
      final paymentUrl = await orderProvider.initiateAmarpayPayment(
        transactionId: txnId,
        amount: cartProvider.total,
        address: address,
        user: authProvider.user,
      );
      if (!mounted) return null;

      final result = await context.push<PaymentResult>(
        AppRouter.paymentPath,
        extra: {'paymentUrl': paymentUrl, 'transactionId': txnId},
      );
      if (!mounted) return null;

      if (result == null || result.status == PaymentStatus.cancelled) {
        _showSnack('Payment cancelled or failed.', isError: true);
        return null;
      }
      if (result.status == PaymentStatus.failed) {
        _showSnack('Payment failed at gateway.', isError: true);
        return null;
      }
      return _PaymentOutcome(
        status: 'paid',
        transactionId: result.transactionId ?? txnId,
      );
    } catch (e) {
      if (!mounted) return null;
      _showSnack('Failed to initiate payment gateway: $e', isError: true);
      return null;
    }
  }

  Future<void> _submitOrder({
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
    required AuthProvider authProvider,
    required ShippingAddressModel address,
    required String paymentStatus,
    required String? transactionId,
  }) async {
    final placedOrder = await orderProvider.placeOrder(
      items: cartProvider.items,
      subtotal: cartProvider.subtotal,
      tax: cartProvider.tax,
      total: cartProvider.total,
      shippingAddress: address,
      paymentStatus: paymentStatus,
      transactionId: transactionId,
      user: authProvider.user,
    );

    if (!mounted) return;

    if (placedOrder != null) {
      await cartProvider.clearCart();
      if (mounted) context.go(AppRouter.orderSuccessRoute(placedOrder.id));
    } else {
      _showSnack(
        orderProvider.errorMessage ?? 'Failed to place order',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _buildBody(context, cartProvider, orderProvider),
      bottomNavigationBar: cartProvider.items.isEmpty
          ? null
          : _buildPlaceOrderButton(orderProvider),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartProvider cartProvider,
    OrderProvider orderProvider,
  ) {
    if (cartProvider.items.isEmpty && !orderProvider.isSubmitting) {
      return EmptyState(
        icon: CupertinoIcons.cart_badge_minus,
        title: 'No items to checkout',
        message: 'Add a product to your cart to start an order.',
        actionLabel: 'Return to Shop',
        onAction: () => context.go('/'),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressSection(),
          const SizedBox(height: 24),
          _buildItemsSection(cartProvider),
          const SizedBox(height: 24),
          _buildPaymentSection(context, orderProvider),
          const SizedBox(height: 24),
          _buildOrderSummarySection(context, cartProvider),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Shipping Address',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ShippingAddressForm(
              nameController: _nameController,
              addressController: _addressController,
              cityController: _cityController,
              postalController: _postalController,
              phoneController: _phoneController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Items (${cartProvider.itemCount})',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: OrderItemsSection(items: cartProvider.items),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context, OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Payment Method',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final method in PaymentMethod.values)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: method == PaymentMethod.values.last ? 0 : 8,
                    ),
                    child: PaymentOption(
                      method: method,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      currentSelection: orderProvider.selectedPaymentMethod,
                      onSelect: orderProvider.updateSelectedPaymentMethod,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Order Summary',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow(
                  'Items (${cartProvider.itemCount})',
                  '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  'Estimated Tax (8%)',
                  '\$${cartProvider.tax.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Standard Shipping',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'FREE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        Text(value),
      ],
    );
  }

  Widget _buildPlaceOrderButton(OrderProvider orderProvider) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: orderProvider.isSubmitting ? null : _handlePlaceOrder,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: orderProvider.isSubmitting
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Placing order…'),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_seal, size: 18),
                    SizedBox(width: 8),
                    Text('Place Order'),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PaymentOutcome {
  const _PaymentOutcome({required this.status, required this.transactionId});

  final String status;
  final String? transactionId;
}