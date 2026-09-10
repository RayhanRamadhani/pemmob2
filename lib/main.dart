import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koleksi',
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E7E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0B6E69), width: 2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Product {
  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
  });
  final String name;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
}

class ProductRepository {
  Future<List<Product>> loadProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    return [
      Product(
        name: 'Morning Ceramic Mug',
        price: 125000,
        category: 'Homeware',
        description:
            'Cangkir keramik hangat dengan bentuk minimalis untuk ritual pagi.',
        imageUrl:
            'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=900',
      ),
      Product(
        name: 'Linen Everyday Tote',
        price: 189000,
        category: 'Lifestyle',
        description:
            'Tas linen ringan dengan ruang luas untuk menemani aktivitas harian.',
        imageUrl:
            'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=900',
      ),
      Product(
        name: 'Terracotta Plant Pot',
        price: 99000,
        category: 'Homeware',
        description:
            'Pot terracotta bertekstur natural untuk memberi aksen hijau di rumah.',
        imageUrl:
            'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=900',
      ),
    ];
  }

  Future<void> addProduct(Product product) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (product.name.toLowerCase().contains('error'))
      throw Exception('Produk gagal disimpan. Coba gunakan nama lain.');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductRepository _repository = ProductRepository();
  int _selectedIndex = 0;
  late Future<List<Product>> _productsFuture;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final products = await _repository.loadProducts();
    if (mounted) setState(() => _products = products);
    return products;
  }

  void _showProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  Future<void> _saveProduct(Product product) async {
    await _repository.addProduct(product);
    if (!mounted) return;
    setState(() {
      _products = [product, ..._products];
      _selectedIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ProductListPage(
            productsFuture: _productsFuture,
            products: _products,
            onProductTap: _showProductDetail,
            onAddProduct: () => setState(() => _selectedIndex = 1),
            onRetry: () => setState(() => _productsFuture = _loadProducts()),
          ),
          AddProductPage(onSave: _saveProduct),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Tambah',
          ),
        ],
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  const ProductListPage({
    super.key,
    required this.productsFuture,
    required this.products,
    required this.onProductTap,
    required this.onAddProduct,
    required this.onRetry,
  });
  final Future<List<Product>> productsFuture;
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onAddProduct;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KOLEKSI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Color(0xFF0B6E69),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Temukan yang kamu suka',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: onAddProduct,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Product>>(
            future: productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  products.isEmpty)
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              if (snapshot.hasError && products.isEmpty)
                return SliverFillRemaining(
                  child: _ErrorState(onRetry: onRetry),
                );
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                sliver: SliverList.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onTap: () => onProductTap(products[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(url: product.imageUrl, height: 190),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Color(0xFF0B6E69),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail produk'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          ProductImage(url: product.imageUrl, height: 300),
          const SizedBox(height: 24),
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B6E69),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            _formatPrice(product.price),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 26),
          const Text(
            'Tentang produk',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, required this.onSave});
  final Future<void> Function(Product product) onSave;
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        Product(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.replaceAll(',', '.')),
          description: _descriptionController.text.trim(),
          category: _category!,
          imageUrl:
              'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?w=900',
        ),
      );
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() => _category = null);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        children: [
          const Text(
            'TAMBAH PRODUK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Color(0xFF0B6E69),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Buat koleksi baru',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama produk',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama produk wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final price = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return price == null || price <= 0
                        ? 'Masukkan harga yang valid'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const ['Homeware', 'Lifestyle', 'Fashion', 'Food']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value),
                  validator: (value) =>
                      value == null ? 'Pilih kategori produk' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 64),
                      child: Icon(Icons.notes_outlined),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 10
                      ? 'Deskripsi minimal 10 karakter'
                      : null,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan produk'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, required this.height});
  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFDCE9E5),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 42,
              color: Color(0xFF0B6E69),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 42),
        const SizedBox(height: 12),
        const Text('Produk gagal dimuat'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );
}

String _formatPrice(double price) =>
    'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '.')}';
