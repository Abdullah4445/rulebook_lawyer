import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String? comment;
  String? rating;
  String? id;
  String? customerId;
  String? driverId;
  String? type;
  Timestamp? date;
  /// Lawyer's public reply to the client's review (Phase 2.7).
  String? lawyerReply;
  Timestamp? lawyerReplyAt;

  ReviewModel({
    this.comment,
    this.rating,
    this.id,
    this.date,
    this.customerId,
    this.driverId,
    this.lawyerReply,
    this.lawyerReplyAt,
  });

  ReviewModel.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    rating = json['rating'];
    id = json['id'];
    date = json['date'];
    customerId = json['customerId'];
    driverId = json['driverId'];
    type = json['type'];
    lawyerReply = json['lawyerReply'] as String?;
    lawyerReplyAt = json['lawyerReplyAt'] as Timestamp?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['comment'] = comment;
    data['rating'] = rating;
    data['id'] = id;
    data['date'] = date;
    data['customerId'] = customerId;
    data['driverId'] = driverId;
    data['type'] = type;
    if (lawyerReply != null) data['lawyerReply'] = lawyerReply;
    if (lawyerReplyAt != null) data['lawyerReplyAt'] = lawyerReplyAt;
    return data;
  }
}
