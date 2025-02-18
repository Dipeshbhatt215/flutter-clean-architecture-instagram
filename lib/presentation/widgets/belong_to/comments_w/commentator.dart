import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/config/routes/app_routes.dart';
import 'package:instagram/core/functions/date_of_now.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/resources/styles_manager.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/data/models/comment.dart';
import 'package:instagram/data/models/notification.dart';
import 'package:instagram/data/models/post.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import 'package:instagram/domain/entities/notification_check.dart';
import 'package:instagram/presentation/cubit/notification/notification_cubit.dart';
import 'package:instagram/presentation/cubit/postInfoCubit/commentsInfo/cubit/comment_likes/comment_likes_cubit.dart';
import 'package:instagram/presentation/cubit/postInfoCubit/commentsInfo/cubit/repliesInfo/replyLikes/reply_likes_cubit.dart';
import 'package:instagram/presentation/cubit/postInfoCubit/commentsInfo/cubit/repliesInfo/reply_info_cubit.dart';
import 'package:instagram/presentation/pages/profile/users_who_likes_for_mobile.dart';
import 'package:instagram/presentation/widgets/belong_to/profile_w/which_profile_page.dart';
import 'package:instagram/presentation/widgets/global/circle_avatar_image/circle_avatar_of_profile_image.dart';
import 'package:instagram/core/functions/toast_show.dart';

// ignore: must_be_immutable
class CommentInfo extends StatefulWidget {
  int index;
  bool addReply;
  bool isThatReply;
  final Comment commentInfo;
  final bool rebuildComment;
  Map<int, bool> showMeReplies;
  UserPersonalInfo myPersonalInfo;
  ValueNotifier<TextEditingController> textController;
  final ValueNotifier<ValueChanged<Comment>>? selectedCommentInfo;
  final ValueChanged<bool> rebuildCallback;
  final Post postInfo;
  ValueNotifier<FocusNode> currentFocus;

  CommentInfo(
      {Key? key,
      required this.commentInfo,
      required this.currentFocus,
      this.selectedCommentInfo,
      required this.index,
      this.isThatReply = false,
      required this.myPersonalInfo,
      required this.rebuildComment,
      required this.showMeReplies,
      required this.rebuildCallback,
      required this.addReply,
      required this.textController,
      required this.postInfo})
      : super(key: key);

  @override
  State<CommentInfo> createState() => _CommentInfoState();
}

