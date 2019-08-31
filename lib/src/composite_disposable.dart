import 'dart:async' show StreamSubscription;

import 'package:rxdart/rxdart.dart' show Subject;

/// Collects [StreamSubscriptions] and [Subjects] to all be disposed later with a single
/// call to [CompositeDisposable.dispose()]
///
/// This is a crude approximation of
/// https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Disposables/CompositeDisposable.swift

class CompositeDisposable {
  final List<StreamSubscription> _disposables = [];
  final List<Subject> _subjects = [];

  /// Add a [StreamSubscription] to be disposed of later
  add(StreamSubscription disposable) => _disposables.add(disposable);

  /// Add a [Subject] to be disposed of later
  addSubject(Subject subject) => _subjects.add(subject);

  /// Dispose of every registered [StreamSubscription] and [Subject]
  dispose() {
    _disposables.forEach((disposable) {
      disposable.cancel();
    });

    _subjects.forEach((subject) {
      subject.close();
    });
  }
}
