import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/send_notification.dart';
import '../model/order_model.dart';
import 'fire_store_utils.dart';

class NotifyCustomerButton extends StatefulWidget {
  final OrderModel orderModel;

  const NotifyCustomerButton({
    Key? key,
    required this.orderModel,
  }) : super(key: key);

  @override
  State<NotifyCustomerButton> createState() => _NotifyCustomerButtonState();
}

class _NotifyCustomerButtonState extends State<NotifyCustomerButton> {
  bool _isCooldown = false;
  int _secondsRemaining = 0;

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _secondsRemaining = 25;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_secondsRemaining == 1) {
        setState(() {
          _isCooldown = false;
          _secondsRemaining = 0;
        });
        return false;
      } else {
        setState(() {
          _secondsRemaining--;
        });
        return true;
      }
    });
  }

  Future<void> _sendNotification() async {
    try {
      final customer =
          await FireStoreUtils.getCustomer(widget.orderModel.userId.toString());
      if (customer != null && customer.fcmToken != null) {
        Map<String, dynamic> payload = {
          "type": "driver_arrived",
          "orderId": widget.orderModel.id,
        };

        await SendNotification.sendOneNotification(
          token: customer.fcmToken.toString(),
          title: '🚖 Driver Arrived!',
          body: 'Your driver has reached your pickup location.',
          payload: payload,
        );

        Get.snackbar(
          'Notification Sent',
          'Customer has been notified successfully.',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        _startCooldown();
      } else {
        Get.snackbar(
          'Error',
          'Customer not found or missing FCM token.',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send notification: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isCooldown ? null : _sendNotification,
      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
      label: Text(
        _isCooldown
            ? 'Please wait $_secondsRemaining seconds...'
            : 'Notify Customer that you have reached the Source Destination',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        disabledBackgroundColor: Colors.grey, // Optional: grey out during cooldown
      ),
    );
  }
}
