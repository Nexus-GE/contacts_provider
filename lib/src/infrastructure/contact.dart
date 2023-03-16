import 'package:flutter/material.dart';

class MyContact {
  final String firstName;
  final String? lastName;
  final PhoneVO phoneNumber;

  MyContact({
    required this.firstName,
    this.lastName,
    required this.phoneNumber,
  });
}

/// Phone value object, for maintaining phone number granularily
@immutable
class PhoneVO {
  final String codeSymbol;
  final int countryCode;
  final int providerCode;
  final String number;
  const PhoneVO({
    this.codeSymbol = "+",
    this.countryCode = 995,
    this.providerCode = 598,
    required this.number,
  });

  @override
  String toString() {
    return "$codeSymbol$countryCode-$providerCode-$number";
  }
}
