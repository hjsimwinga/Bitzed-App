import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/rate.dart';
import '../models/config.dart';

class ApiService {
  // Try multiple URLs for different environments
  static const List<String> _baseUrls = [
    'http://10.0.2.2:30001/api', // Android emulator host IP
    'http://127.0.0.1:30001/api', // Localhost for other platforms
    'http://localhost:30001/api', // Fallback localhost
  ];
  
  static String get _baseUrl => 'http://10.0.2.2:30001/api'; // Android emulator host IP
  
  static Future<ExchangeRate> getExchangeRate() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExchangeRate.fromJson(data);
      } else {
        throw Exception('Failed to fetch exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rate: $e');
    }
  }

  static Future<RateStats> getRateStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rate/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RateStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch rate stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rate stats: $e');
    }
  }

  static Future<Map<String, double>> getMaximumAmounts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/maximums'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'maxBuyAmount': (data['maxBuyAmount'] ?? 120).toDouble(),
          'maxSpendAmount': (data['maxSpendAmount'] ?? 80).toDouble(),
        };
      } else {
        throw Exception('Failed to fetch maximum amounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching maximum amounts: $e');
    }
  }

  static Future<SpendStatus> getSpendStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/spend-status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SpendStatus.fromJson(data);
      } else {
        throw Exception('Failed to fetch spend status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching spend status: $e');
    }
  }

  static Future<bool> validateLightningAddress(String lightningAddress) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/validate-lightning-address'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'lightningAddress': lightningAddress}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<Transaction> createBuyTransaction(BuyTransactionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/confirm-buy-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create buy transaction');
      }
    } catch (e) {
      throw Exception('Error creating buy transaction: $e');
    }
  }

  static Future<Transaction> createSpendTransaction(SpendTransactionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-spend-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create spend transaction');
      }
    } catch (e) {
      throw Exception('Error creating spend transaction: $e');
    }
  }

  static Future<Transaction> checkSpendPayment(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check-spend-payment/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        throw Exception('Failed to check spend payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking spend payment: $e');
    }
  }

  static Future<Transaction> processRefund({
    required String transactionId,
    required String lightningAddress,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/process-refund'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transactionId': transactionId,
          'lightningAddress': lightningAddress,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to process refund');
      }
    } catch (e) {
      throw Exception('Error processing refund: $e');
    }
  }

  static Future<Transaction> getTransactionStatus(String shortId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction-status/$shortId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        throw Exception('Failed to get transaction status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transaction status: $e');
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
