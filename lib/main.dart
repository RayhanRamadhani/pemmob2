import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'card_product.dart';
import 'detail_product.dart';
import 'product.dart';
import 'product_api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Koleksi Produk',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E69)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardPage()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Email wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Password wajib diisi'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Masuk'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProductApi _api = ProductApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Product> _products = [];
  int _page = 1;
  static const _pageSize = 10;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (_loadingMore) return;
    if (refresh || _products.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    try {
      final result = await _api.getProducts(
        page: _page,
        limit: _pageSize,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _products = result.products;
        _hasMore = result.hasMore;
        _loading = false;
        _error = null;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message ?? 'Gagal mengambil data produk';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _api.getProducts(
        page: _page + 1,
        limit: _pageSize,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _page++;
        _products.addAll(result.products);
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _loadingMore = false);
        _showError(error);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadProducts(refresh: true);
    });
  }

  Future<void> _addProduct() async {
    final product = await Navigator.of(
      context,
    ).push<Product>(MaterialPageRoute(builder: (_) => const ProductFormPage()));
    if (product == null) return;
    try {
      await _api.createProduct(product);
      await _loadProducts(refresh: true);
      if (mounted) _showMessage('Produk berhasil ditambahkan');
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _editProduct(Product product) async {
    final updated = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (updated == null) return;
    try {
      await _api.updateProduct(updated);
      await _loadProducts(refresh: true);
      if (mounted) _showMessage('Produk berhasil diubah');
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await _api.deleteProduct(product);
      if (!mounted) return;
      setState(() => _products.remove(product));
      _showMessage('Produk berhasil dihapus');
    } catch (error) {
      _showError(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(Object error) {
    if (!mounted) return;
    _showMessage('Terjadi kesalahan: $error');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Dashboard produk'),
      actions: [
        IconButton(
          onPressed: () => _loadProducts(refresh: true),
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
  );

  Widget _buildProductContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _products.isEmpty) {
      return _StateMessage(
        message: 'Produk gagal dimuat',
        actionLabel: 'Coba lagi',
        onAction: () => _loadProducts(refresh: true),
      );
    }
    if (_products.isEmpty) {
      return const _StateMessage(message: 'Produk tidak ditemukan');
    }
    return RefreshIndicator(
      onRefresh: () => _loadProducts(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _loadMore,
                        child: const Text('Muat lebih banyak'),
                      ),
              ),
            );
          }
          final product = _products[index];
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
  const _StateMessage({required this.message, this.actionLabel, this.onAction});

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

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  String _category = 'Homeware';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: product?.quantity.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _category = product?.category.isNotEmpty == true
        ? product!.category
        : 'Homeware';
    _imagePath = product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => _imagePath = image.path);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.product;
    Navigator.pop(
      context,
      Product(
        id: old?.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        quantity: int.parse(_quantityController.text),
        category: _category,
        description: _descriptionController.text.trim(),
        imagePath: _imagePath,
        imageId: old?.imageId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.product == null ? 'Tambah produk' : 'Edit produk'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('Pilih gambar lokal'),
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 12),
            Image.file(File(_imagePath!), height: 180, fit: BoxFit.cover),
          ],
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama produk'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Nama produk wajib diisi'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Harga'),
            validator: (value) =>
                double.tryParse((value ?? '').replaceAll(',', '.')) == null
                ? 'Masukkan harga yang valid'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah'),
            validator: (value) => int.tryParse(value ?? '') == null
                ? 'Masukan angka yang valid.'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items:
                const [
                      'Homeware',
                      'Lifestyle',
                      'Fashion',
                      'Food',
                      'Merchandise',
                      'BUKU',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) =>
                setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
            validator: (value) => value == null || value.trim().length < 10
                ? 'Deskripsi minimal 10 karakter'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Simpan produk'),
          ),
        ],
      ),
    ),
  );
}
