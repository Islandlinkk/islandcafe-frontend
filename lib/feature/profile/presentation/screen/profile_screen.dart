import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/profile/presentation/widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: ProfileColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: ProfileColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: ProfileColors.textDark),
      ),
      body: isLoggedIn
          ? _buildUserProfile(context, user)
          : _buildGuestView(context),
    );
  }
  Widget _buildUserProfile(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          ProfileHeaderCard(
            photoUrl: user.photoURL,
            name: user.displayName ?? 'Coffee Lover',
            email: user.email ?? '',
            onEditTap: () => context.push('/user-info'),
          ),

          const SizedBox(height: 24),

          const ProfileSectionTitle(title: 'My Account'),
          ProfileMenuCard(
            children: [
              ProfileMenuItem(
                icon: Icons.history_rounded,
                text: 'Order History',
                onTap: () => context.push('/history'),
              ),
              ProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                text: 'Favorites',
                onTap: () {}, // TODO: Add Favorites Route
              ),
              ProfileMenuItem(
                icon: Icons.location_on_outlined,
                text: 'Saved Addresses',
                onTap: () {}, // TODO: Add Address Route
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const ProfileSectionTitle(title: 'Settings & Support'),
          ProfileMenuCard(
            children: [
              ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                text: 'Notifications',
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                text: 'Help & Support',
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                text: 'Privacy Policy',
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ProfileColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.coffee_rounded,
                size: 64,
                color: ProfileColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Join the Club!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ProfileColors.textDark,
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
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProfileColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sign In',
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
                  side: const BorderSide(
                    color: ProfileColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: ProfileColors.primary,
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await AuthService.signOut();
    }
  }
}
