import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product/product_bloc.dart';
import '../card_product.dart';
import '../detail_product.dart';
import '../product.dart';
import 'product_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProducts(refresh: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<ProductBloc>().add(SearchProducts(value));
  }

  Future<void> _addProduct() async {
    final bloc = context.read<ProductBloc>();
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );
    if (product == null) return;
    bloc.add(CreateProductEvent(product));
  }

  Future<void> _editProduct(Product product) async {
    final bloc = context.read<ProductBloc>();
    final updated = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (updated == null) return;
    bloc.add(UpdateProductEvent(updated));
  }

  Future<void> _deleteProduct(Product product) async {
    context.read<ProductBloc>().add(DeleteProductEvent(product));
  }

  void _loadMore() {
    context.read<ProductBloc>().add(LoadMoreProducts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        } else if (state is ProductError && state.products.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard produk'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<ProductBloc>().add(FetchProducts(refresh: true)),
              tooltip: 'Muat ulang',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addProduct,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  labelText: 'Cari produk',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(child: _buildProductContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        switch (state) {
          case ProductLoading(:final products, :final hasMore):
            if (products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProductList(products, hasMore, false);

          case ProductLoaded(
              :final products,
              :final hasMore,
              :final loadingMore,
            ):
            if (products.isEmpty) {
              return _StateMessage(message: 'Produk tidak ditemukan');
            }
            return _buildProductList(products, hasMore, loadingMore);

          case ProductError(:final products):
            if (products.isEmpty) {
              return _StateMessage(
                message: 'Produk gagal dimuat',
                actionLabel: 'Coba lagi',
                onAction: () =>
                    context.read<ProductBloc>().add(FetchProducts(refresh: true)),
              );
            }
            return _buildProductList(products, false, false);

          case ProductInitial():
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildProductList(
    List<Product> products,
    bool hasMore,
    bool loadingMore,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductBloc>().add(FetchProducts(refresh: true));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: products.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: loadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _loadMore,
                        child: const Text('Muat lebih banyak'),
                      ),
              ),
            );
          }
          final product = products[index];
          return CardProduct(
            product: product,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailProduct(product: product),
              ),
            ),
            onEdit: () => _editProduct(product),
            onDelete: () => _deleteProduct(product),
          );
        },
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message),
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}
