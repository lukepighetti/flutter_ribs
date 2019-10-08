/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/DI/Dependency.swift

/// The base dependency protocol.
///
/// Subclasses should define a set of properties that are required by the module from the DI graph. A dependency is
/// typically provided and satisfied by its immediate parent module.
abstract class Dependency {}

/// The special empty dependency.
abstract class EmptyDependency extends Dependency {}
