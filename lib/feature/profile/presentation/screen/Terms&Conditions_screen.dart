import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'TERMS & CONDITIONS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('MOBILE APPLICATION AND MEMBERSHIP CARD'),

            _Paragraph(
              'By signing up an account via the TUBE COFFEE Mobile Application (“App”), '
              'which is owned and operated by Tube Café Co., Ltd. (“Company”) and its '
              'licensors, if any, to register the Tube Coffee for a membership with the '
              'Company, you agree and are bound by the following terms and conditions '
              '(“Terms of Use”).',
            ),

            SizedBox(height: 16),
            _SubTitle('Agreement to Terms of Use'),

            _NumberedItem(
              '1.',
              'The Company reserves the right, at its discretion, to modify these Terms '
              'of Use at any time without notice. The change shall be effective immediately '
              'upon posting on the App.',
            ),
            _NumberedItem(
              '2.',
              'Although the Company uses its reasonable effort to notify the change, it is '
              'your sole responsibility to check these Terms of Use from time to time to '
              'keep yourself updated. Your continued use of the App or the Card following '
              'any changes will be deemed as your acceptance and agreement to such change.',
            ),

            SizedBox(height: 16),
            _SubTitle('Content'),

            _NumberedItem(
              '3.',
              'All texts, interfaces, graphics, photographs, trademarks, logos, sounds, '
              'music, artworks and computer code including but not limited to design, '
              'structure, selection and arrangement of the aforesaid items contained on '
              'the App or the Card (“Content”) are owned, controlled or licensed by or to '
              'the Company.',
            ),
            _NumberedItem(
              '4.',
              'No part of the App, the Card, or the Content may be translated, copied, '
              'reproduced, republished, uploaded, posted, publicly displayed, encoded, '
              'transmitted, or distributed in any way without the Company’s prior written '
              'consent.',
            ),
            _NumberedItem(
              '5.',
              'You may use any Content on the App that the Company purposely made available '
              'for downloading, provided that you:',
            ),

            _BulletItem(
              'make no modification to any such information;',
            ),
            _BulletItem(
              'use such information only for your personal and non-commercial purpose and '
              'not for any purpose that is unlawful or prohibited by these Terms of Use; and',
            ),
            _BulletItem(
              'do not make any representations or warranties relating to such Content.',
            ),

            SizedBox(height: 16),
            _SubTitle('Membership and Class'),

            _NumberedItem(
              '6.',
              'Membership with the Company and use of the App is not intended for any '
              'commercial resale or redistribution. Membership benefits are non-transferable '
              'and may only be used by the registered account holder.',
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  final String text;
  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  final String number;
  final String text;
  const _NumberedItem(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '$number $text',
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        '• $text',
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }
}
