import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/dash_board_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/responsive.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// marging code
class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DashBoardController>(
        init: DashBoardController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: controller.selectedDrawerIndex.value == 0
                  ? StreamBuilder(
                  stream: FireStoreUtils.fireStore
                      .collection(CollectionName.driverUsers)
                      .doc(FireStoreUtils.getCurrentUid())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong'.tr);
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Constant.loader(context);
                    }

                    DriverUserModel driverModel =
                    DriverUserModel.fromJson(snapshot.data!.data()!);
                    return Container(
                      width: Responsive.width(50, context),
                      height: Responsive.height(5.5, context),
                      decoration: const BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.all(
                          Radius.circular(50.0),
                        ),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment:
                            Alignment(driverModel.isOnline == true ? -1 : 1, 0),
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: Responsive.width(26, context),
                              height: Responsive.height(8, context),
                              decoration: const BoxDecoration(
                                color: AppColors.darkModePrimary,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              ShowToastDialog.showLoader("Please wait".tr);
                              if (driverModel.documentVerification == false &&
                                  Constant.isVerifyDocument == true) {
                                ShowToastDialog.closeLoader();
                                _showAlertDialog(context, "document");
                              } else if (driverModel.vehicleInformation == null ||
                                  ((driverModel.serviceIds == null ||
                                          driverModel.serviceIds!.isEmpty) &&
                                      (driverModel.serviceId == null ||
                                          driverModel.serviceId!.isEmpty))) {
                                ShowToastDialog.closeLoader();
                                _showAlertDialog(context, "vehicleInformation");
                              } else {
                                driverModel.isOnline = true;
                                await FireStoreUtils.updateDriverUser(driverModel);

                                ShowToastDialog.closeLoader();
                              }
                            },
                            child: Align(
                              alignment: const Alignment(-1, 0),
                              child: Container(
                                width: Responsive.width(26, context),
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                child: Text(
                                  'Online'.tr,
                                  style: GoogleFonts.poppins(
                                      color: driverModel.isOnline == true
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              ShowToastDialog.showLoader("Please wait".tr);
                              driverModel.isOnline = false;
                              await FireStoreUtils.updateDriverUser(driverModel);

                              ShowToastDialog.closeLoader();
                            },
                            child: Align(
                              alignment: const Alignment(1, 0),
                              child: Container(
                                width: Responsive.width(26, context),
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                child: Text(
                                  'Offline'.tr,
                                  style: GoogleFonts.poppins(
                                      color: driverModel.isOnline == false
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  : controller.shouldShowAppBarTitle(controller.selectedDrawerIndex.value)
                  ? Text(
                (controller.selectedDrawerItem?.title ?? '').tr,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              )
                  : Text(""),
              centerTitle: true,
              leading: Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 20),
                    child: SvgPicture.asset('assets/icons/ic_humber.svg'),
                  ),
                );
              }),
            ),
            drawer: buildAppDrawer(context, controller),
            body: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) {
                    return;
                  }

                  final canExit = await controller.onWillPop();
                  if (canExit && context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                },
                child:
                controller.getDrawerItemWidget(controller.selectedDrawerIndex.value)),
          );
        });
  }

  Future<void> _showAlertDialog(BuildContext context, String type) async {
    final controllerDashBoard = Get.put(DashBoardController());

    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: Text('Information'.tr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'To start earning with Rulebook Lawyer you need to fill in your personal information'
                        .tr),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'.tr),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text('Yes'.tr),
              onPressed: () {
                if (type == "document") {
                  controllerDashBoard.onSelectItem(5); // Index update kiya
                } else {
                  controllerDashBoard.onSelectItem(6); // Index update kiya
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildAppDrawer(BuildContext context, DashBoardController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedBg = isDark
        ? AppColors.brandGold
        : AppColors.brandNavy;
    final unselectedBg = isDark
        ? AppColors.darkContainerBackground
        : AppColors.containerBackground;
    final unselectedBorder = isDark
        ? AppColors.darkContainerBorder
        : AppColors.containerBorder;
    final unselectedText = isDark ? Colors.white : AppColors.brandNavy;
    final unselectedSubtitle = isDark ? AppColors.gray400 : AppColors.gray500;

    final drawerItems = controller.drawerItems;
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      final isSelected = i == controller.selectedDrawerIndex.value;

      drawerOptions.add(InkWell(
        onTap: () {
          controller.onSelectItem(i);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : unselectedBg,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              border: Border.all(
                color: isSelected ? Colors.transparent : unselectedBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.brandGold.withOpacity(isDark ? 0.35 : 0.18)
                      : Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                  blurRadius: isSelected ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.18)
                        : AppColors.brandGold.withOpacity(isDark ? 0.18 : 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    d.icon,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? (isDark ? AppColors.brandNavy : Colors.white)
                          : AppColors.brandGold,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.title.tr,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? (isDark ? AppColors.brandNavy : Colors.white)
                              : unselectedText,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        d.subtitle.tr,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.brandNavy.withOpacity(0.7)
                                  : Colors.white70)
                              : unselectedSubtitle,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isSelected
                      ? (isDark ? AppColors.brandNavy : Colors.white)
                      : unselectedSubtitle,
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF151923), Color(0xFF202736)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FutureBuilder<DriverUserModel?>(
                  future: FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Constant.loader(context);
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          DriverUserModel driverModel = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 78,
                                    width: 78,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.brandGold,
                                        width: 2.2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: CachedNetworkImage(
                                        imageUrl: driverModel.profilePic.toString(),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Constant.loader(context),
                                        errorWidget: (context, url, error) => Container(
                                          color: const Color(0xFF111827),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _initialsFromName(driverModel.fullName),
                                            style: GoogleFonts.poppins(
                                              color: AppColors.brandGold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rulebook Lawyer'.tr,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.brandGold,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            driverModel.fullName.toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverModel.email.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your legal support dashboard, wallet and case updates in one place.'.tr,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      default:
                        return Text('Error'.tr);
                    }
                  }),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Column(children: drawerOptions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _initialsFromName(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'RL';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
