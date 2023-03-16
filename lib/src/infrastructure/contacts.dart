import 'dart:async';
import 'package:contacts_provider/src/infrastructure/contacts_delegate.dart';
import 'package:contacts_provider/src/infrastructure/contstants.dart';
import 'package:contacts_provider/src/infrastructure/events.dart';
import 'package:contacts_provider/src/interfaces/i_contacts.dart';
import 'package:contacts_provider/src/interfaces/i_events.dart';
import 'package:contacts_provider/src/utils/converter.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:listentocontacts/listentocontacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ContactsAction = Function(ContactEvent contactEvent);

class Contacts implements IContacts {
  SharedPreferences? _prefs;
  BehaviorSubject<ContactEvent> streamController = BehaviorSubject();

  Function(ContactEvent contactEvent)? _onDelete;

  Function(ContactEvent contactEvent)? _onUpdate;

  Function(ContactEvent contactEvent)? _onCreate;

  Function()? _onChange;

  set setOnDelete(ContactsAction? onDelete) => _onDelete = onDelete;

  set setOnUpdate(ContactsAction? onUpdate) => _onUpdate = onUpdate;

  set setOnChange(Function()? onChange) => _onChange = onChange;

  set setOnCreate(ContactsAction? onCreate) => _onCreate = onCreate;

  static Contacts? _instance;

  factory Contacts() {
    _instance ??= Contacts._();
    return _instance!;
  }

  Contacts._();

  @override
  void hasChanged() {
    throw UnimplementedError();
  }

  Future<void> init(
      //   Function(ContactEvent contactEvent)? onDelete,
      //   Function(ContactEvent contactEvent)? onUpdate,
      //   Function(ContactEvent contactEvent)? onCreate,
      //   Function()? onChange,
      ) async {
    //   _onChange = onChange;
    //   _onDelete = onDelete;
    //   _onUpdate = onUpdate;
    //   _onCreate = onCreate;
    _prefs = await SharedPreferences.getInstance();

    if (!localCopyExists) {
      await updateLocalCopy();
    }

    final initialEvent = ContactEvent(
      effectedContacts: [],
      event: ContactEventType.initial,
      contactList: localCopy.values.toList(),
    );

    streamController.add(initialEvent);

    Listentocontacts().onContactsChanged.listen((_) async {
      if (_onChange != null) _onChange!();
      if (localCopy == null) {
        return;
      }
      final latest = await readContacts();
      final contactsDelegate = ContactsDelegate(
        streamController,
        localCopy: localCopy,
        latest: latest,
      );
      contactsDelegate();
      updateLocalCopy();
    });

    streamController.stream.listen(
      (contactEvent) {
        switch (contactEvent.event) {
          case ContactEventType.created:
            if (_onCreate != null) {
              contactEvent.contactList =
                  _createContacts(contactEvent.effectedContacts);
              _onCreate!(contactEvent);
            }
            break;
          case ContactEventType.deleted:
            if (_onDelete != null) {
              contactEvent.contactList =
                  _deleteContacts(contactEvent.effectedContacts);
              _onDelete!(contactEvent);
            }
            break;
          case ContactEventType.updated:
            if (_onUpdate != null) {
              contactEvent.contactList =
                  _updateContacts(contactEvent.effectedContacts);
              _onUpdate!(contactEvent);
            }
            break;
        }
      },
    );
  }

  List<Contact> _deleteContacts(List<Contact> effectedContacts) {
    final local = localCopy;
    for (var contact in effectedContacts) {
      local.remove(contact.identifier.toString());
    }
    return local.values.toList();
  }

  List<Contact> _updateContacts(List<Contact> effectedContacts) {
    final local = localCopy;
    for (var contact in effectedContacts) {
      local.update(contact.identifier.toString(), (value) => contact);
    }
    return local.values.toList();
  }

  List<Contact> _createContacts(List<Contact> effectedContacts) {
    final local = localCopy;
    for (var contact in effectedContacts) {
      local[contact.identifier.toString()] = contact;
    }
    return local.values.toList();
  }

  FutureOr<void> updateLocalCopy() async {
    final contacts = await readContacts();
    final stringifiedContacts = ContactConverter.stringify(contacts);
    final result =
        await _prefs?.setString(sharedPrefsKeyName, stringifiedContacts);
  }

  bool get localCopyExists {
    final localCopyString = _prefs?.getString(sharedPrefsKeyName);

    return localCopyString != null && localCopyString.isNotEmpty;
  }

  Map<String, Contact> get localCopy {
    final localCopyString = _prefs?.getString(sharedPrefsKeyName);
    if (localCopyString == null) {
      return {};
    }
    return ContactConverter.fromStringAsMap(localCopyString);
  }

  void compare() {}

  @override
  Future<List<Contact>> readContacts() async {
    final allContacts = await ContactsService.getContacts();

    return allContacts;
  }

  @override
  List writeContacts() {
    throw UnimplementedError();
  }

  Future handlePermissions() async {
    var contactStatus = await Permission.contacts.status;
    if (contactStatus.isDenied) {
      await Permission.contacts.request().isGranted;
    }
    return Future.value(1);
  }

  @override
  void dispose() {
    if (streamController != null) {
      streamController.close();
    }
  }
}
