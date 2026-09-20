import 'package:dio/dio.dart';

import 'product.dart';

class ProductApi {
  ProductApi({Dio? dio}) : _dio = dio ?? Dio();

  static const _baseUrl = 'https://pos.cicd.web.id';
  final Dio _dio;

  Future<ProductPage> getProducts({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/items/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = (body['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return ProductPage(products: data, hasMore: data.length == limit);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/items/products',
      data: product.toJson(),
    );
    return Product.fromJson(_data(response.data));
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) throw Exception('ID produk tidak tersedia');
    final response = await _dio.patch<Map<String, dynamic>>(
      '$_baseUrl/items/products/${product.id}',
      data: product.toJson(),
    );
    return Product.fromJson(_data(response.data));
  }

  Future<void> deleteProduct(Product product) async {
    if (product.id == null) throw Exception('ID produk tidak tersedia');
    await _dio.delete('$_baseUrl/items/products/${product.id}');
  }

  Map<String, dynamic> _data(Map<String, dynamic>? body) {
    final data = body?['data'];
    return data is Map<String, dynamic> ? data : body ?? {};
  }
}

class ProductPage {
  const ProductPage({required this.products, required this.hasMore});

  final List<Product> products;
  final bool hasMore;
}
