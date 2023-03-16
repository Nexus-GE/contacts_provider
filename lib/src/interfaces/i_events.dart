import 'package:contacts_service/contacts_service.dart';

enum ContactEventType {
  initial,
  deleted,
  updated,
  created,
}

abstract class IContactEvent {
  late ContactEventType event;
  late List<Contact> effectedContacts = [];
  late List<Contact> contactList = [];
  bool get isEffected => effectedContacts.isNotEmpty;
}
