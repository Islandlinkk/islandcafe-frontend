import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Membership Program
            SectionHeader(title: 'Membership Program'),
            _Question(
              number: '1.',
              question: 'How do I sign up for the membership program?',
              answer:
                  'Download the Tube app and register with your phone number or email to get started.',
            ),
            _Question(
              number: '2.',
              question: 'Is there a fee to join the membership program?',
              answer: 'Currently, Tube’s membership program is free to join.',
            ),
            _Question(
              number: '3.',
              question: 'Can I use my membership in all Tube locations?',
              answer:
                  'Yes, the membership benefits are available across all Tube stores nationwide.',
            ),
            _Question(
              number: '4.',
              question: 'Can I transfer my membership to someone else?',
              answer:
                  'Memberships are non-transferable and tied to your account.',
            ),
            _Question(
              number: '5.',
              question: 'What happens if I lose access to my account?',
              answer:
                  'Contact Tube support through the app or visit your nearest store to recover your account.',
            ),
            _Question(
              number: '6.',
              question: 'Will I be notified about new benefits or updates?',
              answer:
                  'Yes! Members receive notifications in the app and email updates about new features and promotions.',
            ),
            _Question(
              number: '7.',
              question:
                  'If I pay with the Tube app, will I earn reward points?',
              answer:
                  'Tube currently does not have a reward points system. The app allows you to place orders and make payments.',
            ),
            SizedBox(height: 24),

            // Privacy
            SectionHeader(title: 'Privacy'),
            _Question(
              number: '8.',
              question:
                  'Can I secure my Tube Account(s) on my mobile device with a passcode?',
              answer:
                  'Yes, enable a passcode under Dashboard > Account & Settings > Passcode Lock.',
            ),
            _Question(
              number: '9.',
              question: 'How does Tube protect my privacy after I register?',
              answer: 'Please read our Privacy Policy for details.',
            ),
            SizedBox(height: 24),

            // Sign in/Sign up Information & Issues
            SectionHeader(title: 'Sign in/Sign up Information & Issues'),
            _Question(
              number: '10.',
              question: 'I forgot my password. What should I do?',
              answer:
                  'Click "Forgot Password" on the login screen and follow instructions. The reset link expires in 30 minutes.',
            ),
            _Question(
              number: '11.',
              question: 'How do I change my email or phone number?',
              answer:
                  'Go to Dashboard > Account & Settings > Personal Information to update your contact details.',
            ),
            _Question(
              number: '12.',
              question: 'Can I have multiple Tube accounts?',
              answer:
                  'Yes, you can create multiple accounts using different email addresses or phone numbers. Each must be unique.',
            ),
            _Question(
              number: '13.',
              question: 'Why am I not receiving verification codes or emails?',
              answer:
                  'Check spam/junk folders and ensure your email provider is not blocking Tube. Add Tube to your safe sender list.',
            ),
            _Question(
              number: '14.',
              question: 'How do I delete my Tube account?',
              answer:
                  'Contact Tube customer support via the app or visit a store to delete your account.',
            ),
            SizedBox(height: 24),

            // Application Information and Issues
            SectionHeader(title: 'Application Information and Issues'),
            _Question(
              number: '15.',
              question: 'The app is crashing or freezing. What should I do?',
              answer:
                  'Close and reopen the app. If it persists, reinstall the app and ensure your OS is up to date.',
            ),
            _Question(
              number: '16.',
              question: 'How do I report a bug or provide feedback?',
              answer:
                  'Go to app settings and select "Contact Support" or "Feedback".',
            ),
            _Question(
              number: '17.',
              question: 'Why is the app not loading or connecting?',
              answer:
                  'Check your internet connection, switch between Wi-Fi and mobile data, and restart your device if needed.',
            ),
            _Question(
              number: '18.',
              question: 'How do I update the app to the latest version?',
              answer:
                  'Go to your device’s app store, search "Tube", and tap "Update" if available.',
            ),
            _Question(
              number: '19.',
              question: 'What are the system requirements for the Tube app?',
              answer:
                  'iOS 12.0+ for Apple devices and Android 6.0+ for Android devices.',
            ),
            _Question(
              number: '20.',
              question: 'Can I use the app on multiple devices?',
              answer:
                  'Yes, but log out from one device before logging in on another to avoid access issues.',
            ),
            _Question(
              number: '21.',
              question: 'Why am I experiencing slow performance in the app?',
              answer:
                  'Slow performance may be due to weak internet, low device storage, or multiple apps running. Clear cache and ensure stable connection.',
            ),
            _Question(
              number: '22.',
              question: 'How do I manage notifications from the app?',
              answer:
                  'Go to Dashboard > Settings > Notifications to customize your preferences.',
            ),
            _Question(
              number: '23.',
              question: 'Can I change my preferred language in the app?',
              answer:
                  'Yes, go to Dashboard > Settings > Language and select your preferred language.',
            ),
            _Question(
              number: '24.',
              question: 'Is there an offline mode in the app?',
              answer:
                  'Currently, Tube app requires internet access for most features. Some content may be cached for offline viewing.',
            ),
            _Question(
              number: '25.',
              question: 'How do I contact customer support?',
              answer:
                  'You can contact customer support via the app, website, or by visiting the nearest Tube store.',
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final String number;
  final String question;
  final String answer;

  const _Question({
    required this.number,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number $question',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
