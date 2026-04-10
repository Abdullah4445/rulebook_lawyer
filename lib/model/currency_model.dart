import 'package:cloud_firestore/cloud_firestore.dart';

class CurrencyModel {
  Timestamp? createdAt;
  String? symbol;
  String? code;
  bool? enable;
  bool? symbolAtRight;
  String? name;
  int? decimalDigits;
  String? id;
  Timestamp? updatedAt;

  CurrencyModel({this.createdAt, this.symbol, this.code, this.enable, this.symbolAtRight, this.name, this.decimalDigits, this.id, this.updatedAt});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    // For createdAt, check if it's a String or Timestamp
    if (json['createdAt'] is String) {
      createdAt = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    } else if (json['createdAt'] is Timestamp) {
      createdAt = json['createdAt'];
    } else {
      createdAt = null;
    }

    symbol = json['symbol'];
    code = json['code'];
    enable = json['enable'];
    symbolAtRight = json['symbolAtRight'];
    name = json['name'];
    decimalDigits = json['decimalDigits'] != null ? int.parse(json['decimalDigits'].toString()) : 2;
    id = json['id'];

    // For updatedAt, check if it's a String or Timestamp
    if (json['updatedAt'] is String) {
      updatedAt = Timestamp.fromDate(DateTime.parse(json['updatedAt']));
    } else if (json['updatedAt'] is Timestamp) {
      updatedAt = json['updatedAt'];
    } else {
      updatedAt = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt != null ? createdAt!.toDate().toIso8601String() : null;
    data['symbol'] = symbol;
    data['code'] = code;
    data['enable'] = enable;
    data['symbolAtRight'] = symbolAtRight;
    data['name'] = name;
    data['decimalDigits'] = decimalDigits;
    data['id'] = id;
    data['updatedAt'] = updatedAt != null ? updatedAt!.toDate().toIso8601String() : null;
    return data;
  }
}
