import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/announcement/data/provider/announcement_provider.dart';
import 'package:island_cafe/feature/announcement/presentation/widget/announcement_card.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/home/data/provider/billboard_provider.dart';
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  int bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Watch the Auth Provider
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    // 2. Get the Display Name (use 'Coffee Lover' as fallback like in Profile)
    final displayName = user?.displayName ?? 'Coffee Lover';

    final billboardsAsync = ref.watch(billboardHompageProvider);
    final announcementAsync = ref.watch(announcementHomepageProvider);
    
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const _BillboardSkeleton(),
            error: (_, __) => _PlaceholderBanner(
              onRetry: () => ref.refresh(billboardProvider),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              // 3. Update the Text string to include the name
              '$greeting, $displayName', 
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
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    icon: Icons.local_cafe,
                    title: 'Pickup',
                    onTap: () {
                      context.pushNamed('/menu');
                    },
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: _ActionCard(
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    icon: Icons.local_shipping,
                    title: 'Delivery',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          content: const Text(
                            'Delivery service is coming soon!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
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
                TextButton(
                  onPressed: () {
                    context.pushNamed('/announcements');
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: announcementAsync.when(
              data: (announcement) {
                if (announcement.isEmpty) {
                  return const Text('No announcements available.');
                }
                return Column(
                  children: [
                    for (var ann in announcement)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnnouncementCard(
                          id: ann.id,
                          type: ann.type,
                          title: ann.title,
                          content: ann.content,
                          image: ann.image,
                        ),
                      ),
                  ],
                );
              },
              error: (_, __) => Column(
                children: [
                  const Text('Failed to load announcements.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.refresh(announcementProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              loading: () => const _AnnouncementSkeleton(),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.0),
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (billboard.link.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  billboard.link,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        ],
      ),
    );
  }
}

class _BillboardSkeleton extends StatelessWidget {
  const _BillboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementSkeleton extends StatelessWidget {
  const _AnnouncementSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
