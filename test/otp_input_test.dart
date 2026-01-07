import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsetrade_app/core/presentation/widgets/otp_input.dart';

void main() {
  testWidgets('OTPInput notifies on deletion', (WidgetTester tester) async {
    var latestCode = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: OTPInput(
            length: 4,
            onChanged: (code) => latestCode = code,
            onCompleted: (_) {},
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '1');
    await tester.pump();
    await tester.enterText(fields.at(1), '2');
    await tester.pump();

    expect(latestCode, '12');

    await tester.enterText(fields.at(1), '');
    await tester.pump();

    expect(latestCode, '1');
  });

  testWidgets('OTPInput clears previous digit on backspace', (WidgetTester tester) async {
    var latestCode = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: OTPInput(
            length: 3,
            onChanged: (code) => latestCode = code,
            onCompleted: (_) {},
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);

    await tester.enterText(fields.at(0), '1');
    await tester.pump();
    await tester.enterText(fields.at(1), '2');
    await tester.pump();

    expect(latestCode, '12');

    await tester.enterText(fields.at(1), '');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(latestCode, '');
  });

  testWidgets('OTPInput supports paste into the first field', (WidgetTester tester) async {
    var latestCode = '';
    var completedCode = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: OTPInput(
            length: 6,
            onChanged: (code) => latestCode = code,
            onCompleted: (code) => completedCode = code,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    expect(latestCode, '123456');
    expect(completedCode, '123456');
  });
}
