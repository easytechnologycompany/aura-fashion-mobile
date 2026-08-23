import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.unitPrice,
    super.salePrice,
  });

  factory WishlistItemModel.fromEntity(WishlistItemEntity entity) {
    return WishlistItemModel(
      productId: entity.productId,
      name: entity.name,
      imageUrl: entity.imageUrl,
      unitPrice: entity.unitPrice,
      salePrice: entity.salePrice,
    );
  }

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      unitPrice: (json['unit_price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'unit_price': unitPrice,
      'sale_price': salePrice,
    };
  }
}
