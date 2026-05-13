import 'package:flutter/material.dart';

import '../../shared/i18n/app_localizations.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('review.title'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.text('review.empty')),
        ),
      ),
    );
  }
}
