import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'composite_disposable.dart';
import 'interactor.dart';

/// The lifecycle stages of a router scope.
enum RouterLifecycle {
  /// Router did load
  didLoad,
}

/// The scope of a `Router`, defining various lifecycles of a `Router`.
abstract class RouterScope {
  /// An observable that emits values when the router scope reaches its corresponding life-cycle stages. This
  /// observable completes when the router scope is deallocated.
  Observable<RouterLifecycle> get lifecycle;
}

/// The base protocol for all routers.
abstract class Routing extends RouterScope {
  // The following methods must be declared in the base protocol, since `Router` internally  invokes these methods.
  // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
  // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
  // base class logic without error.
  /// The base interactable associated with this `Router`.

  // var interactable: Interactable { get }
  Interactable get interactable;

  /// The list of children routers of this `Router`.

  // var children: [Routing] { get }
  List<Routing> get children;

  /// Loads the `Router`.
  ///
  /// - note: This method is internally used by the framework. Application code should never
  ///   invoke this method explicitly.
  // func load()
  load();

  // We cannot declare the attach/detach child methods to take in concrete `Router` instances,
  // since during unit testing, we need to use mocked child routers.
  /// Attaches the given router as a child.
  ///
  /// - parameter child: The child router to attach.
  // func attachChild(_ child: Routing)
  attachChild(Routing child);

  /// Detaches the given router from the tree.
  ///
  /// - parameter child: The child router to detach.
  // func detachChild(_ child: Routing)
  detachChild(Routing child);
}

/// The base class of all routers that does not own view controllers, representing application states.
///
/// A router acts on inputs from its corresponding interactor, to manipulate application state, forming a tree of
/// routers. A router may obtain a view controller through constructor injection to manipulate view controller tree.
/// The DI structure guarantees that the injected view controller must be from one of this router's ancestors.
/// Router drives the lifecycle of its owned `Interactor`.
///
/// Routers should always use helper builders to instantiate children routers.
class Router<I extends Interactable> extends Routing {
  /// The corresponding `Interactor` owned by this `Router`.
  // public let interactor: InteractorType
  final I interactor;

  /// The base `Interactable` associated with this `Router`.
  // public let interactable: Interactable
  final Interactable interactable;

  /// The list of children `Router`s of this `Router`.
  // public final var children: [Routing] = []
  final List<Routing> children = [];

  /// The observable that emits values when the router scope reaches its corresponding life-cycle stages.
  ///
  /// This observable completes when the router scope is deallocated.
  // public final var lifecycle: Observable<RouterLifecycle> {
  //     return lifecycleSubject.asObservable()
  // }

  Observable<RouterLifecycle> get lifecycle => _lifecycleSubject;

  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  // public init(interactor: InteractorType) {
  //     self.interactor = interactor
  //     guard let interactable = interactor as? Interactable else {
  //         fatalError("\(interactor) should conform to \(Interactable.self)")
  //     }
  //     self.interactable = interactable
  // }
  Router({@required this.interactor}) : this.interactable = interactor;

  /// Loads the `Router`.
  ///
  /// - note: This method is internally used by the framework. Application code should never invoke this method
  ///   explicitly.
  // public final func load() {
  //     guard !didLoadFlag else {
  //         return
  //     }

  //     didLoadFlag = true
  //     internalDidLoad()
  //     didLoad()
  // }
  load() {
    if (_didLoadFlag == true) {
      return;
    }

    _didLoadFlag = true;
    internalDidLoad();
    didLoad();
  }

  /// Called when the router has finished loading.
  ///
  /// This method is invoked only once. Subclasses should override this method to perform one time setup logic,
  /// such as attaching immutable children. The default implementation does nothing.
  // open func didLoad() {
  //     // No-op
  // }

  didLoad() {}

  // We cannot declare the attach/detach child methods to take in concrete `Router` instances,
  // since during unit testing, we need to use mocked child routers.
  /// Attaches the given router as a child.
  ///
  /// - parameter child: The child `Router` to attach.
  // public final func attachChild(_ child: Routing) {
  //     assert(!(children.contains { $0 === child }), "Attempt to attach child: \(child), which is already attached to \(self).")

  //     children.append(child)

  //     // Activate child first before loading. Router usually attaches immutable children in didLoad.
  //     // We need to make sure the RIB is activated before letting it attach immutable children.
  //     child.interactable.activate()
  //     child.load()
  // }

