import 'package:flutter/widgets.dart';

// import UIKit

/// Basic interface between a `Router` and the UIKit `UIViewController`.
// public protocol ViewControllable: class {

//     var uiviewController: UIViewController { get }
// }

mixin ViewControllable on Widget {
  Widget get uiviewController => this;
}

/// Default implementation on `UIViewController` to conform to `ViewControllable` protocol
// public extension ViewControllable where Self: UIViewController {

//     var uiviewController: UIViewController {
//         return self
//     }
// }
