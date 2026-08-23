import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/remove_address_usecase.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final RemoveAddressUseCase removeAddressUseCase;

  AddressCubit({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.removeAddressUseCase,
  }) : super(const AddressState());

  Future<void> loadAddresses() async {
    final result = await getAddressesUseCase(const NoParams());
    result.fold(
      (_) {},
      (addresses) => emit(state.copyWith(addresses: addresses)),
    );
  }

  Future<void> addAddress(AddressEntity address) async {
    final result = await addAddressUseCase(address);
    result.fold(
      (_) {},
      (addresses) => emit(
        state.copyWith(addresses: addresses, selectedId: address.id),
      ),
    );
  }

  Future<void> removeAddress(String id) async {
    final result = await removeAddressUseCase(id);
    result.fold(
      (_) {},
      (addresses) => emit(
        state.copyWith(
          addresses: addresses,
          selectedId: state.selectedId == id ? null : state.selectedId,
        ),
      ),
    );
  }

  void selectAddress(String id) => emit(state.copyWith(selectedId: id));

  AddressEntity? get selected {
    if (state.selectedId == null) return null;
    for (final address in state.addresses) {
      if (address.id == state.selectedId) return address;
    }
    return null;
  }
}