class _CommentInfoState extends State<CommentInfo> {
  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.commentInfo.likes.contains(myPersonalId);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10.0, end: 10),
      child: Column(
        children: [
          rowOfCommentator(context, isLiked, widget.commentInfo.theComment),
          if (!widget.isThatReply && widget.commentInfo.replies!.isNotEmpty)
            widget.showMeReplies[widget.index] == false
                ? textOfReplyCount(context)
                : showReplies(context),
        ],
      ),
    );
  }

  BlocBuilder<ReplyInfoCubit, ReplyInfoState> showReplies(
      BuildContext context) {
    return BlocBuilder<ReplyInfoCubit, ReplyInfoState>(
        bloc: BlocProvider.of<ReplyInfoCubit>(context)
          ..getRepliesOfThisComment(commentId: widget.commentInfo.commentUid),
        buildWhen: (previous, current) {
          if (previous != current && (current is CubitReplyInfoLoaded)) {
            return true;
          }
          if (widget.rebuildComment) {
            widget.rebuildCallback(false);
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is CubitReplyInfoLoaded) {
            List<Comment> repliesInfo =
                BlocProvider.of<ReplyInfoCubit>(context).repliesOnComment;
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 40.0),
              child: ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return CommentInfo(
                      showMeReplies: widget.showMeReplies,
                      commentInfo: repliesInfo[index],
                      textController: widget.textController,
                      rebuildCallback: widget.rebuildCallback,
                      index: index,
                      selectedCommentInfo: widget.selectedCommentInfo,
                      myPersonalInfo: widget.myPersonalInfo,
                      addReply: widget.addReply,
                      isThatReply: true,
                      rebuildComment: widget.rebuildComment,
                      postInfo: widget.postInfo,
                      currentFocus: widget.currentFocus,
                    );
                  },
                  itemCount: repliesInfo.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(
                        height: 20,
                      )),
            );
          } else if (state is CubitReplyInfoFailed) {
            ToastShow.toastStateError(state);
            return Text(state.toString(),
                style: Theme.of(context).textTheme.bodyText1);
          } else {
            return textOfLoading(context, StringsManager.loading.tr());
          }
        });
  }

  Padding textOfLoading(BuildContext context, String loadingText) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 50.0),
      child: Row(
        children: [
          Container(
              color: Theme.of(context).dividerColor, height: 1, width: 40),
          const SizedBox(width: 10),
          Expanded(
            child:
                Text(loadingText, style: Theme.of(context).textTheme.headline1),
          )
        ],
      ),
    );
  }

  Padding textOfReplyCount(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 50.0, bottom: 10),
      child: Row(
        children: [
          Container(
              color: Theme.of(context).dividerColor, height: 1, width: 40),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.showMeReplies.update(widget.index, (value) => true);
                });
              },
              child: Text(
                "${StringsManager.view.tr()} ${widget.commentInfo.replies!.length} ${StringsManager.more.tr()} ${widget.commentInfo.replies!.length > 1 ? StringsManager.replies.tr() : StringsManager.reply.tr()}",
                style: getNormalStyle(color: Theme.of(context).indicatorColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  Row rowOfCommentator(
      BuildContext context, bool isLiked, String hashTageOfUserName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        profileImage(context),
        const SizedBox(width: 8),
        buildCommentInfo(context, hashTageOfUserName),
        if (!widget.commentInfo.isLoading) loveButton(isLiked, context)
      ],
    );
  }

  GestureDetector profileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pushToPage(context, page:  WhichProfilePage(
            userId: widget.commentInfo.whoCommentInfo!.userId),withoutRoot: false);
      },
      child: CircleAvatarOfProfileImage(
        userInfo: widget.commentInfo.whoCommentInfo!,
        bodyHeight: widget.isThatReply ? 280 : 400,
      ),
    );
  }

  Expanded buildCommentInfo(BuildContext context, String hashTageOfUserName) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 3.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              whoCommentUserName(context, hashTageOfUserName),
              const SizedBox(height: 5),
              commentOption(context),
              const SizedBox(height: 15),
            ]),
      ),
    );
  }

  Widget commentOption(BuildContext context) {
    return Row(
      children: [
        Text(DateOfNow.commentsDateOfNow(widget.commentInfo.datePublished),
            style: Theme.of(context).textTheme.headline1),
        if (widget.commentInfo.likes.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 20.0),
            child: InkWell(
              onTap: () {
                pushToPage(context, page:  UsersWhoLikesForMobile(
                  showSearchBar: false,
                  usersIds: widget.commentInfo.likes,
                  isThatMyPersonalId:
                  widget.commentInfo.whoCommentId == myPersonalId,
                ),withoutRoot: false);

              },
              child: Text(
                "${widget.commentInfo.likes.length} ${widget.commentInfo.likes.length == 1 ? StringsManager.like.tr() : StringsManager.likes.tr()}",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () async {
            String hashTag = "@${widget.commentInfo.whoCommentInfo!.userName} ";

            widget.textController.value.text = hashTag;

            widget.textController.value.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.textController.value.text.length));
            Comment commentInfo = widget.commentInfo;
            if (widget.commentInfo.parentCommentId.isEmpty) {
              commentInfo.parentCommentId = commentInfo.commentUid;
            }
            // widget.currentFocus.value.requestFocus();

            setState(() {
              widget.selectedCommentInfo!.value(commentInfo);
            });
          },
          child: Text(
            StringsManager.reply.tr(),
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ],
    );
  }

  GestureDetector whoCommentUserName(
      BuildContext context, String hashTageOfUserName) {
    return GestureDetector(
      onTap: () {
        pushToPage(context, page:  WhichProfilePage(
            userId: widget.commentInfo.whoCommentInfo!.userId));
      },
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: widget.commentInfo.whoCommentInfo!.userName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const TextSpan(
              text: '  ',
            ),
            if (widget.isThatReply)
              TextSpan(
                text: hashTageOfUserName.split(" ")[0],
                style: getNormalStyle(color: ColorManager.lightBlue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    List<String> hashTagName = hashTageOfUserName.split(" ");
                    String userName = hashTagName[0].replaceAll('@', '');
                    await pushToPage(context, page: WhichProfilePage(
                      userName: userName,
                    ));
                  },
              ),
            TextSpan(
              style: TextStyle(color: Theme.of(context).focusColor),
              text:
                  " ${widget.isThatReply ? hashTageOfUserName.split(" ")[1] : hashTageOfUserName}",
            )
          ],
        ),
      ),
    );
  }

  Widget loveButton(bool isLiked, BuildContext context) {
    return GestureDetector(
      child: !isLiked
          ? const Icon(
              Icons.favorite_border,
              size: 15,
              color: Colors.grey,
            )
          : const Icon(
              Icons.favorite,
              size: 15,
              color: Colors.red,
            ),
      onTap: () {
        setState(() {
          if (isLiked) {
            if (widget.isThatReply) {
              BlocProvider.of<ReplyLikesCubit>(context).removeLikeOnThisReply(
                  replyId: widget.commentInfo.commentUid,
                  myPersonalId: myPersonalId);
            } else {
              BlocProvider.of<CommentLikesCubit>(context)
                  .removeLikeOnThisComment(
                postId: widget.commentInfo.postId,
                commentId: widget.commentInfo.commentUid,
                myPersonalId: myPersonalId,
              );
            }
            widget.commentInfo.likes.remove(myPersonalId);
            //for notification
            BlocProvider.of<NotificationCubit>(context).deleteNotification(
                notificationCheck: createNotificationCheck(widget.postInfo));
          } else {
            if (widget.isThatReply) {
              BlocProvider.of<ReplyLikesCubit>(context).putLikeOnThisReply(
                replyId: widget.commentInfo.commentUid,
                myPersonalId: myPersonalId,
              );
            } else {
              BlocProvider.of<CommentLikesCubit>(context).putLikeOnThisComment(
                postId: widget.commentInfo.postId,
                commentId: widget.commentInfo.commentUid,
                myPersonalId: myPersonalId,
              );
            }
            widget.commentInfo.likes.add(myPersonalId);
            //for notification
            BlocProvider.of<NotificationCubit>(context).createNotification(
                newNotification: createNotification(widget.commentInfo));
          }
        });
      },
    );
  }

  NotificationCheck createNotificationCheck(Post postInfo) {
    return NotificationCheck(
      senderId: myPersonalId,
      receiverId: postInfo.publisherId,
      postId: postInfo.postUid,
      isThatLike: false,
    );
  }

  CustomNotification createNotification(Comment commentInfo) {
    return CustomNotification(
      text: "liked your comment:${commentInfo.theComment}",
      postId: widget.postInfo.postUid,
      postImageUrl: widget.postInfo.imagesUrls.length > 1
          ? widget.postInfo.imagesUrls[0]
          : widget.postInfo.postUrl,
      time: DateOfNow.dateOfNow(),
      senderId: myPersonalId,
      receiverId: widget.postInfo.publisherId,
      personalUserName: widget.myPersonalInfo.userName,
      personalProfileImageUrl: widget.myPersonalInfo.profileImageUrl,
      isThatLike: false,
    );
  }
}
