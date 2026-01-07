import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_text_field.dart';
import 'package:pulsetrade_app/core/theme/app_colors.dart';
import 'package:pulsetrade_app/core/theme/typography.dart';
import 'package:pulsetrade_app/features/home/domain/models/stock_data.dart';

/// Bottom sheet for displaying and adding comments
class CommentsBottomSheet extends StatefulWidget {
  final List<CommentData> comments;
  final VoidCallback? onAddComment;
  final void Function(String)? onLikeComment;

  const CommentsBottomSheet({
    super.key,
    required this.comments,
    this.onAddComment,
    this.onLikeComment,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.comments.length} comments',
              style: AppTextStyles.labelLarge(
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 14),
            ),
          ),
          
          const Divider(
            color: Color(0xFF2C2C2C),
            height: 1,
          ),
          
          // Comments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return _CommentItem(
                  comment: comment,
                  onLike: () => widget.onLikeComment?.call(comment.id),
                );
              },
            ),
          ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      TablerIcons.user,
                      size: 20,
                      color: Color(0xFFAEAEAE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text field
                  Expanded(
                    child: AppTextField(
                      label: '',
                      placeholder: 'Add comment',
                      controller: _commentController,
                      showLabel: false,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  
                  // Send button (optional, if needed)
                  if (_commentController.text.trim().isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        widget.onAddComment?.call();
                        _commentController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        TablerIcons.send,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentData comment;
  final VoidCallback? onLike;

  const _CommentItem({
    required this.comment,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              TablerIcons.user,
              size: 24,
              color: Color(0xFFAEAEAE),
            ),
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Text(
                  comment.userName,
                  style: AppTextStyles.labelLarge(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                
                // Comment text
                Text(
                  comment.comment,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Actions (timestamp, reply, like)
                Row(
                  children: [
                    Text(
                      comment.timestamp,
                      style: AppTextStyles.bodySmall(
                        color: const Color(0xFFAEAEAE),
                      ).copyWith(fontSize: 10),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Reply',
                      style: AppTextStyles.labelSmall(
                        color: const Color(0xFFAEAEAE),
                      ).copyWith(fontSize: 10),
                    ),
                    if (comment.replies > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        'View ${comment.replies} Replies',
                        style: AppTextStyles.labelSmall(
                          color: const Color(0xFFAEAEAE),
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Like button
          Column(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Icon(
                  comment.isLiked ? TablerIcons.heart_filled : TablerIcons.heart,
                  size: 16,
                  color: comment.isLiked ? AppColors.error : const Color(0xFFAEAEAE),
                ),
              ),
              if (comment.likes > 0) ...[
                const SizedBox(height: 4),
                Text(
                  comment.likes.toString(),
                  style: AppTextStyles.bodySmall(
                    color: const Color(0xFFAEAEAE),
                  ).copyWith(fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Show comments bottom sheet
void showCommentsSheet(
  BuildContext context,
  List<CommentData> comments, {
  VoidCallback? onAddComment,
  void Function(String)? onLikeComment,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: CommentsBottomSheet(
          comments: comments,
          onAddComment: onAddComment,
          onLikeComment: onLikeComment,
        ),
      );
    },
  );
}
