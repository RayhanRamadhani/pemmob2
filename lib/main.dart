import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'detail_product.dart';
import 'dummy_product.dart';
import 'card_product.dart';
import 'product.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
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
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _products = List.from(dummyProducts);
  String _query = '';

  List<Product> get _filteredProducts => _products.where((product) {
    final query = _query.toLowerCase();
    return product.name.toLowerCase().contains(query) ||
        product.category.toLowerCase().contains(query);
  }).toList();

  Future<void> _addProduct() async {
    final product = await Navigator.of(
      context,
    ).push<Product>(MaterialPageRoute(builder: (_) => const AddProductPage()));
    if (product == null || !mounted) return;
    setState(() => _products.insert(0, product));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

  Future<void> _editProduct(Product product) async {
    final updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => AddProductPage(product: product)),
    );
    if (updatedProduct == null || !mounted) return;
    final index = _products.indexOf(product);
    if (index >= 0) setState(() => _products[index] = updatedProduct);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil diubah')));
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi produk')),
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
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                labelText: 'Cari produk',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('Produk tidak ditemukan'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) => CardProduct(
                      product: products[index],
                      onEdit: () => _editProduct(products[index]),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailProduct(product: products[index]),
                        ),
                      ),
                      onDelete: () =>
                          setState(() => _products.remove(products[index])),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, this.product});

  final Product? product;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Homeware';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) return;
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = product.description;
    _category = product.category;
    _imagePath = product.imagePath;
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
    Navigator.pop(
      context,
      Product(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        quantity: int.parse(_quantityController.text),
        category: _category,
        description: _descriptionController.text.trim(),
        imagePath: _imagePath,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(_imagePath!),
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
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
            decoration: const InputDecoration(
              labelText: 'Harga',
              prefixText: 'Rp. ',
            ),
            validator: (value) =>
                double.tryParse((value ?? '').replaceAll(',', '.')) == null
                ? 'Masukkan harga yang valid'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Jumlah'),
            validator: (value) => int.tryParse((value ?? '')) == null
                ? 'Masukan angka yang valid.'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: const ['Homeware', 'Lifestyle', 'Fashion', 'Food']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
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
