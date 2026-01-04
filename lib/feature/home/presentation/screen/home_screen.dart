import 'package:flutter/material.dart';
import 'package:island_cafe/feature/home/presentation/widget/home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: HomeContent()),
      // bottomSheet: const _CartBar(),
    );
  }
}