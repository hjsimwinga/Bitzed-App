class Transaction {
  final String id;
  final String shortId;
  final double amount;
  final String phoneNumber;
  final String lightningAddress;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentHash;
  final String? invoice;
  final double? sats;
  final String? errorMessage;

  Transaction({
    required this.id,
    required this.shortId,
    required this.amount,
    required this.phoneNumber,
    required this.lightningAddress,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentHash,
    this.invoice,
    this.sats,
    this.errorMessage,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Handle different response formats from backend
    String? invoice;
    if (json['invoice'] is String) {
      invoice = json['invoice'];
    } else if (json['invoice'] is Map<String, dynamic>) {
      invoice = json['invoice']['paymentRequest'];
    }
    
    return Transaction(
      id: json['id'] ?? json['transactionId'] ?? '',
      shortId: json['shortId'] ?? json['transactionId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      phoneNumber: json['phoneNumber'] ?? json['merchantPhone'] ?? '',
      lightningAddress: json['lightningAddress'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      paymentHash: json['paymentHash'],
      invoice: invoice,
      sats: json['sats']?.toDouble(),
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortId': shortId,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'lightningAddress': lightningAddress,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paymentHash': paymentHash,
      'invoice': invoice,
      'sats': sats,
      'errorMessage': errorMessage,
    };
  }
}

class BuyTransactionRequest {
  final double amount;
  final String phoneNumber;
  final String lightningAddress;

  BuyTransactionRequest({
    required this.amount,
    required this.phoneNumber,
    required this.lightningAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'phoneNumber': phoneNumber,
      'lightningAddress': lightningAddress,
    };
  }
}

class SpendTransactionRequest {
  final double amount;
  final String merchantPhone;
  final double sats;

  SpendTransactionRequest({
    required this.amount,
    required this.merchantPhone,
    required this.sats,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'merchantPhone': merchantPhone,
      'sats': sats,
    };
  }
}
