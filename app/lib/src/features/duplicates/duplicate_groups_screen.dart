import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../shared/i18n/app_localizations.dart';
import '../../shared/storage/storage.dart';

class DuplicateGroupsScreen extends StatefulWidget {
  const DuplicateGroupsScreen({super.key});

  @override
  State<DuplicateGroupsScreen> createState() => _DuplicateGroupsScreenState();
}

class _DuplicateGroupsScreenState extends State<DuplicateGroupsScreen> {
  final DuplicateGroupRepository _duplicateGroups = DuplicateGroupRepository();

  late Future<List<DuplicateGroupRecord>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _duplicateGroups.listLatest();
  }

  Future<void> _reload() async {
    setState(() {
      _groupsFuture = _duplicateGroups.listLatest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('duplicates.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<DuplicateGroupRecord>>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            final groups = snapshot.data ?? const <DuplicateGroupRecord>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reload,
                    child: groups.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 160),
                              Center(
                                child: Text(
                                  snapshot.hasError
                                      ? l10n.text('duplicates.loadFailed')
                                      : l10n.text('duplicates.empty'),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: groups.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _DuplicateGroupTile(group: groups[index]);
                            },
                          ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: groups.isEmpty
                      ? null
                      : () => Navigator.of(context).pushNamed(AppRoutes.review),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l10n.text('duplicates.openReview')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DuplicateGroupTile extends StatelessWidget {
  const _DuplicateGroupTile({required this.group});

  final DuplicateGroupRecord group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.filter_none_outlined),
        title: Text(
          l10n
              .text('duplicates.groupTitle')
              .replaceAll('{memberCount}', '${group.members.length}'),
        ),
        subtitle: Text(
          l10n
              .text('duplicates.groupSubtitle')
              .replaceAll('{confidence}', group.confidence)
              .replaceAll('{selectedCount}', '${group.selectedCount}'),
        ),
        children: group.members.map((member) {
          return ListTile(
            leading: Icon(
              member.keepRecommended
                  ? Icons.bookmark_added_outlined
                  : Icons.delete_outline,
            ),
            title: Text(member.pathHint ?? member.assetId),
            subtitle: Text(
              member.keepRecommended
                  ? l10n.text('duplicates.keepRecommended')
                  : l10n.text('duplicates.selectedForCleanup'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