  attachChild(Routing child) {
    assert(children.contains(child) == false,
        "Attempt to attach child: $child, which is already attached to $this.");

    children.add(child);

    child.interactable.activate();

    child.load();
  }

  /// Detaches the given `Router` from the tree.
  ///
  /// - parameter child: The child `Router` to detach.
  // public final func detachChild(_ child: Routing) {
  //     child.interactable.deactivate()

  //     children.removeElementByReference(child)
  // }

  void detachChild(Routing child) {
    child.interactable.deactivate();
    children.remove(child);
  }

  // MARK: - Internal
  // let deinitDisposable = CompositeDisposable()
  // final deinitDisposable = CompositeDisposable(); /// doesn't exist in `rxdart`
  final deinitDisposable = CompositeDisposable();

  // func internalDidLoad() {
  //     bindSubtreeActiveState()
  //     lifecycleSubject.onNext(.didLoad)
  // }
  void internalDidLoad() {
    _bindSubtreeActiveState();
    _lifecycleSubject.add(RouterLifecycle.didLoad);
  }

  // MARK: - Private
  // private let lifecycleSubject = PublishSubject<RouterLifecycle>()
  // private var didLoadFlag: Bool = false

  final _lifecycleSubject = PublishSubject<RouterLifecycle>(sync: true);

  bool _didLoadFlag = false;

  // private func bindSubtreeActiveState() {

  //     let disposable = interactable.isActiveStream
  //         // Do not retain self here to guarantee execution. Retaining self will cause the dispose bag
  //         // to never be disposed, thus self is never deallocated. Also cannot just store the disposable
  //         // and call dispose(), since we want to keep the subscription alive until deallocation, in
  //         // case the router is re-attached. Using weak does require the router to be retained until its
  //         // interactor is deactivated.
  //         .subscribe(onNext: { [weak self] (isActive: Bool) in
  //             // When interactor becomes active, we are attached to parent, otherwise we are detached.
  //             self?.setSubtreeActive(isActive)
  //         })
  //     _ = deinitDisposable.insert(disposable)
  // }

  void _bindSubtreeActiveState() {
    final disposable = interactable.isActiveStream
        //         // Do not retain self here to guarantee execution. Retaining self will cause the dispose bag
        //         // to never be disposed, thus self is never deallocated. Also cannot just store the disposable
        //         // and call dispose(), since we want to keep the subscription alive until deallocation, in
        //         // case the router is re-attached. Using weak does require the router to be retained until its
        //         // interactor is deactivated.
        .listen((bool isActive) {
      setSubtreeActive(isActive);
    });

    deinitDisposable.add(disposable);
  }

  // private func setSubtreeActive(_ active: Bool) {

  //     if active {
  //         iterateSubtree(self) { router in
  //             if !router.interactable.isActive {
  //                 router.interactable.activate()
  //             }
  //         }
  //     } else {
  //         iterateSubtree(self) { router in
  //             if router.interactable.isActive {
  //                 router.interactable.deactivate()
  //             }
  //         }
  //     }
  // }
  void setSubtreeActive(bool active) {
    if (active) {
      _iterateSubtree(this, (Router router) {
        if (!router.interactable.isActive) {
          router.interactable.activate();
        }
      });
    } else {
      _iterateSubtree(this, (Router router) {
        if (router.interactable.isActive) {
          router.interactable.deactivate();
        }
      });
    }
  }

  // private func iterateSubtree(_ root: Routing, closure: (_ node: Routing) -> ()) {
  //     closure(root)

  //     for child in root.children {
  //         iterateSubtree(child, closure: closure)
  //     }
  // }

  void _iterateSubtree(Routing root, Function(Router) closure) {
    closure(root);

    for (Routing child in root.children) {
      _iterateSubtree(child, closure);
    }
  }

  // private func detachAllChildren() {

  //     for child in children {
  //         detachChild(child)
  //     }
  // }

  void _detachAllChildren() {
    for (Routing child in children) {
      detachChild(child);
    }
  }

  // deinit {
  //     interactable.deactivate()

  //     if !children.isEmpty {
  //         detachAllChildren()
  //     }

  //     lifecycleSubject.onCompleted()

  //     deinitDisposable.dispose()

  //     LeakDetector.instance.expectDeallocate(object: interactable)
  // }

  dispose() {
    interactable.deactivate();

    if (children.isNotEmpty) {
      _detachAllChildren();
    }

    _lifecycleSubject.close();

    deinitDisposable.dispose();

    // LeakDetector.instance.expectDeallocate(object: interactable);
  }
}
