import 'package:contacts_provider/src/interfaces/i_events.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactEvent implements IContactEvent {
  @override
  List<Contact> effectedContacts;

  @override
  List<Contact> contactList;

  @override
  ContactEventType event;

  @override
  bool get isEffected => throw UnimplementedError();

  ContactEvent({
    required this.effectedContacts,
    required this.event,
    required this.contactList,
  });

  factory ContactEvent.withEventType(ContactEventType eventType) {
    return ContactEvent(
      effectedContacts: [],
      event: eventType,
      contactList: [],
    );
  }

  bool get hasHappened => effectedContacts.isNotEmpty;
}
