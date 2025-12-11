import 'package:flutter/material.dart';
import 'package:island_cafe/feature/home/presentation/widget/home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: HomeContent()),
      bottomSheet: const _CartBar(),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return SafeArea(
      top: false,

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),


          ),



        ),
      ),
    );
  }
}
