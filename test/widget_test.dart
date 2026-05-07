import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lawyer/ui/ai_chat/ai_chat_screen.dart';

void main() {
  testWidgets('AI Legal System screen renders for lawyers', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: AiChatScreen()));
    await tester.pumpAndSettle();

    expect(find.text('AI Legal System'), findsWidgets);
    expect(find.byIcon(Icons.attach_file), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });
}
