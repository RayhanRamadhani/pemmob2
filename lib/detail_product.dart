import 'dart:io';
import 'package:flutter/material.dart';
import 'product.dart';

class DetailProduct extends StatelessWidget {
  const DetailProduct({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (product.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(product.imagePath!),
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 24),
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0B6E69),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPrice(product.price),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Stok: ${product.quantity}',
            style: const TextStyle(color: Color(0xFF0B6E69), fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tentang produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.description),
        ],
      ),
    );
  }
}

String _formatPrice(double price) => 'Rp ${price.toStringAsFixed(0)}';
