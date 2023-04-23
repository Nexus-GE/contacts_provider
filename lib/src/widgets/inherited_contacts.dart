import 'package:contacts_provider/contacts_provider.dart';
import 'package:flutter/material.dart';

class InheritedContacts extends InheritedWidget {
  final Contacts contacts;

  const InheritedContacts({
    super.key,
    required this.contacts,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static InheritedContacts? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedContacts>();
  }

  static InheritedContacts of(BuildContext context) {
    final InheritedContacts? result = maybeOf(context);
    assert(result != null, 'No InheritedContacts found in context');
    return result!;
  }
}
