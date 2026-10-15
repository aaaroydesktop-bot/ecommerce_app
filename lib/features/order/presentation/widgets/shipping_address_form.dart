import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/shipping_address_model.dart';

/// Captures the shipping address during checkout. Pure stateless widget so
/// the parent page owns the controllers and the persistence logic.
class ShippingAddressForm extends StatelessWidget {
  const ShippingAddressForm({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.cityController,
    required this.postalController,
    required this.phoneController,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postalController;
  final TextEditingController phoneController;

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Please enter $label' : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Recipient Full Name',
            prefixIcon: Icon(CupertinoIcons.person, size: 20),
          ),
          validator: (v) => _required(v, 'full name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(
            labelText: 'Street Address',
            prefixIcon: Icon(CupertinoIcons.location, size: 20),
          ),
          validator: (v) => _required(v, 'street address'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(CupertinoIcons.building_2_fill, size: 20),
                ),
                validator: (v) => _required(v, 'city'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: postalController,
                decoration: const InputDecoration(labelText: 'Zip / Postal'),
                validator: (v) => _required(v, 'zip'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contact Phone Number',
            prefixIcon: Icon(CupertinoIcons.phone, size: 20),
          ),
          validator: (v) => _required(v, 'contact phone'),
        ),
      ],
    );
  }

  /// Convenience helper to snapshot the current controllers into the
  /// domain model the OrderProvider persists.
  ShippingAddressModel toModel() => ShippingAddressModel(
        fullName: nameController.text.trim(),
        addressLine: addressController.text.trim(),
        city: cityController.text.trim(),
        postalCode: postalController.text.trim(),
        phone: phoneController.text.trim(),
      );
}