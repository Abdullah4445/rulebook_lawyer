import 'dart:developer';

import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InformationController extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> barCouncilIdController = TextEditingController().obs;
  Rx<TextEditingController> qualificationController = TextEditingController().obs;
  Rx<TextEditingController> officeAddressController = TextEditingController().obs;
  Rx<TextEditingController> practiceCityController = TextEditingController().obs;

  RxString countryCode = "+92".obs;
  RxString loginType = "".obs;

  // Lawyer-specific selections
  RxString licenseType = "".obs;      // 'advocate' | 'advocate_hc' | 'advocate_sc'
  RxString barAssociation = "".obs;
  RxString province = "".obs;

  static const List<Map<String, String>> licenseOptions = [
    {'value': 'advocate',    'label': 'Advocate (District / Lower Courts)'},
    {'value': 'advocate_hc', 'label': 'Advocate High Court (Province)'},
    {'value': 'advocate_sc', 'label': 'Advocate Supreme Court (National)'},
  ];

  static const List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Azad Jammu & Kashmir',
    'Gilgit-Baltistan',
  ];

  static const List<String> barAssociations = [
    'Lahore Bar Association',
    'Karachi Bar Association',
    'Islamabad Bar Association',
    'Peshawar Bar Association',
    'Quetta Bar Association',
    'Rawalpindi Bar Association',
    'Faisalabad Bar Association',
    'Multan Bar Association',
    'Gujranwala Bar Association',
    'Sialkot Bar Association',
    'Hyderabad Bar Association',
    'Sukkur Bar Association',
    'Abbottabad Bar Association',
    'Other',
  ];

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<DriverUserModel> userModel = DriverUserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCode.value = userModel.value.countryCode.toString();
      } else {
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
      }
      // Pre-fill lawyer fields if editing existing profile
      if (userModel.value.barCouncilId != null) {
        barCouncilIdController.value.text = userModel.value.barCouncilId!;
      }
      if (userModel.value.qualification != null) {
        qualificationController.value.text = userModel.value.qualification!;
      }
      if (userModel.value.officeAddress != null) {
        officeAddressController.value.text = userModel.value.officeAddress!;
      }
      if (userModel.value.cityIds != null && userModel.value.cityIds!.isNotEmpty) {
        practiceCityController.value.text = userModel.value.cityIds!.first;
      }
      if (userModel.value.licenseType != null) {
        licenseType.value = userModel.value.licenseType!;
      }
      if (userModel.value.barAssociation != null) {
        barAssociation.value = userModel.value.barAssociation!;
      }
      if (userModel.value.province != null) {
        province.value = userModel.value.province!;
      }
      log("------->${loginType.value}");
    }
    update();
  }
}
