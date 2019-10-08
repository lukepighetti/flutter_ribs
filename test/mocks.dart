/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBsTests/Mocks.swift

import 'package:flutter/widgets.dart';
import 'package:ribs/ribs.dart';
import 'package:rxdart/rxdart.dart';

class ViewControllableMock extends StatelessWidget with ViewControllable {
  static String get label => "ViewControllableMock";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label),
    );
  }
}

class InteractorMock extends Interactable {
  @override
  bool get isActive => _active.value;

  @override
  Observable<bool> get isActiveStream => _active.stream;

  final _active = BehaviorSubject<bool>.seeded(false);

  @override
  void activate() {
    _active.add(true);
  }

  @override
  void deactivate() {
    _active.add(false);
  }
}

class InteractableMock extends Interactable {
  /// Variables
  var _isActive = false;
  bool get isActive => _isActive;
  set isActive(bool setter) {
    _isActive = setter;
    isActiveSetCallCount++;
  }

  var isActiveSetCallCount = 0;

  var _isActiveStreamSubject = PublishSubject<bool>();
  PublishSubject<bool> get isActiveStreamSubject => _isActiveStreamSubject;
  set isActiveStreamSubject(PublishSubject<bool> setter) {
    _isActiveStreamSubject = setter;
    isActiveStreamSubjectSetCallCount++;
  }

  var isActiveStreamSubjectSetCallCount = 0;

  Observable<bool> get isActiveStream => _isActiveStreamSubject;

  /// Function handlers
  var activateHandler = () => null;
  var activateCallCount = 0;
  var deactivateHandler = () => null;
  var deactivateCallCount = 0;

  @override
  activate() {
    activateCallCount++;

    if (activateHandler != null) {
      activateHandler();
    }
  }

  @override
  deactivate() {
    deactivateCallCount++;

    if (deactivateHandler != null) {
      deactivateHandler();
    }
  }
}
