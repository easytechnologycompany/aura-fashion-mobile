import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.fullAddress,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'full_address': fullAddress,
      };

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
        id: entity.id,
        label: entity.label,
        fullAddress: entity.fullAddress,
      );
}
