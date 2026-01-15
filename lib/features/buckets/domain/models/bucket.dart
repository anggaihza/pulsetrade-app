import 'package:flutter/material.dart';

/// Bucket entity representing a portfolio bucket
/// 
/// A bucket is a collection of stocks grouped by category (e.g., Financial, Technology, Tourism)
class Bucket {
  final String id;
  final String name;
  final double priceChange;
  final double priceChangePercent;
  final bool isPositive;
  final bool isPublic;
  final int? bookmarksCount;
  final int? checkmarksCount;
  final Color avatarColor;
  final String? imageAsset;

  const Bucket({
    required this.id,
    required this.name,
    required this.priceChange,
    required this.priceChangePercent,
    required this.isPositive,
    required this.isPublic,
    this.bookmarksCount,
    this.checkmarksCount,
    required this.avatarColor,
    this.imageAsset,
  });
}

