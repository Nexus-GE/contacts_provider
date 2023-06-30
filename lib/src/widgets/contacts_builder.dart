import 'package:contacts_provider/contacts_provider.dart';
import 'package:flutter/material.dart';

typedef ContactsBuilderBuild = Widget Function(BuildContext, List<Contact>);

class ContactsBuilder extends StatefulWidget {
  final Function()? onChange;
  final ContactsAction? onUpdate;
  final ContactsAction? onCreate;
  final ContactsAction? onDelete;
  final ContactsBuilderBuild builder;

  const ContactsBuilder({
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
  final _contacts = Contacts();

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
    return StreamBuilder<List<Contact>>(
      stream: _contacts.contactListStream,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot.data ?? []);
      },
    );
  }

  @override
  void dispose() {
    _contacts.dispose();
    super.dispose();
  }
}
