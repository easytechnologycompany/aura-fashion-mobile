import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<List<AddressModel>> addAddress(AddressModel address);
  Future<List<AddressModel>> removeAddress(String id);
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  final SharedPreferences sharedPreferences;

  AddressLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final raw = sharedPreferences.getString(StorageKeys.savedAddresses);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to read saved addresses');
    }
  }

  @override
  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final addresses = await getAddresses();
    addresses.add(address);
    await _persist(addresses);
    return addresses;
  }

  @override
  Future<List<AddressModel>> removeAddress(String id) async {
    final addresses = await getAddresses();
    addresses.removeWhere((a) => a.id == id);
    await _persist(addresses);
    return addresses;
  }

  Future<void> _persist(List<AddressModel> addresses) async {
    try {
      final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
      await sharedPreferences.setString(StorageKeys.savedAddresses, encoded);
    } catch (_) {
      throw const CacheException('Failed to save address');
    }
  }
}
