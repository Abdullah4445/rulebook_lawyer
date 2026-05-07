import 'package:flutter_test/flutter_test.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/controller/dash_board_controller.dart';
import 'package:lawyer/ui/ai_chat/ai_chat_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_history.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';

void main() {
  group('DashBoardController drawer mapping', () {
    test('non-subscription drawer items stay aligned with opened screens', () {
      Constant.isSubscriptionModelApplied = false;
      final controller = DashBoardController();

      controller.setDrawerList();

      expect(controller.drawerItems.length, 13);
      expect(controller.drawerItems[8].title, 'AI Legal System');
      expect(controller.getDrawerItemWidget(8), isA<AiChatScreen>());
      expect(controller.getDrawerItemWidget(9), isA<SubscriptionHistory>());
      expect(controller.logoutIndex, 12);
      expect(controller.shouldShowAppBarTitle(0), isFalse);
      expect(controller.shouldShowAppBarTitle(8), isTrue);
      expect(controller.shouldShowAppBarTitle(12), isFalse);
    });

    test('subscription drawer items keep AI and subscription screens aligned', () {
      Constant.isSubscriptionModelApplied = true;
      final controller = DashBoardController();

      controller.setDrawerList();

      expect(controller.drawerItems.length, 14);
      expect(controller.drawerItems[8].title, 'AI Legal System');
      expect(controller.getDrawerItemWidget(8), isA<AiChatScreen>());
      expect(controller.getDrawerItemWidget(9), isA<SubscriptionListScreen>());
      expect(controller.getDrawerItemWidget(10), isA<SubscriptionHistory>());
      expect(controller.logoutIndex, 13);
      expect(controller.shouldShowAppBarTitle(0), isFalse);
      expect(controller.shouldShowAppBarTitle(9), isTrue);
      expect(controller.shouldShowAppBarTitle(13), isFalse);
    });
  });
}

