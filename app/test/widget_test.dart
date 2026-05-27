import 'package:flutter_test/flutter_test.dart';

import 'package:zerotrace_mobile/src/app/mobile_app.dart';
import 'package:zerotrace_mobile/src/shared/settings/preferences_repository.dart';

void main() {
  testWidgets('shows dashboard shell', (tester) async {
    await tester.pumpWidget(
      ZeroTraceMobileApp(
        preferencesRepository: InMemoryPreferencesRepository(),
      ),
    );

    expect(find.text('ExtraSync'), findsOneWidget);
    expect(
      find.text('Send phone photos to ZeroTraceBrowser over local Wi-Fi.'),
      findsOneWidget,
    );
    expect(find.text('Phone Sync'), findsOneWidget);
    expect(find.text('Similar Photos'), findsOneWidget);
    expect(find.text('Duplicate Photos'), findsNothing);
  });

  testWidgets('changes language from settings', (tester) async {
    await tester.pumpWidget(
      ZeroTraceMobileApp(
        preferencesRepository: InMemoryPreferencesRepository(),
      ),
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('手机同步'), findsOneWidget);
    expect(find.text('相似图片'), findsOneWidget);
  });
}
