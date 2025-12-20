import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
// Make sure to import the new widgets file
import 'package:island_cafe/feature/profile/presentation/widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final isLoggedIn = user != null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => context.push(settingsRoute),
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: isLoggedIn ? _LoggedInView(user: user) : const _GuestView(),
        );
      },
    );
  }
}

// ==========================================
// VIEW 1: GUEST VIEW (Not Logged In)
// ==========================================
class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_cafe_rounded,
              size: 64,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Join the Club!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to track your orders, save your favorites, and get exclusive offers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: () => context.push('/login'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => context.push('/signup'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 60),
          const SectionLabel(text: 'SUPPORT'),
          const SizedBox(height: 12),
          CardGrid(
            surface: Colors.grey[100]!,
            border: Colors.grey[300]!,
            iconColor: Colors.grey[600]!,
            items: [
              CardItem(
                icon: Icons.person_outline,
                label: 'Customer Service',
                onTap: () => showPlatformModal(context),
              ),
              CardItem(
                icon: Icons.storefront_outlined,
                label: 'Find Stores',
                routeName: menuRoute,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// VIEW 2: LOGGED IN VIEW
// ==========================================
class _LoggedInView extends StatelessWidget {
  final User user;
  const _LoggedInView({required this.user});

  @override
  Widget build(BuildContext context) {
    final surface = Colors.grey[100]!;
    final border = Colors.grey[300]!;
    final iconColor = Colors.grey[600]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHero(user: user),
          const SectionLabel(text: 'PERSONAL'),
          const SizedBox(height: 12),
          CardGrid(
            surface: surface,
            border: border,
            iconColor: iconColor,
            items: [
              CardItem(
                icon: Icons.mail_outline,
                label: 'Inbox',
                onTap: () {},
              ),
              CardItem(
                icon: Icons.favorite_border,
                label: 'Favorites',
                onTap: () => context.push(favoritesRoute),
              ),
              CardItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Vouchers',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionLabel(text: 'SHORTCUTS'),
          const SizedBox(height: 12),
          CardGrid(
            surface: surface,
            border: border,
            iconColor: iconColor,
            items: const [
              CardItem(
                icon: Icons.storefront_outlined,
                label: 'Stores',
                routeName: menuRoute,
              ),
              CardItem(
                icon: Icons.campaign_outlined,
                label: 'Announcements',
                routeName: announcementRoute,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionLabel(text: 'CONTACTS'),
          const SizedBox(height: 12),
          CardGrid(
            surface: surface,
            border: border,
            iconColor: iconColor,
            items: [
              CardItem(
                icon: Icons.person_outline,
                label: 'Customer Service',
                onTap: () => showPlatformModal(context),
              ),
              CardItem(
                icon: Icons.edit_note_outlined,
                label: 'Feedback',
                onTap: () => showPlatformModal(context),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SocialsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}