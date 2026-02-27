import 'package:equatable/equatable.dart';

class MrzData extends Equatable {
  final String documentType;
  final String countryCode;
  final String surname;
  final String givenNames;
  final String documentNumber;
  final String nationalityCountryCode;
  final DateTime dateOfBirth;
  final String sex;
  final DateTime expirationDate;
  final String personalNumber;

  const MrzData({
    required this.documentType,
    required this.countryCode,
    required this.surname,
    required this.givenNames,
    required this.documentNumber,
    required this.nationalityCountryCode,
    required this.dateOfBirth,
    required this.sex,
    required this.expirationDate,
    required this.personalNumber,
  });

  factory MrzData.fromJson(Map<String, dynamic> json) {
    return MrzData(
      documentType: json['documentType'] as String,
      countryCode: json['countryCode'] as String,
      surname: json['surname'] as String,
      givenNames: json['givenNames'] as String,
      documentNumber: json['documentNumber'] as String,
      nationalityCountryCode: json['nationalityCountryCode'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      sex: json['sex'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      personalNumber: json['personalNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'countryCode': countryCode,
      'surname': surname,
      'givenNames': givenNames,
      'documentNumber': documentNumber,
      'nationalityCountryCode': nationalityCountryCode,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'sex': sex,
      'expirationDate': expirationDate.toIso8601String(),
      'personalNumber': personalNumber,
    };
  }

  @override
  List<Object?> get props => [
    documentType,
    countryCode,
    surname,
    givenNames,
    documentNumber,
    nationalityCountryCode,
    dateOfBirth,
    sex,
    expirationDate,
    personalNumber,
  ];
}
