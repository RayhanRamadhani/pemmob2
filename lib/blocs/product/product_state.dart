part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {
  ProductLoading({this.products = const [], this.hasMore = true});

  final List<Product> products;
  final bool hasMore;

  @override
  List<Object?> get props => [products, hasMore];
}

final class ProductLoaded extends ProductState {
  ProductLoaded({
    required this.products,
    required this.hasMore,
    this.loadingMore = false,
    this.searchQuery,
    this.message,
  });

  final List<Product> products;
  final bool hasMore;
  final bool loadingMore;
  final String? searchQuery;
  final String? message;

  @override
  List<Object?> get props => [
    products,
    hasMore,
    loadingMore,
    searchQuery,
    message,
  ];

  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasMore,
    bool? loadingMore,
    String? searchQuery,
    String? message,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      message: message ?? this.message,
    );
  }
}

final class ProductError extends ProductState {
  ProductError(this.message, {this.products = const []});

  final String message;
  final List<Product> products;

  @override
  List<Object?> get props => [message, products];
}
