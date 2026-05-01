import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/user_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserView extends StatelessWidget {
  final String? userId;
  final String? amount;
  final String? distance;
  final String? distanceType;

  const UserView({
    Key? key,
    this.userId,
    this.amount,
    this.distance,
    this.distanceType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getCustomer(userId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Loading user...",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildUserRow(
            context,
            imageUrl: Constant.userPlaceHolder,
            name: "Unknown User",
            rating: "0.0",
            reviewCount: "0",
            amount: amount ?? '0',
            distance: distance ?? '0',
            distanceType: distanceType ?? 'km',
          );
        }

        UserModel user = snapshot.data!;

        return _buildUserRow(
          context,
          imageUrl: user.profilePic ?? Constant.userPlaceHolder,
          name: user.fullName ?? "No Name",
          rating: Constant.calculateReview(
            reviewCount: user.reviewsCount,
            reviewSum: user.reviewsSum,
          ),
          reviewCount: user.reviewsCount ?? "0",
          amount: amount ?? '0',
          distance: distance ?? '0',
          distanceType: distanceType ?? 'km',
        );
      },
    );
  }

  /// ðŸ”¹ Reusable row builder
  Widget _buildUserRow(
      BuildContext context, {
        required String imageUrl,
        required String name,
        required String rating,
        required String reviewCount,
        required String amount,
        required String distance,
        required String distanceType,
      }) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color?.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.78 : 0.72,
        ) ??
        (theme.brightness == Brightness.dark ? AppColors.gray300 : AppColors.gray600);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: CachedNetworkImage(
            height: 50,
            width: 50,
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Constant.loader(context),
            errorWidget: (context, url, error) => Image.network(
              Constant.userPlaceHolder,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ðŸ‘¤ User name
              Text(
                name.isEmpty ? "No Name" : name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),

              /// ðŸ’°, ðŸ“, â­ info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ðŸ’° Amount
                  // Text(
                  //   Constant.amountShow(amount: amount),
                  //   style: GoogleFonts.poppins(
                  //     fontWeight: FontWeight.w500,
                  //     fontSize: 13,
                  //     color: Colors.black,
                  //   ),
                  // ),

                  // ðŸ“ Distance
                  Row(
                    children: [
                      // const Icon(Icons.location_on,
                      //     size: 16, color: Colors.blueAccent),
                      // const SizedBox(width: 3),
                      // Text(
                      //   "${double.tryParse(distance)?.toStringAsFixed(Constant.currencyModel?.decimalDigits ?? 2) ?? '0.00'} $distanceType",
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 13,
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),

                  // â­ Rating
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 18, color: AppColors.ratingColour),
                      const SizedBox(width: 3),
                      Text(
                        rating.isEmpty ? "0.0" : rating,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
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





// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:lawyer/constant/constant.dart';
// import 'package:lawyer/model/user_model.dart';
// import 'package:lawyer/themes/app_colors.dart';
// import 'package:lawyer/utils/fire_store_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class UserView extends StatelessWidget {
//   final String? userId;
//   final String? amount;
//   final String? distance;
//   final String? distanceType;
//
//   const UserView({Key? key, this.userId, this.amount, this.distance, this.distanceType,}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<UserModel?>(
//         future: FireStoreUtils.getCustomer(userId.toString()),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return const SizedBox();
//             case ConnectionState.done:
//               if (snapshot.hasError) {
//                 return Text(snapshot.error.toString());
//               } else {
//                 if (snapshot.data == null) {
//                   return Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.all(Radius.circular(10)),
//                         child: CachedNetworkImage(
//                           height: 50,
//                           width: 50,
//                           imageUrl: Constant.userPlaceHolder,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Constant.loader(context),
//                           errorWidget: (context, url, error) => Image.network(
//                               'https://firebasestorage.googleapis.com/v0/b/goflow-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Asynchronous user", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(Constant.amountShow(amount: amount.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       size: 18,
//                                     ),
//                                     const SizedBox(
//                                       width: 5,
//                                     ),
//                                     Text("${(double.parse(distance.toString())).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} $distanceType",
//                                         style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.star,
//                                       size: 22,
//                                       color: AppColors.ratingColour,
//                                     ),
//                                     const SizedBox(
//                                       width: 5,
//                                     ),
//                                     Text(Constant.calculateReview(reviewCount: "0.0", reviewSum: "0.0"), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//                                   ],
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//                 UserModel driverModel = snapshot.data!;
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                       child: CachedNetworkImage(
//                         height: 50,
//                         width: 50,
//                         imageUrl: driverModel.profilePic.toString(),
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Constant.loader(context),
//                         errorWidget: (context, url, error) => Image.network(
//                             'https://firebasestorage.googleapis.com/v0/b/goflow-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(driverModel.fullName.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(Constant.amountShow(amount: amount.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(
//                                     width: 5,
//                                   ),
//                                   Text(
//                                     "${double.tryParse(distance?.toString() ?? '0')?.toStringAsFixed(Constant.currencyModel?.decimalDigits ?? 2)} $distanceType",
//                                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                                   )
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.star,
//                                     size: 22,
//                                     color: AppColors.ratingColour,
//                                   ),
//                                   const SizedBox(
//                                     width: 5,
//                                   ),
//                                   Text(Constant.calculateReview(reviewCount: driverModel.reviewsCount, reviewSum: driverModel.reviewsSum), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
//                                 ],
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }
//             default:
//               return const Text('Error');
//           }
//         });
//   }
// }
}
