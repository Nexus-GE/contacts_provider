import 'package:contacts_provider/src/infrastructure/contacts.dart';
import 'package:contacts_provider/src/infrastructure/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';

typedef ContactsBuilderBuild = Widget Function(BuildContext, ContactEvent);

class ContactsBuilder extends StatefulWidget {
  Function()? onChange;
  ContactsAction? onUpdate;
  ContactsAction? onCreate;
  ContactsAction? onDelete;
  ContactsBuilderBuild builder;

  ContactsBuilder({
    super.key,
    this.onChange,
    this.onCreate,
    this.onDelete,
    this.onUpdate,
    required this.builder,
  });

  @override
  State<ContactsBuilder> createState() => _ContactsBuilderState();
}

class _ContactsBuilderState extends State<ContactsBuilder> {
  Contacts _contacts = Contacts();

  @override
  void initState() {
    _contacts.setOnChange = widget.onChange;
    _contacts.setOnCreate = widget.onCreate;
    _contacts.setOnUpdate = widget.onUpdate;
    _contacts.setOnDelete = widget.onDelete;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ContactEvent>(
      stream: _contacts.streamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const CircularProgressIndicator();
        }
        return widget.builder(context, snapshot.data!);
      },
    );
  }

  @override
  void dispose() {
    _contacts.dispose();
    super.dispose();
  }
}
