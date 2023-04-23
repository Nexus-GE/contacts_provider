import 'package:contacts_provider/contacts_provider.dart';
import 'package:contacts_provider/src/widgets/inherited_contacts.dart';
import 'package:flutter/material.dart';

class ContactsProvider extends StatelessWidget {
  final Contacts Function(BuildContext) create;
  final Widget child;
  const ContactsProvider({
    super.key,
    required this.create,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Contacts contacts = create(context);
    return InheritedContacts(
      contacts: contacts,
      child: child,
    );
  }
}
