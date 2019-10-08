/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Builder.swift

/// The base builder protocol that all builders should conform to.
abstract class Buildable {}

/// Utility that instantiates a RIB and sets up its internal wirings.
class Builder<T> extends Buildable {
  /// The dependency used for this builder to build the RIB.
  final T dependency;

  /// Initializer.
  ///
  /// - parameter dependency: The dependency used for this builder to build the RIB.
  Builder(this.dependency);
}
