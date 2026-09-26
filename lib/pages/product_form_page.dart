import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../product.dart';

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
    _category =
        product?.category.isNotEmpty == true ? product!.category : 'Homeware';
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
            validator: (value) =>
                value == null || value.trim().isEmpty
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
            validator: (value) =>
                int.tryParse(value ?? '') == null
                    ? 'Masukan angka yang valid.'
                    : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: const [
              'Homeware',
              'Lifestyle',
              'Fashion',
              'Food',
              'Merchandise',
              'BUKU',
            ]
                .map(
                  (item) => DropdownMenuItem(value: item, child: Text(item)),
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
            validator: (value) =>
                value == null || value.trim().length < 10
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
