import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for stocks chart data matching Figma mockup
/// Returns the exact data points from Figma design
final stocksChartDataProvider = Provider.family<List<double>, String>((ref, ticker) {
  // Figma chart data from ConfigAndData component
  // Normalized values (0-100 range) that need to be mapped to price range
  const figmaData = [
    0, 0, 4, 11, 9, 8, 8, 8, 8, 6, 6, 7, 6, 10, 8, 16, 15, 19, 19, 26, 27, 31,
    30, 36, 39, 47, 53, 59, 58, 56, 60, 63, 61, 61, 59, 60, 60, 59, 62, 67, 69,
    73, 72, 70, 72, 77, 81, 81, 81, 83, 78, 79, 80, 81, 83, 84, 82, 78, 74, 76,
    76, 72, 67, 64, 64, 65, 66, 63, 64, 61, 62, 56, 54, 46, 47, 49, 48, 42, 38,
    39, 39, 41, 41, 42, 37, 31, 26, 27, 25, 20, 21, 22, 15, 16, 16, 17, 13, 9, 10, 7
  ];

  // Map normalized values (0-100) to price range (6,800 - 6,830)
  // Based on Figma Y-axis: 6,800, 6,810, 6,820, 6,830
  const minPrice = 6800.0;
  const maxPrice = 6830.0;
  const dataMin = 0.0;
  const dataMax = 100.0;

  return figmaData.map((normalizedValue) {
    // Normalize to 0-1 range
    final normalized = (normalizedValue - dataMin) / (dataMax - dataMin);
    // Map to price range
    return minPrice + (normalized * (maxPrice - minPrice));
  }).toList();
});

