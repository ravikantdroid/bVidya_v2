import 'routes.dart';

export 'package:flutter/material.dart';
// export 'package:sizer/sizer.dart';
export 'package:flutter_easyloading/flutter_easyloading.dart';
export '/ui/widget/app_snackbar.dart';
export '../generated/l10n.dart';
export 'theme/appstyle.dart';
export 'theme/textstyles.dart';
export 'theme/inputstyle.dart';
export 'utils/widgets.dart';
export 'utils/sizer.dart';

void setScreen(String name) {
  Routes.setToScreen(name);
}
