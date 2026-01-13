import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';
import 'package:pulsetrade_app/features/home/presentation/providers/home_feed_provider.dart';

/// Provider for comments by stock ticker
/// 
/// Usage:
/// ```dart
/// final commentsAsync = ref.watch(commentsProvider('TSLA'));
/// ```
final commentsProvider = FutureProvider.family<List<CommentData>, String>((ref, ticker) async {
  final repository = ref.watch(homeFeedRepositoryProvider);
  return repository.getComments(ticker);
});

