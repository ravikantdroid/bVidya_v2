import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '/core/state.dart';
import '/core/theme/appstyle.dart';
import '/core/theme/inputstyle.dart';
import '/core/theme/textstyles.dart';
import '../../../../generated/l10n.dart';
import '../base_settings.dart';

class StudentProfileDetail extends StatelessWidget {
  StudentProfileDetail({super.key});

  //texteditingController
  // final nameTextController = useTextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return BaseSettings(
      bodyContent: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              "${S.current.profile_title} Detail", //didn't added throught l10n
              style: textStyleHeading,
            ),
            SizedBox(height: 2.h),
            Text(
              "Name", //didn't added throught l10n
              style: inputBoxCaptionStyle(context),
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDirectionStyle.copyWith(
                hintText: S.current.signup_fullname_hint,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Email Address", //didn't added throught l10n
              style: inputBoxCaptionStyle(context),
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDirectionStyle.copyWith(
                hintText: S.current.login_email_hint,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Phone Number", //didn't added throught l10n
              style: inputBoxCaptionStyle(context),
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDirectionStyle.copyWith(
                hintText: S.current.signup_mobile_hint,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Age", //didn't added throught l10n
              style: inputBoxCaptionStyle(context),
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDirectionStyle.copyWith(
                hintText: S.current.prof_hint_age,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Address", //didn't added throught l10n
              style: inputBoxCaptionStyle(context),
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: inputDirectionStyle.copyWith(
                hintText: S.current.prof_edit_address,
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: elevatedButtonTextStyle,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Save",
                      style: elevationTextButtonTextStyle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
