import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getItems();
  Future<List<CartItemModel>> addItem(CartItemModel item);
  Future<List<CartItemModel>> updateQuantity(String productId, int quantity);
  Future<List<CartItemModel>> removeItem(String productId);
  Future<void> clear();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<CartItemModel>> getItems() async {
    try {
      final raw = sharedPreferences.getString(StorageKeys.cartItems);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read cart');
    }
  }

  @override
  Future<List<CartItemModel>> addItem(CartItemModel item) async {
    final items = await getItems();
    final existingIndex = items.indexWhere((i) => i.productId == item.productId);

    if (existingIndex == -1) {
      items.add(
        CartItemModel.fromEntity(
          item.copyWith(quantity: min(item.quantity, item.availableStock)),
        ),
      );
    } else {
      final existing = items[existingIndex];
      final mergedQuantity = min(
        existing.quantity + item.quantity,
        existing.availableStock,
      );
      items[existingIndex] = CartItemModel.fromEntity(
        existing.copyWith(quantity: mergedQuantity),
      );
    }

    await _persist(items);
    return items;
  }

  @override
  Future<List<CartItemModel>> updateQuantity(String productId, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return items;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      final clamped = min(quantity, items[index].availableStock);
      items[index] = CartItemModel.fromEntity(items[index].copyWith(quantity: clamped));
    }

    await _persist(items);
    return items;
  }

  @override
  Future<List<CartItemModel>> removeItem(String productId) async {
    final items = await getItems();
    items.removeWhere((i) => i.productId == productId);
    await _persist(items);
    return items;
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.remove(StorageKeys.cartItems);
  }

  Future<void> _persist(List<CartItemModel> items) async {
    try {
      final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
      await sharedPreferences.setString(StorageKeys.cartItems, encoded);
    } catch (_) {
      throw const CacheException('Failed to save cart');
    }
  }
}
