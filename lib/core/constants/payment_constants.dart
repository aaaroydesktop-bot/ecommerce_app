/// Sandbox credentials and endpoint configuration for the AmarPay payment
/// gateway integration.
///
/// Keep this isolated from the rest of the app so swapping providers (e.g.
/// SSLCommerz, Stripe) only requires pointing the repository at a new
/// constants class.
class PaymentConstants {
  PaymentConstants._();

  static const String sandboxBaseUrl = 'https://sandbox.aamarpay.com';
  static const String initiateEndpoint = '/jsonpost.php';

  // Amarpay sandbox credentials (Dummy/test values — do NOT use in prod).
  static const String storeId = 'aamarpaytest';
  static const String signatureKey = 'dbb74894e82415a2f7ff0ec3a97e4183';
  static const String defaultCurrency = 'USD';

  // Webhook-style URLs AmarPay redirects to. The mock URLs here are fine
  // because sandbox mode never actually redirects the user agent.
  static const String successUrl = 'https://example.app/payment/success';
  static const String failUrl = 'https://example.app/payment/fail';
  static const String cancelUrl = 'https://example.app/payment/cancel';
}