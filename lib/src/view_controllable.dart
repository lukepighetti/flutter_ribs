/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/ViewControllable.swift

import 'package:flutter/widgets.dart';

/// Basic interface between a `Router` and the UIKit `UIViewController`.
mixin ViewControllable on Widget {
  Widget get uiviewController => this;
}
