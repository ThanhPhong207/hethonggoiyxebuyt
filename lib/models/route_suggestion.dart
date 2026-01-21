import 'dart:ui';
import 'package:latlong2/latlong.dart';

enum StepType { walk, bus, transfer }

class RouteStep {
  final StepType type;
  final String title;
  final double distanceMeters;
  final double durationMinutes;
  final String? busCode;

  RouteStep({
    required this.type,
    required this.title,
    required this.distanceMeters,
    required this.durationMinutes,
    this.busCode,
  });
}

class RoutePolylineSegment {
  final List<LatLng> points;
  final Color color;
  final String label;
  final bool isBus;

  RoutePolylineSegment({
    required this.points,
    required this.color,
    required this.label,
    required this.isBus,
  });
}

class RouteOption {
  final String id;
  final String title;

  final double totalMeters;
  final double totalMinutes;
  final int totalPriceVnd;

  final double walkMeters;

  final List<RouteStep> steps;
  final List<RoutePolylineSegment> segments;
  final List<LatLng> highlights;
  final LatLng? transferPoint;

  RouteOption({
    required this.id,
    required this.title,
    required this.totalMeters,
    required this.totalMinutes,
    required this.totalPriceVnd,
    required this.walkMeters,
    required this.steps,
    required this.segments,
    required this.highlights,
    this.transferPoint,
  });
}
