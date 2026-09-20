import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_coy/product.dart';

class CardProduct extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CardProduct({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CardProduct> createState() => _CardProductState();
}

class _CardProductState extends State<CardProduct> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteProduct() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 108,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.product.imagePath == null
                    ? Container(
                        width: 76,
                        height: 76,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.file(
                        File(widget.product.imagePath!),
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp. ${widget.product.price}',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok ${widget.product.quantity}',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onEdit,
                    tooltip: 'Edit produk',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: _deleteProduct,
                    tooltip: 'Hapus produk',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
