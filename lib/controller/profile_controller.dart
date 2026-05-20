import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> bioController = TextEditingController().obs;
  RxString countryCode = "+1".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        driverModel.value = value;

        phoneNumberController.value.text = driverModel.value.phoneNumber.toString();
        countryCode.value = driverModel.value.countryCode.toString();
        emailController.value.text = driverModel.value.email.toString();
        fullNameController.value.text = driverModel.value.fullName.toString();
        bioController.value.text = driverModel.value.bio ?? '';
        profileImage.value = driverModel.value.profilePic?? '';
        isLoading.value = false;
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }

}
