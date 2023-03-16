import 'package:contacts_service/contacts_service.dart';

abstract class IContacts {
  Future<List<Contact>> readContacts();
  List writeContacts();
  void hasChanged();
}
