import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/order/presentation/checkout_page.dart';
import '../../features/order/presentation/order_success_page.dart';
import '../../features/order/presentation/orders_page.dart';
import '../../features/payment/presentation/payment_page.dart';
import '../../features/product/presentation/pages/product_details.dart';
import '../../features/product/presentation/pages/product_list.dart';
import '../widgets/empty_state.dart';

/// Centralised route table for the app.
///
/// Routing is done via [GoRouter] so deep links, redirects and named routes
/// all share the same configuration. The error builder delegates to
/// [EmptyState] to keep a single visual language across "empty" surfaces.
class AppRouter {
  AppRouter._();

  // ---------------------------------------------------------------------------
  // Paths
  // ---------------------------------------------------------------------------

  static const String homePath = '/';
  static const String _productDetailPath = '/product/:id';
  static const String cartPath = '/cart';
  static const String signinPath = '/signin';
  static const String profilePath = '/profile';
  static const String checkoutPath = '/checkout';
  static const String _orderSuccessPath = '/orderSuccess/:orderId';
  static const String ordersPath = '/orders';
  static const String paymentPath = '/payment';

  // ---------------------------------------------------------------------------
  // Route builders (named-route helpers)
  // ---------------------------------------------------------------------------

  static String productDetailRoute(int id) => '/product/$id';
  static String orderSuccessRoute(String orderId) => '/orderSuccess/$orderId';

  // ---------------------------------------------------------------------------
  // Router
  // ---------------------------------------------------------------------------

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        pageBuilder: (context, state) => _fadeThrough(
          state: state,
          child: const ProductListScreen(),
        ),
      ),
      GoRoute(
        path: _productDetailPath,
        name: 'productDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _slideUp(
            state: state,
            child: ProductDetailScreen(productId: int.tryParse(id) ?? 0),
          );
        },
      ),
      GoRoute(
        path: cartPath,
        name: 'cart',
        pageBuilder: (context, state) =>
            _slideUp(state: state, child: const CartScreen()),
      ),
      GoRoute(
        path: signinPath,
        name: 'signin',
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return _slideUp(state: state, child: SignInPage(redirect: redirect));
        },
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        pageBuilder: (context, state) =>
            _slideUp(state: state, child: const ProfilePage()),
      ),
      GoRoute(
        path: checkoutPath,
        name: 'checkout',
        pageBuilder: (context, state) =>
            _slideUp(state: state, child: const CheckoutPage()),
      ),
      GoRoute(
        path: _orderSuccessPath,
        name: 'orderSuccess',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return _fadeThrough(
            state: state,
            child: OrderSuccessPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: ordersPath,
        name: 'orders',
        pageBuilder: (context, state) =>
            _slideUp(state: state, child: const OrdersPage()),
      ),
      GoRoute(
        path: paymentPath,
        name: 'payment',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: PaymentPage(
              paymentUrl: extra['paymentUrl'] as String? ?? '',
              transactionId: extra['transactionId'] as String? ?? '',
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: EmptyState(
        icon: Icons.error_outline,
        title: '404 - Page Not Found',
        message: 'The route "${state.uri.path}" could not be found.',
        actionLabel: 'Back to Catalog',
        onAction: () => context.go(homePath),
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // Page-transition presets
  // ---------------------------------------------------------------------------

  static Page<T> _slideUp<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  static Page<T> _fadeThrough<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}