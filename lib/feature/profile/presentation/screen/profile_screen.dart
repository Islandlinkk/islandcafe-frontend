import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<bool> _loggedIn = ValueNotifier<bool>(false);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Colors.grey[100]!;
    final border = Colors.grey[300]!;
    final iconColor = Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
              child: Row(
                children: [
                  const Spacer(),
                  // const Text(
                  //   'ACCOUNT',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  // ),
                  const Spacer(),
                  ValueListenableBuilder<bool>(
                    valueListenable: _loggedIn,
                    builder: (context, isLoggedIn, _) {
                      if (isLoggedIn) {
                        return const SizedBox(width: 48);
                      }
                      return FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _showLoginBottomSheet(context),
                        child: const Text('Log In'),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.push(settingsRoute),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _loggedIn,
                      builder: (context, isLoggedIn, _) {
                        if (!isLoggedIn) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ProfileHero(),
                            const _SectionLabel(text: 'PERSONAL'),
                            const SizedBox(height: 12),
                            _CardGrid(
                              surface: surface,
                              border: border,
                              iconColor: iconColor,
                              items: [
                                _CardItem(
                                  icon: Icons.mail_outline,
                                  label: 'Inbox',
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text('Inbox coming soon'))),
                                ),
                                _CardItem(
                                  icon: Icons.tune,
                                  label: 'Personalization',
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content:
                                              Text('Personalization coming soon'))),
                                ),
                                _CardItem(
                                  icon: Icons.favorite_border,
                                  label: 'Favorites',
                                  onTap: () => context.push(favoritesRoute),
                                ),
                                _CardItem(
                                  icon: Icons.confirmation_number_outlined,
                                  label: 'Vouchers',
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text('Vouchers coming soon'))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                    const _SectionLabel(text: 'SHORTCUTS'),
                    const SizedBox(height: 12),
                    _CardGrid(
                      surface: surface,
                      border: border,
                      iconColor: iconColor,
                      items: const [
                        _CardItem(
                          icon: Icons.storefront_outlined,
                          label: 'Stores',
                          routeName: menuRoute,
                        ),
                        _CardItem(
                          icon: Icons.campaign_outlined,
                          label: 'Announcements',
                          routeName: announcementRoute,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel(text: 'CONTACTS'),
                    const SizedBox(height: 12),
                    _CardGrid(
                      surface: surface,
                      border: border,
                      iconColor: iconColor,
                      items: [
                        _CardItem(
                          icon: Icons.person_outline,
                          label: 'Customer Service',
                          onTap: () => _showPlatformModal(context),
                        ),
                        _CardItem(
                          icon: Icons.edit_note_outlined,
                          label: 'Feedback',
                          onTap: () => _showPlatformModal(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'Stay connected!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Link to Facebook page
                            launchUrl(Uri.parse('https://www.facebook.com/'));
                          },
                          child: _SocialIcon(
                            icon: Icons.facebook,
                            background: Colors.grey[200]!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Link to TikTok page (update the URL as needed)
                            launchUrl(Uri.parse('https://www.tiktok.com/'));
                          },
                          child: _SocialIcon(
                            icon: Icons.tiktok, // placeholder for TikTok
                            background: Colors.grey[200]!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Link to Telegram page/channel (update the URL as needed)
                            launchUrl(Uri.parse('https://t.me/'));
                          },
                          child: _SocialIcon(
                            icon: Icons.telegram,
                            background: Colors.grey[200]!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey[600],
        letterSpacing: 0.3,
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  final List<_CardItem> items;
  final Color surface;
  final Color border;
  final Color iconColor;

  const _CardGrid({
    required this.items,
    required this.surface,
    required this.border,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // two columns with 12px gap
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => _ShortcutCard(
                  surface: surface,
                  border: border,
                  iconColor: iconColor,
                  item: item,
                  width: itemWidth,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CardItem {
  final IconData icon;
  final String label;
  final String? routeName;
  final VoidCallback? onTap;
  const _CardItem({
    required this.icon,
    required this.label,
    this.routeName,
    this.onTap,
  });
}

class _ShortcutCard extends StatelessWidget {
  final _CardItem item;
  final Color surface;
  final Color border;
  final Color iconColor;
  final double width;

  const _ShortcutCard({
    required this.item,
    required this.surface,
    required this.border,
    required this.iconColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (item.onTap != null) {
            item.onTap!();
          } else if (item.routeName != null) {
            context.go(item.routeName!);
          }
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: iconColor, size: 26),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  const _SocialIcon({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.grey[700], size: 22),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_cafe, size: 44, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'AH POY',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('View Profile'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

void _showLoginBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    barrierColor: Colors.black.withOpacity(0.35),
    backgroundColor: Colors.transparent,
    builder: (context) => const _LoginBottomSheet(),
  );
}

void _showCreateAccountBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    barrierColor: Colors.black.withOpacity(0.35),
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateAccountBottomSheet(),
  );
}

class _LoginBottomSheet extends StatefulWidget {
  const _LoginBottomSheet();

  @override
  State<_LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<_LoginBottomSheet> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Text(
                          'LOG IN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _LoginTextField(
                      hintText: 'Email or Phone Number',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _LoginTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          _loggedIn.value = true;



                          Navigator.of(context).pop();
                          Future.microtask(() {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Logged in successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          });
                        },
                        child: const Text('LOG IN'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.microtask(() => _showResetPasswordBottomSheet(context));
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Or',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialLoginButton(
                          icon: Icons.apple,
                          onTap: () {
                            // TODO: Apple login
                          },
                        ),
                        const SizedBox(width: 20),
                        _SocialLoginButton(
                          icon: Icons.g_mobiledata, // placeholder for Google
                          onTap: () {
                            // TODO: Google login
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.microtask(() => _showCreateAccountBottomSheet(context));
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateAccountBottomSheet extends StatefulWidget {
  const _CreateAccountBottomSheet();

  @override
  State<_CreateAccountBottomSheet> createState() => _CreateAccountBottomSheetState();
}

class _CreateAccountBottomSheetState extends State<_CreateAccountBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
                        hintText: 'Phone Number',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your phone number.')),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Continuing account creation...')),
                          );
                        },
                        child: const Text('CONTINUE'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _LoginTextField({
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}

void _showPlatformModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _PlatformSelectionModal(),
  );
}

void _showResetPasswordBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    barrierColor: Colors.black.withOpacity(0.35),
    backgroundColor: Colors.transparent,
    builder: (context) => const _ResetPasswordBottomSheet(),
  );
}

class _ResetPasswordBottomSheet extends StatefulWidget {
  const _ResetPasswordBottomSheet();

  @override
  State<_ResetPasswordBottomSheet> createState() => _ResetPasswordBottomSheetState();
}

class _ResetPasswordBottomSheetState extends State<_ResetPasswordBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'RESET PASSWORD',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            Icon(Icons.phone_outlined, color: Colors.grey[600]),
                        hintText: 'Phone Number',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your phone number.')),
                            );
                            return;
                          }
                          final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString().substring(0, 6);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Verification code sent: $code')),
                          );
                        },
                        child: const Text('CONTINUE'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformSelectionModal extends StatelessWidget {
  const _PlatformSelectionModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Select Platform',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Platform options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _PlatformOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () async {
                    Navigator.of(context).pop();

                    // TODO: Replace with your real Facebook page URL
                    final facebookUrl = Uri.parse('https://facebook.com');

                    try {
                      await launchUrl(
                        facebookUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Unable to open Facebook. Please check the link or your internet connection.',
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                _PlatformOption(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  onTap: () async {
                    Navigator.of(context).pop();

                    final webUrl = Uri.parse('https://t.me/HEANGDD');
                    final telegramAppUrl = Uri.parse(
                      'tg://resolve?domain=HEANGDD',
                    );

                    // Try Telegram app first, then web URL
                    try {
                      // Try launching Telegram app directly
                      await launchUrl(
                        telegramAppUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {
                      // If Telegram app fails, try web URL
                      try {
                        await launchUrl(
                          webUrl,
                          mode: LaunchMode.platformDefault,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please rebuild the app to enable Telegram linking. Stop the app completely and run "flutter run" again.',
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PlatformOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const _PlatformOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
