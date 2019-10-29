import 'package:flutter/material.dart';

import '../../widgets/gradientBackground.dart';
import '../../widgets/bigContainer.dart';
import '../../helper/appConfig.dart';

mixin BaseSettingsPage {
  final double blockHeight = AppConfig.blockSizeHeight;
  final double blockWidth = AppConfig.blockSizeWidth;

  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: BigContainer(child: body(context)),
      ),
    );
  }

  Widget body(BuildContext context);
}
