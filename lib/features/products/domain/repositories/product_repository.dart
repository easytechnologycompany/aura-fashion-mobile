import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

class PaginatedProducts {
  final List<ProductEntity> products;
  final int total;

  const PaginatedProducts({required this.products, required this.total});
}

abstract class ProductRepository {
  Future<Either<Failure, PaginatedProducts>> getProducts({
    int offset = 0,
    int limit = 20,
    String? categoryId,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
