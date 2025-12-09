import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/home/data/provider/billboard_provider.dart';
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  int bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final billboardsAsync = ref.watch(billboardProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    final pageController = PageController(viewportFraction: 1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          billboardsAsync.when(
            data: (billboards) {
              if (billboards.isEmpty) {
                return _PlaceholderBanner(
                  onRetry: () => ref.refresh(billboardProvider),
                );
              }
              return SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: billboards.length,
                      onPageChanged: (i) {
                        setState(() => bannerIndex = i);
                      },
                      itemBuilder: (context, index) {
                        final billboard = billboards[index];
                        return _BillboardSlide(billboard: billboard);
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          billboards.length,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bannerIndex == i
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(top: 40, left: 16, child: _StoreChip()),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _PlaceholderBanner(
              onRetry: () => ref.refresh(billboardProvider),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$greeting, Ah Jm!',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    color: Colors.blue,
                    icon: Icons.local_cafe,
                    title: 'Pickup',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: _ActionCard(
                    color: Colors.blue,
                    icon: Icons.local_shipping,
                    title: 'Delivery',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Announcements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      'https://picsum.photos/seed/coffee/1200/675',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'New menu available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 120,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillboardSlide extends StatelessWidget {
  final Billboard billboard;
  const _BillboardSlide({required this.billboard});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          billboard.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                billboard.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (billboard.link.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  billboard.link,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreChip extends StatelessWidget {
  const _StoreChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'PHERK-COFFEE-STORE',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class _PlaceholderBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _PlaceholderBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
          const Positioned(top: 40, left: 16, child: _StoreChip()),
        ],
      ),
    );
  }
}
