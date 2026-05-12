import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact card that shows the case's source address to the lawyer.
///
/// When [latitude] / [longitude] are supplied (the customer's exact pin),
/// the whole row becomes tappable and opens the location in the user's
/// default maps app — this is how the lawyer sees *exactly* where the
/// case was filed from. A small "Open in Maps" affordance is shown to
/// hint at the action.
class LocationView extends StatelessWidget {
  final String? sourceLocation;
  final String? destinationLocation;

  /// Customer's source-pin coordinates. Coming from
  /// `OrderModel.sourceLocationLatLng` written by the customer app.
  final double? latitude;
  final double? longitude;

  /// Override the default tap action (e.g. to use a custom in-app map).
  final VoidCallback? onTap;

  const LocationView({
    super.key,
    this.sourceLocation,
    this.destinationLocation,
    this.latitude,
    this.longitude,
    this.onTap,
  });

  bool get _hasCoords =>
      latitude != null &&
      longitude != null &&
      latitude!.abs() > 0.000001 &&
      longitude!.abs() > 0.000001;

  Future<void> _openInMaps() async {
    if (!_hasCoords) return;
    final lat = latitude!.toStringAsFixed(6);
    final lng = longitude!.toStringAsFixed(6);
    // `geo:` is the Android intent — most maps apps respond. iOS falls
    // through to Google Maps over https. Explicit Google fallback last.
    final candidates = <Uri>[
      Uri.parse('geo:$lat,$lng?q=$lat,$lng${sourceLocation != null ? "(${Uri.encodeComponent(sourceLocation!)})" : ""}'),
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
    ];
    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {/* try next candidate */}
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final textColor = Theme.of(context).colorScheme.onSurface;

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SvgPicture.asset(
              themeChange.getThem()
                  ? 'assets/icons/ic_source_dark.svg'
                  : 'assets/icons/ic_source.svg',
              width: 18,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sourceLocation?.trim().isNotEmpty == true
                    ? sourceLocation!
                    : 'Location not specified',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(color: textColor),
              ),
              if (_hasCoords) ...[
                const SizedBox(height: 4),
                // Wrap (not Row) so coords + hint flow to a second line on
                // narrow screens instead of overflowing horizontally.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 13, color: AppColors.brandGold),
                        const SizedBox(width: 3),
                        Text(
                          '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to open in Maps',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (_hasCoords)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.brandGold,
            ),
          ),
      ],
    );

    final tappable = onTap ?? (_hasCoords ? _openInMaps : null);
    if (tappable == null) return body;
    return InkWell(
      onTap: tappable,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: body,
      ),
    );
  }

}
