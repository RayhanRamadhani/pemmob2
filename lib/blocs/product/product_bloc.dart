import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../product.dart';
import '../../product_api.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({required ProductApi productApi})
    : _productApi = productApi,
      super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<SearchProducts>(_onSearchProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  final ProductApi _productApi;
  Timer? _searchDebounce;

  int _page = 1;
  static const int _pageSize = 10;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (event.refresh || state is ProductInitial) {
      _page = 1;
      emit(
        ProductLoading(
          products: state is ProductLoaded
              ? (state as ProductLoaded).products
              : [],
          hasMore: true,
        ),
      );
    } else if (state is ProductLoaded && (state as ProductLoaded).loadingMore) {
      return;
    }

    try {
      final result = await _productApi.getProducts(
        page: _page,
        limit: _pageSize,
        search: event.search ?? '',
      );
      emit(
        ProductLoaded(
          products: result.products,
          hasMore: result.hasMore,
          searchQuery: event.search,
        ),
      );
    } on DioException catch (e) {
      _emitError(emit, e.message ?? 'Gagal mengambil data produk');
    } catch (e) {
      _emitError(emit, e.toString());
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductLoaded ||
        !currentState.hasMore ||
        currentState.loadingMore) {
      return;
    }

    emit(currentState.copyWith(loadingMore: true));

    try {
      final result = await _productApi.getProducts(
        page: _page + 1,
        limit: _pageSize,
        search: currentState.searchQuery ?? '',
      );
      _page++;
      emit(
        ProductLoaded(
          products: [...currentState.products, ...result.products],
          hasMore: result.hasMore,
          searchQuery: currentState.searchQuery,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(loadingMore: false));
      rethrow;
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      add(FetchProducts(refresh: true, search: event.query));
    });
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productApi.createProduct(event.product);
      add(FetchProducts(refresh: true));
      if (state is ProductLoaded) {
        emit(
          (state as ProductLoaded).copyWith(
            message: 'Produk berhasil ditambahkan',
          ),
        );
      }
    } catch (e) {
      _emitError(emit, e.toString());
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productApi.updateProduct(event.product);
      add(FetchProducts(refresh: true));
      if (state is ProductLoaded) {
        emit(
          (state as ProductLoaded).copyWith(message: 'Produk berhasil diubah'),
        );
      }
    } catch (e) {
      _emitError(emit, e.toString());
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productApi.deleteProduct(event.product);
      final currentState = state;
      if (currentState is ProductLoaded) {
        final updatedProducts = currentState.products
            .where((p) => p.id != event.product.id)
            .toList();
        emit(
          currentState.copyWith(
            products: updatedProducts,
            message: 'Produk berhasil dihapus',
          ),
        );
      }
    } catch (e) {
      _emitError(emit, e.toString());
    }
  }

  void _emitError(Emitter<ProductState> emit, String message) {
    final products = state is ProductLoaded
        ? (state as ProductLoaded).products
        : <Product>[];
    emit(ProductError(message, products: products));
  }
}
