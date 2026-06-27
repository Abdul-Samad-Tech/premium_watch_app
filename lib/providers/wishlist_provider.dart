import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watch.dart';

class WishlistProvider with ChangeNotifier {
  final List<Watch> _wishlist = [];
  final Set<String> _savedWishlistIds = <String>{};
  List<Watch> get wishlist => _wishlist;

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    _savedWishlistIds
      ..clear()
      ..addAll(prefs.getStringList('wishlist') ?? []);
    _wishlist.removeWhere((watch) => !_savedWishlistIds.contains(watch.id));
    notifyListeners();
  }

  void syncWithCatalog(List<Watch> watches) {
    if (_savedWishlistIds.isEmpty) return;
    final hydratedWishlist = watches
        .where((watch) => _savedWishlistIds.contains(watch.id))
        .toList();

    if (hydratedWishlist.length != _wishlist.length ||
        !_wishlist.every((item) => hydratedWishlist.any((w) => w.id == item.id))) {
      _wishlist
        ..clear()
        ..addAll(hydratedWishlist);
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Watch watch) async {
    if (!_wishlist.any((w) => w.id == watch.id)) {
      _wishlist.add(watch);
      _savedWishlistIds.add(watch.id);
      await _saveWishlist();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String watchId) async {
    _wishlist.removeWhere((watch) => watch.id == watchId);
    _savedWishlistIds.remove(watchId);
    await _saveWishlist();
    notifyListeners();
  }

  bool isInWishlist(String watchId) {
    return _wishlist.any((watch) => watch.id == watchId);
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', _savedWishlistIds.toList());
  }

  int get itemCount => _wishlist.length;

  void clearWishlist() {
    _wishlist.clear();
    _savedWishlistIds.clear();
    _saveWishlist();
    notifyListeners();
  }
}
