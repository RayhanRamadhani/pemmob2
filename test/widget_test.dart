// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_coy/main.dart';

void main() {
  testWidgets('menampilkan daftar produk setelah loading', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text('Morning Ceramic Mug'), findsOneWidget);
    expect(find.text('Linen Everyday Tote'), findsOneWidget);
  });

  testWidgets('produk dapat dibuka ke halaman detail', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    await tester.tap(find.text('Morning Ceramic Mug'));
    await tester.pumpAndSettle();

    expect(find.text('Detail produk'), findsOneWidget);
    expect(find.text('Tentang produk'), findsOneWidget);
  });

  testWidgets('form tambah memvalidasi input wajib', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah'));
    await tester.pump();

    await tester.tap(find.text('Simpan produk'));
    await tester.pump();

    expect(find.text('Nama produk wajib diisi'), findsOneWidget);
    expect(find.text('Masukkan harga yang valid'), findsOneWidget);
    expect(find.text('Pilih kategori produk'), findsOneWidget);
    expect(find.text('Deskripsi minimal 10 karakter'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
  });
}
