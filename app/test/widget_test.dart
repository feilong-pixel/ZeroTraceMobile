import 'package:flutter_test/flutter_test.dart';

import 'package:zerotrace_mobile/src/app/mobile_app.dart';

void main() {
  testWidgets('shows dashboard shell', (tester) async {
    await tester.pumpWidget(const ZeroTraceMobileApp());

    expect(find.text('ZeroTraceMobile'), findsOneWidget);
    expect(find.text('Start Scan'), findsOneWidget);
    expect(find.text('Duplicate Photos'), findsOneWidget);
  });
}
