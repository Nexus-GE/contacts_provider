import 'dart:async';
import 'package:contacts_provider/src/infrastructure/contacts_delegate.dart';
import 'package:contacts_provider/src/infrastructure/constants.dart';
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

  void Function()? _onChange;

  void Function(ContactEvent contactEvent)? _onCreate;

  void Function(ContactEvent contactEvent)? _onUpdate;

  void Function(ContactEvent contactEvent)? _onDelete;

  set setOnDelete(ContactsAction? onDelete) => _onDelete = onDelete;

  set setOnUpdate(ContactsAction? onUpdate) => _onUpdate = onUpdate;

  set setOnChange(Function()? onChange) => _onChange = onChange;

  set setOnCreate(ContactsAction? onCreate) => _onCreate = onCreate;

  static Contacts? _instance;

  factory Contacts({
    void Function()? onChange,
    void Function(ContactEvent contactEvent)? onCreate,
    void Function(ContactEvent contactEvent)? onUpdate,
    void Function(ContactEvent contactEvent)? onDelete,
  }) {
    _instance ??= Contacts._(
      onChange,
      onCreate,
      onUpdate,
      onDelete,
    );

    return _instance!;
  }

  Contacts._(
    this._onChange,
    this._onCreate,
    this._onUpdate,
    this._onDelete,
  );

  @override
  void hasChanged() {
    throw UnimplementedError();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _initEventListener();
    _initContactListener();

    if (!localCopyExists) {
      _initialLoad();
    } else {
      await _checkContactChange();
    }
  }

  _initContactListener() {
    Listentocontacts().onContactsChanged.listen((_) async {
      if (_onChange != null) _onChange!();

      _checkContactChange();
    });
  }

  _initEventListener() {
    streamController.stream.listen(
      (contactEvent) {
        switch (contactEvent.event) {
          case ContactEventType.created:
            if (_onCreate != null) {
              contactEvent.contactList = _createContacts(contactEvent.effectedContacts);
              _onCreate!(contactEvent);
            }
            break;
          case ContactEventType.deleted:
            if (_onDelete != null) {
              contactEvent.contactList = _deleteContacts(contactEvent.effectedContacts);
              _onDelete!(contactEvent);
            }
            break;
          case ContactEventType.updated:
            if (_onUpdate != null) {
              contactEvent.contactList = _updateContacts(contactEvent.effectedContacts);
              _onUpdate!(contactEvent);
            }
            break;
          default:
            break;
        }
      },
    );
  }

  Future _checkContactChange() async {
    final latestContacts = await readContacts();

    final initialEvent = ContactEvent(
      effectedContacts: [],
      event: ContactEventType.initial,
      contactList: latestContacts,
    );

    ContactsDelegate(
      streamController,
      localCopy: localCopy,
      latest: latestContacts,
    )();

    updateLocalCopy(latestContacts: latestContacts);
    streamController.add(initialEvent);
  }

  Future _initialLoad() async {
    await updateLocalCopy();

    final initialEvent = ContactEvent(
      effectedContacts: [],
      event: ContactEventType.initial,
      contactList: localCopy.values.toList(),
    );

    streamController.add(initialEvent);
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

  FutureOr<void> updateLocalCopy({List<Contact>? latestContacts}) async {
    latestContacts ??= await readContacts();

    final stringifiedContacts = ContactConverter.stringify(latestContacts);

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

  void dispose() {
    streamController.close();
  }
}
