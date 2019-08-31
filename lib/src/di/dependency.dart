/// The base dependency protocol.
///
/// Subclasses should define a set of properties that are required by the module from the DI graph. A dependency is
/// typically provided and satisfied by its immediate parent module.
// public protocol Dependency: class {}
abstract class Dependency {}

/// The special empty dependency.
// public protocol EmptyDependency: Dependency {}
abstract class EmptyDependency extends Dependency {}
