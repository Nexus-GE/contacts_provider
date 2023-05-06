import 'dart:async';

import 'package:contacts_provider/src/infrastructure/events.dart';
import 'package:contacts_provider/src/interfaces/i_events.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:rxdart/rxdart.dart';

abstract class ContactsStreamable {
  BehaviorSubject<ContactEvent> get eventStreamController;
  BehaviorSubject<List<Contact>> get contactsListStreamController;
}

mixin BaseEvents {
  final _delete = ContactEvent.withEventType(ContactEventType.deleted);
  final _update = ContactEvent.withEventType(ContactEventType.updated);
  final _create = ContactEvent.withEventType(ContactEventType.created);
}

class ContactsDelegate extends ContactsStreamable with BaseEvents {
  final Map<String, Contact> localCopy;
  final List<Contact> latest;

  final BehaviorSubject<ContactEvent> _eventStreamController;
  final BehaviorSubject<List<Contact>> _contactsListStreamController;

  ContactsDelegate(
    this._eventStreamController,
    this._contactsListStreamController, {
    required this.localCopy,
    required this.latest,
  });

  @override
  BehaviorSubject<ContactEvent> get eventStreamController => _eventStreamController;

  @override
  BehaviorSubject<List<Contact>> get contactsListStreamController => _contactsListStreamController;

  call() {
    _contactsListStreamController.add(latest);
    for (var latestContact in latest) {
      if (hasCreated(latestContact, localCopy)) {
        _create.effectedContacts.add(latestContact);
        continue;
      }

      final localContact = localCopy[latestContact.identifier];
      if (hasUpdated(latestContact, localContact!)) {
        _update.effectedContacts.add(latestContact);
        localCopy.remove(latestContact.identifier);
        continue;
      }

      localCopy.remove(latestContact.identifier);
    }
    if (hasDeleted(localCopy)) {
      _delete.effectedContacts.addAll(localCopy.values);
    }

    if (_update.hasHappened) _eventStreamController.add(_update);
    if (_delete.hasHappened) _eventStreamController.add(_delete);
    if (_create.hasHappened) _eventStreamController.add(_create);
  }

  bool hasCreated(Contact latestContact, Map<String, Contact> localCopy) {
    return !localCopy.containsKey(latestContact.identifier);
  }

  bool hasUpdated(Contact latestContact, Contact localContact) {
    return latestContact.hashCode != localContact.hashCode;
  }

  bool hasDeleted(Map<String, Contact> localCopyRemainder) {
    return localCopyRemainder.isNotEmpty;
  }
}
