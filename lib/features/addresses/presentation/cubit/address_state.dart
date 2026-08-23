part of 'address_cubit.dart';

class AddressState extends Equatable {
  final List<AddressEntity> addresses;
  final String? selectedId;

  const AddressState({this.addresses = const [], this.selectedId});

  AddressState copyWith({
    List<AddressEntity>? addresses,
    // Distinguishes "leave selectedId as-is" (omitted) from "set it to
    // null" (explicit) — a plain `String? selectedId` param can't tell
    // those apart since both look like "no value passed".
    Object? selectedId = _unset,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedId: identical(selectedId, _unset)
          ? this.selectedId
          : selectedId as String?,
    );
  }

  @override
  List<Object?> get props => [addresses, selectedId];
}

const _unset = Object();
