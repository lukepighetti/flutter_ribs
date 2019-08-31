import 'package:meta/meta.dart';
// import Foundation

/// The base builder protocol that all builders should conform to.
// public protocol Buildable: class {}
abstract class Buildable {}

/// Utility that instantiates a RIB and sets up its internal wirings.
// open class Builder<DependencyType>: Buildable {
class Builder<T> extends Buildable {
//     /// The dependency used for this builder to build the RIB.
//     public let dependency: DependencyType
  final T dependency;

//     /// Initializer.
//     ///
//     /// - parameter dependency: The dependency used for this builder to build the RIB.
//     public init(dependency: DependencyType) {
//         self.dependency = dependency
//     }
  Builder({@required this.dependency});
}
