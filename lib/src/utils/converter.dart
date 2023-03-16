import 'dart:convert';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';

class ContactConverter {
  static List contactsToMap(List<Contact> contacts) {
    final result = [];

    for (Contact contact in contacts) {
      result.add(contact.toMap());
    }

    return result;
  }

  static String stringify(List<Contact> contacts) {
    return jsonEncode(contactsToMap(contacts));
  }

  static Map<String, Contact> fromStringAsMap(String contacts) {
    final Map<String, Contact> result = {};

    final dynamic contactsList = jsonDecode(contacts);

    for (Map contactMap in contactsList) {
      contactMap['avatar'] =
          Uint8List.fromList(contactMap['avatar'].cast<int>());
      final contact = Contact.fromMap(contactMap);
      result[contact.identifier.toString()] = contact;
    }

    return result;
  }
}
