import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistLocalDataSource {
  Future<List<WishlistItemModel>> getItems();
  Future<List<WishlistItemModel>> addItem(WishlistItemModel item);
  Future<List<WishlistItemModel>> removeItem(String productId);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  final SharedPreferences sharedPreferences;

  WishlistLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<WishlistItemModel>> getItems() async {
    try {
      final raw = sharedPreferences.getString(StorageKeys.wishlistItems);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read wishlist');
    }
  }

  @override
  Future<List<WishlistItemModel>> addItem(WishlistItemModel item) async {
    final items = await getItems();
    if (items.every((i) => i.productId != item.productId)) {
      items.add(item);
      await _persist(items);
    }
    return items;
  }

  @override
  Future<List<WishlistItemModel>> removeItem(String productId) async {
    final items = await getItems();
    items.removeWhere((i) => i.productId == productId);
    await _persist(items);
    return items;
  }

  Future<void> _persist(List<WishlistItemModel> items) async {
    try {
      final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
      await sharedPreferences.setString(StorageKeys.wishlistItems, encoded);
    } catch (_) {
      throw const CacheException('Failed to save wishlist');
    }
  }
}
