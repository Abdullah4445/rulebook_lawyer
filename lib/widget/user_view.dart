import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserView extends StatefulWidget {
  final String? userId;
  final String? amount;
  final String? distance;
  final String? distanceType;

  const UserView({Key? key, this.userId, this.amount, this.distance, this.distanceType})
      : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final fetchedUser = await FireStoreUtils.getCustomer(widget.userId.toString());
      if (mounted) {
        setState(() {
          user = fetchedUser;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double parsedAmount = double.tryParse(widget.amount ?? '0') ?? 0.0;
    final double parsedDistance = double.tryParse(widget.distance ?? '0') ?? 0.0;
    final String displayAmount =
        parsedAmount > 0 ? Constant.amountShow(amount: parsedAmount.toString()) : "-";
    final String displayDistance = parsedDistance > 0
        ? "${parsedDistance.toStringAsFixed(Constant.currencyModel?.decimalDigits ?? 2)} ${widget.distanceType}"
        : "-";

    final String displayName = user?.fullName ?? "Asynchronous user";
    final String profilePic = user?.profilePic ?? Constant.userPlaceHolder;

    if (isLoading) {
      return const SizedBox();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: CachedNetworkImage(
            height: 50,
            width: 50,
            imageUrl: profilePic,
            fit: BoxFit.cover,
            placeholder: (context, url) => Constant.loader(context),
            errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(displayName, style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('💰'),
                      const SizedBox(width: 5),
                      Text(displayAmount,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 5),
                      Text(displayDistance,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.star, size: 22, color: AppColors.ratingColour),
                      const SizedBox(width: 5),
                      Text(
                        Constant.calculateReview(
                          reviewCount: user?.reviewsCount ?? "0",
                          reviewSum: user?.reviewsSum ?? "0",
                        ),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
