import 'package:flutter_riverpod/legacy.dart';

final selectedPickupTimeProvider = StateProvider<String>((ref) => '30 min');
final selectedPaymentMethodProvider = StateProvider<String>((ref) => 'Cash on Pickup');
