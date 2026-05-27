import 'package:flutter_test/flutter_test.dart';

import 'package:zerotrace_mobile/src/app/mobile_app.dart';

void main() {
  testWidgets('shows dashboard shell', (tester) async {
    await tester.pumpWidget(const ZeroTraceMobileApp());

    expect(find.text('ZeroTraceMobile'), findsOneWidget);
    expect(
      find.text('Send phone photos to ZeroTraceBrowser over local Wi-Fi.'),
      findsOneWidget,
    );
    expect(find.text('Phone Sync'), findsOneWidget);
    expect(find.text('Similar Photos'), findsOneWidget);
    expect(find.text('Duplicate Photos'), findsNothing);
  });
}
