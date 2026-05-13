import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../shared/i18n/app_localizations.dart';
import 'fixture_scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FixtureScanService _fixtureScanService = FixtureScanService();

  bool _isRunning = false;
  FixtureScanResult? _result;
  String? _errorMessage;

  Future<void> _runFixtureScan() async {
    setState(() {
      _isRunning = true;
      _errorMessage = null;
    });

    try {
      final result = await _fixtureScanService.run();
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('scan.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: _isRunning ? null : 0),
            const SizedBox(height: 16),
            Text(l10n.text('scan.fixtureNote')),
            const SizedBox(height: 16),
            if (_result != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(l10n.text('scan.fixtureComplete')),
                  subtitle: Text(
                    l10n
                        .text('scan.fixtureSummary')
                        .replaceAll('{assetCount}', '${_result!.assetCount}')
                        .replaceAll(
                          '{groupCount}',
                          '${_result!.exactGroupCount}',
                        )
                        .replaceAll(
                          '{selectedCount}',
                          '${_result!.selectedForCleanupCount}',
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.duplicates),
                ),
              ),
            if (_errorMessage != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(l10n.text('scan.fixtureFailed')),
                  subtitle: Text(_errorMessage!),
                ),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _isRunning ? null : _runFixtureScan,
              icon: const Icon(Icons.play_arrow_outlined),
              label: Text(l10n.text('scan.runFixture')),
            ),
          ],
        ),
      ),
    );
  }
}
