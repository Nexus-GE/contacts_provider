import 'package:contacts_provider/contacts_provider.dart';
import 'package:contacts_provider/src/infrastructure/events.dart';
import 'package:contacts_provider/src/widgets/inherited_contacts.dart';
import 'package:flutter/material.dart';

class ContactsProvider extends StatelessWidget {
  final Widget child;
  late final Contacts _contacts;

  ContactsProvider({
    super.key,
    void Function()? onChange,
    void Function(ContactEvent contactEvent)? onCreate,
    void Function(ContactEvent contactEvent)? onUpdate,
    void Function(ContactEvent contactEvent)? onDelete,
    required this.child,
  }) : _contacts = Contacts(
          onChange: onChange,
          onCreate: onCreate,
          onUpdate: onUpdate,
          onDelete: onDelete,
        );

  @override
  Widget build(BuildContext context) {
    return InheritedContacts(
      contacts: _contacts,
      child: child,
    );
  }
}
