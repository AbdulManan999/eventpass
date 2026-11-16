import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:eventpass/models/Venue.dart';
import 'package:eventpass/utils/colors.dart';

/// OpenStreetMap preview of a venue with its self check-in geofence.
class VenueMap extends StatelessWidget {
  const VenueMap({super.key, required this.venue, this.height});

  final Venue venue;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(venue.latitude ?? 0, venue.longitude ?? 0);
    final radius = (venue.geofenceRadiusM ?? 200).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: height ?? 180.h,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            // One zoom level out per doubling of the radius keeps the circle in view.
            initialZoom: (15.6 - log(radius / 150) / ln2).clamp(12, 17).toDouble(),
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.abdulmanan.eventpass',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: center,
                  radius: radius,
                  useRadiusInMeter: true,
                  color: primaryColor.withValues(alpha: 0.12),
                  borderColor: primaryColor,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 36.w,
                  height: 36.w,
                  child: Icon(Icons.location_on, color: primaryColor, size: 36.sp),
                ),
              ],
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
          ],
        ),
      ),
    );
  }
}
