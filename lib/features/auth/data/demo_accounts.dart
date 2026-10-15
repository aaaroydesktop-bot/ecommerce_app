/// Demo account used by the SignInPage.
///
/// This is a typed value object so the UI doesn't have to deal with raw
/// `Map<String, String>` literals and string keys.
class DemoAccount {
  const DemoAccount({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  final String name;
  final String username;
  final String password;
  final String role;
}

/// Catalog of pre-filled demo accounts offered on the SignIn screen. These
/// match the seeded users exposed by DummyJSON so reviewers can sign in
/// without manually typing credentials.
class DemoAccounts {
  DemoAccounts._();

  static const List<DemoAccount> all = [
    DemoAccount(
      name: 'Emily Johnson',
      username: 'emilys',
      password: 'emilyspass',
      role: 'Admin',
    ),
    DemoAccount(
      name: 'Michael Williams',
      username: 'michaelw',
      password: 'michaelwpass',
      role: 'Customer',
    ),
  ];
}