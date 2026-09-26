part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FetchProducts extends ProductEvent {
  FetchProducts({this.refresh = false, this.search});

  final bool refresh;
  final String? search;

  @override
  List<Object?> get props => [refresh, search];
}

final class LoadMoreProducts extends ProductEvent {}

final class SearchProducts extends ProductEvent {
  SearchProducts(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CreateProductEvent extends ProductEvent {
  CreateProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class UpdateProductEvent extends ProductEvent {
  UpdateProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class DeleteProductEvent extends ProductEvent {
  DeleteProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}
