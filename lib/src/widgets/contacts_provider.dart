import 'package:contacts_provider/contacts_provider.dart';
import 'package:contacts_provider/src/infrastructure/events.dart';
import 'package:flutter/material.dart';

class ContactsProvider extends InheritedWidget {
  late final Contacts _contacts;

  ContactsProvider({
    super.key,
    void Function()? onChange,
    void Function(ContactEvent contactEvent)? onCreate,
    void Function(ContactEvent contactEvent)? onUpdate,
    void Function(ContactEvent contactEvent)? onDelete,
    required super.child,
  }) : _contacts = Contacts(
          onChange: onChange,
          onCreate: onCreate,
          onUpdate: onUpdate,
          onDelete: onDelete,
        );

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static ContactsProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContactsProvider>();
  }

  static ContactsProvider of(BuildContext context) {
    final ContactsProvider? result = maybeOf(context);
    assert(result != null, 'No ContactsProvider found in context');
    return result!;
  }
}
