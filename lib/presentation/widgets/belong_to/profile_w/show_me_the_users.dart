import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/config/routes/app_routes.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/utility/define_function.dart';
import 'package:instagram/data/models/parent_classes/without_sub_classes/user_personal_info.dart';
import 'package:instagram/core/functions/toast_show.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/user_info_cubit.dart';
import '../../../cubit/follow/follow_cubit.dart';
import '../../global/circle_avatar_image/circle_avatar_of_profile_image.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/widgets/belong_to/profile_w/which_profile_page.dart';

class ShowMeTheUsers extends StatefulWidget {
  final List<UserPersonalInfo> usersInfo;
  final bool isThatFollower;
  final bool showColorfulCircle;
  final String emptyText;
  final bool isThatMyPersonalId;
  final UpdateFollowersCallback? updateFollowedCallback;

  const ShowMeTheUsers({
    Key? key,
    this.updateFollowedCallback,
    required this.isThatMyPersonalId,
    this.showColorfulCircle = true,
    this.isThatFollower = true,
    required this.usersInfo,
    required this.emptyText,
  }) : super(key: key);

  @override
  State<ShowMeTheUsers> createState() => _ShowMeTheUsersState();
}

class _ShowMeTheUsersState extends State<ShowMeTheUsers> {
  late UserPersonalInfo myPersonalInfo;
  @override
  initState() {
    myPersonalInfo = UserInfoCubit.getMyPersonalInfo(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.usersInfo.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            return containerOfUserInfo(
                widget.usersInfo[index], widget.isThatFollower);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: widget.usersInfo.length,
        ),
      );
    } else {
      return Center(
        child: Text(
          widget.emptyText,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
  }

  Widget containerOfUserInfo(UserPersonalInfo userInfo, bool isThatFollower) {
    String hash = "${userInfo.userId.hashCode}userInfo";

    return InkWell(
      onTap: () async {
        Navigator.of(context).maybePop();
        await pushToPage(context,
            page: WhichProfilePage(userId: userInfo.userId),
            withoutRoot: false);
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, top: 15),
        child: Row(children: [
          Hero(
            tag: hash,
            child: CircleAvatarOfProfileImage(
              bodyHeight: 600,
              hashTag: hash,
              userInfo: userInfo,
              showColorfulCircle: widget.showColorfulCircle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo.userName,
                  style: Theme.of(context).textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Text(
                  userInfo.name,
                  style: Theme.of(context).textTheme.displayLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
          ),
          // const Spacer(),
          followButton(userInfo, isThatFollower),
        ]),
      ),
    );
  }

  Widget followButton(UserPersonalInfo userInfo, bool isThatFollower) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (followContext, stateOfFollow) {
        return Builder(
          builder: (userContext) {
            if (myPersonalId == userInfo.userId) {
              return Container();
            } else {
              return GestureDetector(
                  onTap: () async {
                    if (myPersonalInfo.followedPeople
                        .contains(userInfo.userId)) {
                      BlocProvider.of<FollowCubit>(followContext)
                          .unFollowThisUser(
                              followingUserId: userInfo.userId,
                              myPersonalId: myPersonalId);
                      BlocProvider.of<UserInfoCubit>(context)
                          .updateMyFollowings(
                              userId: userInfo.userId, addThisUser: false);
                      if (widget.updateFollowedCallback != null) {
                        widget.updateFollowedCallback!(false, userInfo.userId);
                      }
                    } else {
                      BlocProvider.of<FollowCubit>(followContext)
                          .followThisUser(
                              followingUserId: userInfo.userId,
                              myPersonalId: myPersonalId);
                      BlocProvider.of<UserInfoCubit>(context)
                          .updateMyFollowings(userId: userInfo.userId);
                      if (widget.updateFollowedCallback != null) {
                        widget.updateFollowedCallback!(true, userInfo.userId);
                      }
                    }
                  },
                  child: whichContainerOfText(stateOfFollow, userInfo));
            }
          },
        );
      },
    );
  }

  Widget whichContainerOfText(
      FollowState stateOfFollow, UserPersonalInfo userInfo) {
    if (stateOfFollow is CubitFollowThisUserFailed) {
      ToastShow.toastStateError(stateOfFollow);
    }

    return !myPersonalInfo.followedPeople.contains(userInfo.userId)
        ? containerOfFollowText(
            text: StringsManager.follow.tr,
            isThatFollower: false,
          )
        : containerOfFollowText(
            text: StringsManager.following.tr,
            isThatFollower: true,
          );
  }

  Widget containerOfFollowText(
      {required String text, required bool isThatFollower}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 45, end: 15),
      child: Container(
        height: 32.0,
        decoration: BoxDecoration(
          color: isThatFollower
              ? Theme.of(context).primaryColor
              : ColorManager.blue,
          border: isThatFollower
              ? Border.all(
                  color: Theme.of(context).bottomAppBarColor, width: 1.0)
              : null,
          borderRadius: BorderRadius.circular(isThatMobile ? 15 : 5),
        ),
        child: Center(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isThatFollower ? 10.0 : 22),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 17.0,
                  color: isThatFollower
                      ? Theme.of(context).focusColor
                      : ColorManager.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
