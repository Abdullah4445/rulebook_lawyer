import 'package:lawyer/controller/freight_controller.dart';
import 'package:lawyer/controller/home_intercity_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActiveInterCityOrderController extends GetxController{

  HomeIntercityController homeController = Get.put(HomeIntercityController());
  FreightController frightController = Get.put(FreightController());
  Rx<TextEditingController> otpController = TextEditingController().obs;

}
