import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/vehicle_information_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/service_model.dart';
import 'package:lawyer/model/vehicle_type_model.dart';
import 'package:lawyer/model/zone_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/responsive.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VehicleInformationScreen extends StatelessWidget {
  const VehicleInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<VehicleInformationController>(
      init: VehicleInformationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Column(
            children: [
              SizedBox(
                height: Responsive.width(10, context),
                width: Responsive.width(100, context),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                  child: controller.isLoading.value
                      ? Constant.loader(context)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 14,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your specialties'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: themeChange.getThem()
                                              ? Colors.white
                                              : AppColors.brandNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Select every category you can handle as a lawyer. Tap to toggle, you can pick more than one.'
                                            .tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: (themeChange.getThem()
                                                  ? Colors.white
                                                  : AppColors.brandNavy)
                                              .withOpacity(0.65),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Obx(() => Text(
                                            controller.selectedServiceIds.isEmpty
                                                ? 'No category selected yet'.tr
                                                : '${controller.selectedServiceIds.length} ${controller.selectedServiceIds.length == 1 ? "category" : "categories"} selected'
                                                    .tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.brandGold,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: Responsive.height(22, context),
                                  child: ListView.builder(
                                    itemCount: controller.serviceList.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      ServiceModel serviceModel = controller.serviceList[index];
                                      return Obx(
                                        () {
                                          final isSelected = controller.isServiceSelected(serviceModel.id);
                                          return InkWell(
                                            onTap: () => controller.toggleService(serviceModel.id),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Stack(
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(milliseconds: 220),
                                                    curve: Curves.easeOut,
                                                    width: Responsive.width(28, context),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? (themeChange.getThem()
                                                              ? AppColors.darkModePrimary
                                                              : AppColors.primary)
                                                          : (themeChange.getThem()
                                                              ? AppColors.darkService
                                                              : controller.colors[
                                                                  index % controller.colors.length]),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? AppColors.brandGold
                                                            : Colors.transparent,
                                                        width: 2,
                                                      ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                color: AppColors.brandGold
                                                                    .withOpacity(0.30),
                                                                blurRadius: 14,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.background,
                                                            borderRadius:
                                                                BorderRadius.all(Radius.circular(20)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: CachedNetworkImage(
                                                              imageUrl: serviceModel.image.toString(),
                                                              fit: BoxFit.contain,
                                                              height: Responsive.height(8, context),
                                                              width: Responsive.width(18, context),
                                                              placeholder: (context, url) =>
                                                                  Constant.loader(context),
                                                              errorWidget: (context, url, error) =>
                                                                  Image.network(
                                                                      'https://firebasestorage.googleapis.com/v0/b/goflow-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          Constant().localizationTitle(
                                                              serviceModel.title!, 'defaultText'),
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: isSelected
                                                                ? FontWeight.w700
                                                                : FontWeight.w500,
                                                            color: isSelected
                                                                ? (themeChange.getThem()
                                                                    ? Colors.black
                                                                    : Colors.white)
                                                                : (themeChange.getThem()
                                                                    ? Colors.white
                                                                    : Colors.black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        width: 22,
                                                        height: 22,
                                                        decoration: const BoxDecoration(
                                                          color: AppColors.brandGold,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.check_rounded,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFieldThem.buildTextFiled(context, hintText: 'Vehicle Number'.tr, controller: controller.vehicleNumberController.value),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Constant.selectDate(context).then((value) {
                                      if (value != null) {
                                        controller.selectedDate.value = value;
                                        controller.registrationDateController.value.text = DateFormat("dd-MM-yyyy").format(value);
                                      }
                                    });
                                  },
                                  child: TextFieldThem.buildTextFiled(context,
                                      hintText: 'Registration Date'.tr, controller: controller.registrationDateController.value, enable: false),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                DropdownButtonFormField<VehicleTypeModel>(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                      contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                    ),
                                    validator: (value) => value == null ? 'field required' : null,
                                    value: controller.selectedVehicle.value.id == null ? null : controller.selectedVehicle.value,
                                    onChanged: (value) {
                                      controller.selectedVehicle.value = value!;
                                    },
                                    hint: Text("Select vehicle type".tr),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    items: controller.vehicleList.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(Constant.localizationName(item.name)),
                                      );
                                    }).toList()),
                                const SizedBox(
                                  height: 10,
                                ),
                                DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                      contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                    ),
                                    validator: (value) => value == null ? 'field required' : null,
                                    value: controller.selectedColor.value.isEmpty ? null : controller.selectedColor.value,
                                    onChanged: (value) {
                                      controller.selectedColor.value = value!;
                                    },
                                    hint: Text("Select vehicle color".tr),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    items: controller.carColorList.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item.toString()),
                                      );
                                    }).toList()),
                                const SizedBox(
                                  height: 10,
                                ),
                                DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                      contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                    ),
                                    validator: (value) => value == null ? 'field required' : null,
                                    value: controller.seatsController.value.text.isEmpty ? null : controller.seatsController.value.text,
                                    onChanged: (value) {
                                      controller.seatsController.value.text = value!;
                                    },
                                    hint: Text("How Many Seats".tr),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    items: controller.sheetList.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item.toString()),
                                      );
                                    }).toList()),
                                const SizedBox(height: 18),
                                // ─── Jurisdiction picker (country → province → cities) ───
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jurisdiction'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: themeChange.getThem()
                                              ? Colors.white
                                              : AppColors.brandNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pick country, then province, then all cities you cover.'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: (themeChange.getThem()
                                                  ? Colors.white
                                                  : AppColors.brandNavy)
                                              .withOpacity(0.65),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Loading / error / retry banner — shown only
                                // when the jurisdictions catalog isn't ready.
                                Obx(() {
                                  if (controller.isLoadingJurisdictions.value) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2)),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Loading countries...'.tr,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: themeChange.getThem()
                                                    ? Colors.white70
                                                    : AppColors.brandNavy.withOpacity(0.7)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  if (controller.countries.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.08),
                                        border: Border.all(
                                            color: AppColors.error.withOpacity(0.4)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.jurisdictionsError.value ??
                                                'Could not load countries. Make sure the admin server is reachable.'.tr,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: AppColors.error),
                                          ),
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: controller.reloadJurisdictions,
                                              icon: const Icon(Icons.refresh, size: 16),
                                              label: Text('Retry'.tr,
                                                  style: GoogleFonts.poppins(fontSize: 12)),
                                              style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 4),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize.shrinkWrap),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                // Country dropdown
                                Obx(() => DropdownButtonFormField<String>(
                                      decoration: _jurisdictionInputDecoration(themeChange.getThem()),
                                      isExpanded: true,
                                      value: controller.selectedCountryIso.value,
                                      hint: Text(controller.countries.isEmpty
                                          ? 'No countries available'.tr
                                          : 'Select Country'.tr),
                                      style: GoogleFonts.poppins(
                                        color: themeChange.getThem()
                                            ? Colors.white
                                            : AppColors.brandNavy,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      items: controller.countries
                                          .map((c) => DropdownMenuItem(
                                                value: c.iso,
                                                child: Text('${c.flag ?? ''} ${c.name}'.trim()),
                                              ))
                                          .toList(),
                                      onChanged: controller.countries.isEmpty
                                          ? null
                                          : (value) => controller.setCountry(value),
                                    )),
                                const SizedBox(height: 10),
                                // Province dropdown — scoped to selected country
                                Obx(() {
                                  final provinces = controller.provincesForCurrentCountry;
                                  return DropdownButtonFormField<String>(
                                    decoration: _jurisdictionInputDecoration(themeChange.getThem()),
                                    isExpanded: true,
                                    value: controller.selectedProvince.value,
                                    hint: Text(provinces.isEmpty
                                        ? 'Select Country first'.tr
                                        : 'Select Province'.tr),
                                    style: GoogleFonts.poppins(
                                      color: themeChange.getThem()
                                          ? Colors.white
                                          : AppColors.brandNavy,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: provinces
                                        .map((p) => DropdownMenuItem(
                                              value: p.name,
                                              child: Text(p.name),
                                            ))
                                        .toList(),
                                    onChanged: provinces.isEmpty
                                        ? null
                                        : (value) => controller.setProvince(value),
                                  );
                                }),
                                const SizedBox(height: 12),
                                // Cities — chips, multi-select, scoped to selected province
                                Obx(() {
                                  final province = controller.selectedProvince.value;
                                  if (province == null || province.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 8),
                                      child: Text(
                                        'Select a province above to choose cities.'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: (themeChange.getThem()
                                                  ? Colors.white
                                                  : AppColors.brandNavy)
                                              .withOpacity(0.5),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }
                                  final cities = controller.citiesForCurrentProvince;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6, bottom: 8),
                                        child: Text(
                                          controller.selectedCities.isEmpty
                                              ? 'No city selected'.tr
                                              : '${controller.selectedCities.length} ${controller.selectedCities.length == 1 ? "city" : "cities"} selected'
                                                  .tr,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.brandGold,
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: cities.map((city) {
                                          final selected =
                                              controller.isCitySelected(city.name);
                                          return GestureDetector(
                                            onTap: () =>
                                                controller.toggleCity(city.name),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 180),
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? AppColors.brandGold
                                                    : (themeChange.getThem()
                                                        ? AppColors
                                                            .darkContainerBackground
                                                        : AppColors.surfaceTint),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: selected
                                                      ? AppColors.brandGold
                                                      : (themeChange.getThem()
                                                          ? AppColors
                                                              .darkContainerBorder
                                                          : AppColors
                                                              .containerBorder),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (selected) ...[
                                                    const Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  Text(
                                                    city.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight: selected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: selected
                                                          ? Colors.white
                                                          : (themeChange
                                                                  .getThem()
                                                              ? Colors.white70
                                                              : AppColors
                                                                  .brandNavy),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 18),
                                // ─── Professional Credentials ───
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Professional Credentials'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: themeChange.getThem() ? Colors.white : AppColors.brandNavy,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Verification status badge
                                      if (controller.driverModel.value.documentVerification == true)
                                        _verificationBadge('Verified', AppColors.brandGold, Icons.verified_rounded)
                                      else if (controller.driverModel.value.licenseType != null &&
                                          controller.driverModel.value.licenseType!.isNotEmpty)
                                        _verificationBadge('Pending\n Review', Colors.orange, Icons.hourglass_top_rounded)
                                      else
                                        _verificationBadge('Not Verified', Colors.red.shade400, Icons.cancel_rounded),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // License Type dropdown
                                Obx(() => DropdownButtonFormField<String>(
                                  decoration: _jurisdictionInputDecoration(themeChange.getThem()),
                                  isExpanded: true,
                                  value: controller.licenseType.value.isEmpty ? null : controller.licenseType.value,
                                  hint: Text('Select License Type'.tr),
                                  style: GoogleFonts.poppins(
                                    color: themeChange.getThem() ? Colors.white : AppColors.brandNavy,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: VehicleInformationController.licenseOptions.map((opt) => DropdownMenuItem(
                                    value: opt['value'],
                                    child: Text(opt['label']!),
                                  )).toList(),
                                  onChanged: (value) {
                                    if (value != null) controller.licenseType.value = value;
                                  },
                                )),
                                const SizedBox(height: 10),
                                // Bar Association dropdown
                                Obx(() => DropdownButtonFormField<String>(
                                  decoration: _jurisdictionInputDecoration(themeChange.getThem()),
                                  isExpanded: true,
                                  value: controller.barAssociation.value.isEmpty ? null : controller.barAssociation.value,
                                  hint: Text('Select Bar Association'.tr),
                                  style: GoogleFonts.poppins(
                                    color: themeChange.getThem() ? Colors.white : AppColors.brandNavy,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: VehicleInformationController.barAssociations.map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(name),
                                  )).toList(),
                                  onChanged: (value) {
                                    if (value != null) controller.barAssociation.value = value;
                                  },
                                )),
                                const SizedBox(height: 10),
                                TextFieldThem.buildTextFiled(context,
                                    hintText: 'Qualification (e.g. LLB, LLM)'.tr,
                                    controller: controller.qualificationController.value),
                                const SizedBox(height: 10),
                                TextFieldThem.buildTextFiled(context,
                                    hintText: 'Office / Chamber Address'.tr,
                                    controller: controller.officeAddressController.value),
                                const SizedBox(height: 16),

                                // ─── Enrollment Certificate Upload ───
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bar Council Enrollment Certificate'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem() ? Colors.white70 : AppColors.brandNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Upload a clear photo/scan. Our system will auto-verify your ID.'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: (themeChange.getThem() ? Colors.white : AppColors.brandNavy).withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(() => controller.certificateFile.value != null
                                          ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.file(
                                                    controller.certificateFile.value!,
                                                    height: 160,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 6, right: 6,
                                                  child: GestureDetector(
                                                    onTap: () => controller.certificateFile.value = null,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black54,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: _certUploadBtn(
                                                    icon: Icons.photo_library_outlined,
                                                    label: 'Gallery'.tr,
                                                    dark: themeChange.getThem(),
                                                    onTap: controller.pickCertificateImage,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _certUploadBtn(
                                                    icon: Icons.camera_alt_outlined,
                                                    label: 'Camera'.tr,
                                                    dark: themeChange.getThem(),
                                                    onTap: controller.pickCertificateCamera,
                                                  ),
                                                ),
                                              ],
                                            )),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text("Select Your Rules".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                ListBody(
                                  children: controller.driverRulesList
                                      .map((item) => CheckboxListTile(
                                            checkColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                            value: controller.selectedDriverRulesList.indexWhere((element) => element.id == item.id) == -1 ? false : true,
                                            title: Text(Constant.localizationName(item.name), style: GoogleFonts.poppins(fontWeight: FontWeight.w400)),
                                            onChanged: (value) {
                                              if (value == true) {
                                                controller.selectedDriverRulesList.add(item);
                                              } else {
                                                controller.selectedDriverRulesList.removeAt(controller.selectedDriverRulesList.indexWhere((element) => element.id == item.id));
                                              }
                                            },
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: ButtonThem.buildButton(
                                    context,
                                    title: "Save".tr,
                                    onPress: () async {
                                      if (controller.selectedServiceIds.isEmpty) {
                                        ShowToastDialog.showToast(
                                            "Please select at least one specialty".tr);
                                      } else if (controller.vehicleNumberController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter Vehicle number".tr);
                                      } else if (controller.registrationDateController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please select registration date".tr);
                                      } else if (controller.selectedVehicle.value.id == null || controller.selectedVehicle.value.id!.isEmpty) {
                                        ShowToastDialog.showToast("Please enter Vehicle type".tr);
                                      } else if (controller.selectedColor.value.isEmpty) {
                                        ShowToastDialog.showToast("Please enter Vehicle color".tr);
                                      } else if (controller.seatsController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter seats".tr);
                                      } else if (controller.selectedCountryIso.value == null ||
                                          controller.selectedCountryIso.value!.isEmpty) {
                                        ShowToastDialog.showToast("Please select a country".tr);
                                      } else if (controller.selectedProvince.value == null ||
                                          controller.selectedProvince.value!.isEmpty) {
                                        ShowToastDialog.showToast("Please select a province".tr);
                                      } else if (controller.selectedCities.isEmpty) {
                                        ShowToastDialog.showToast("Please select at least one city".tr);
                                      } else {
                                        // Bar Council ID format check (alphanumeric + dash/slash, 4–25 chars)
                                        final barId = controller.vehicleNumberController.value.text.trim();
                                        final barIdRegex = RegExp(r'^[A-Za-z0-9\-\/]{4,25}$');
                                        if (barId.isNotEmpty && !barIdRegex.hasMatch(barId)) {
                                          ShowToastDialog.showToast(
                                              "Bar Council ID format invalid. Use alphanumeric characters and dashes only (4–25 chars).".tr);
                                          return;
                                        }
                                        ShowToastDialog.showLoader("Please wait".tr);
                                        // Lawyers can update their specialties at any time.
                                        controller.driverModel.value.serviceIds =
                                            controller.selectedServiceIds.toList();
                                        controller.driverModel.value.serviceId =
                                            controller.selectedServiceIds.first;
                                        // Court jurisdiction
                                        controller.driverModel.value.countryIso =
                                            controller.selectedCountryIso.value;
                                        controller.driverModel.value.province =
                                            controller.selectedProvince.value;
                                        controller.driverModel.value.cityIds =
                                            controller.selectedCities.toList();
                                        // Mirror to zoneIds for backwards-compat with existing
                                        // matching queries (case docs use `zoneId` = city name).
                                        controller.driverModel.value.zoneIds =
                                            controller.selectedCities.toList();

                                        // Professional credentials
                                        if (controller.licenseType.value.isNotEmpty) {
                                          controller.driverModel.value.licenseType = controller.licenseType.value;
                                        }
                                        if (controller.barAssociation.value.isNotEmpty) {
                                          controller.driverModel.value.barAssociation = controller.barAssociation.value;
                                        }
                                        final qual = controller.qualificationController.value.text.trim();
                                        if (qual.isNotEmpty) controller.driverModel.value.qualification = qual;
                                        final addr = controller.officeAddressController.value.text.trim();
                                        if (addr.isNotEmpty) controller.driverModel.value.officeAddress = addr;

                                        // If key credentials changed, mark as pending re-verification
                                        if (controller.credentialsChanged) {
                                          controller.driverModel.value.documentVerification = false;
                                        }

                                        controller.driverModel.value.vehicleInformation = VehicleInformation(
                                            registrationDate: Timestamp.fromDate(controller.selectedDate.value!),
                                            vehicleColor: controller.selectedColor.value,
                                            vehicleNumber: controller.vehicleNumberController.value.text,
                                            vehicleType: controller.selectedVehicle.value.name,
                                            vehicleTypeId: controller.selectedVehicle.value.id,
                                            seats: controller.seatsController.value.text,
                                            driverRules: controller.selectedDriverRulesList);

                                        await FireStoreUtils.updateDriverUser(controller.driverModel.value).then((value) async {
                                          if (value == true) {
                                            // If a certificate was uploaded, trigger OCR auto-verification
                                            if (controller.certificateFile.value != null) {
                                              ShowToastDialog.showLoader("Verifying credentials...".tr);
                                              final result = await controller.verifyCredentialsWithOcr();
                                              ShowToastDialog.closeLoader();
                                              switch (result) {
                                                case 'verified':
                                                  ShowToastDialog.showToast("Credentials verified successfully!".tr);
                                                  break;
                                                case 'pending':
                                                  ShowToastDialog.showToast("Your certificate has been sent to admin for review.".tr);
                                                  break;
                                                case 'rejected':
                                                  ShowToastDialog.showToast("Could not verify credentials from the uploaded image. Please upload a clearer photo.".tr);
                                                  break;
                                                default:
                                                  ShowToastDialog.showToast("Information saved. Verification pending.".tr);
                                              }
                                            } else {
                                              ShowToastDialog.closeLoader();
                                              ShowToastDialog.showToast("Information update successfully".tr);
                                            }
                                          } else {
                                            ShowToastDialog.closeLoader();
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "You can update your specialties any time. Lawyers handling more categories receive more case requests."
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: (themeChange.getThem()
                                            ? Colors.white
                                            : AppColors.brandNavy)
                                        .withOpacity(0.6),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Small badge chip for verification status.
  Widget _verificationBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label.tr,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Shared decoration for the jurisdiction dropdowns to avoid repetition.
  InputDecoration _jurisdictionInputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkTextField : AppColors.textField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: isDark
                ? AppColors.darkTextFieldBorder
                : AppColors.textFieldBorder,
            width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: isDark
                ? AppColors.darkTextFieldBorder
                : AppColors.textFieldBorder,
            width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brandGold, width: 1.6),
      ),
    );
  }

  Widget _certUploadBtn({
    required IconData icon,
    required String label,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkTextField : AppColors.textField,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.brandGold, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: dark ? Colors.white70 : AppColors.brandNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  zoneDialog(BuildContext context, VehicleInformationController controller) {
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(),
      ),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        if (controller.selectedZone.isEmpty) {
          ShowToastDialog.showToast("Please select zone");
        } else {
          String nameValue = "";
          for (var element in controller.selectedZone) {
            List<ZoneModel> list = controller.zoneList.where((p0) => p0.id == element).toList();
            if(list.isNotEmpty){
              nameValue = "$nameValue${nameValue.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
            }
          }
          controller.zoneNameController.value.text = nameValue;
          Get.back();
        }
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Zone list'),
            content: SizedBox(
              width: Responsive.width(90, context), // Change as per your requirement
              child: controller.zoneList.isEmpty
                  ? Container()
                  : Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.zoneList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Obx(
                            () => CheckboxListTile(
                              value: controller.selectedZone.contains(controller.zoneList[index].id),
                              onChanged: (value) {
                                if (controller.selectedZone.contains(controller.zoneList[index].id)) {
                                  controller.selectedZone.remove(controller.zoneList[index].id); // unselect
                                } else {
                                  controller.selectedZone.add(controller.zoneList[index].id); // select
                                }
                              },
                              activeColor: AppColors.primary,
                              title: Text(Constant.localizationName(controller.zoneList[index].name)),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
        });
  }
}
