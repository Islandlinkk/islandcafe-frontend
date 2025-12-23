import 'package:flutter/material.dart';
import 'package:island_cafe/feature/product/presentation/widget/product_detail_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ProductDetailWidget());
  }
}
