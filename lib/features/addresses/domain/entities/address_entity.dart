import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String label;
  final String fullAddress;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
  });

  @override
  List<Object?> get props => [id, label, fullAddress];
}
