import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/core/resources/assets_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/resources/styles_manager.dart';
import 'package:instagram/presentation/pages/activity/activity_for_mobile.dart';

class ActivityForWeb extends StatelessWidget {
  const ActivityForWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  PopupMenuButton<Widget>(
      position: PopupMenuPosition.under,
      elevation: 20,color:Theme.of(context).splashColor ,
      offset: const Offset(90, 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SvgPicture.asset(
        IconsAssets.add2Icon,
        color: Theme.of(context).focusColor,
        height: 700,
        width: 500,
      ),
      itemBuilder: (context) => [
      PopupMenuItem<Widget>(
      child:ActivityPage(),
      ),
      ],
    );
  }

}
