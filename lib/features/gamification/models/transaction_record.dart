import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionRecord {
  final String id;
  final String userId;
  final int amount;
  final String reason;
  final DateTime timestamp;

  const TransactionRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.timestamp,
  });

  factory TransactionRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      reason: data['reason'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
