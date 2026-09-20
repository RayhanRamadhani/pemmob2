import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_coy/product.dart';

class CardProduct extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.imagePath == null
                    ? Container(
                        width: 76,
                        height: 76,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.file(
                        File(product.imagePath!),
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
                      product.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Rp. ${product.price}', textAlign: TextAlign.left),
                    const SizedBox(height: 4),
                    Text('Stok ${product.quantity}', textAlign: TextAlign.left),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Edit produk',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
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
