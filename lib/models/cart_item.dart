import 'watch.dart';

class CartItem {
  final Watch watch;
  int quantity;

  CartItem({
    required this.watch,
    this.quantity = 1,
  });

  double get totalPrice => watch.price * quantity;

  void updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      quantity = newQuantity;
    }
  }
}
