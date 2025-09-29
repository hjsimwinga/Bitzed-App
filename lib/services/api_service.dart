import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/rate.dart';
import '../models/config.dart';

class ApiService {
  static String _baseUrl = '';

  // Initialize the base URL from config
  static Future<void> initialize() async {
    try {
      final config = await AppConfig.load();
      _baseUrl = config.apiBaseUrl;
    } catch (e) {
      // Fallback to hardcoded URL if config fails
      _baseUrl = 'https://bitzed.xyz/api';
    }
  }

  static Future<ExchangeRate> getExchangeRate() async {
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExchangeRate.fromJson(data);
      } else {
        throw Exception('Failed to fetch exchange rate: $response.statusCode');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rate: $e');
    }
  }

  static Future<RateStats> getRateStats() async {
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rate/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RateStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch rate stats: $response.statusCode');
      }
    } catch (e) {
      throw Exception('Error fetching rate stats: $e');
    }
  }

  static Future<Map<String, double>> getMaximumAmounts() async {
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/maximums'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'maxBuyAmount': (data['maximums']['buyAmountZMW'] ?? 120).toDouble(),
          'maxSpendAmount': (data['maximums']['spendAmountZMW'] ?? 80).toDouble(),
        };
      } else {
        throw Exception('Failed to fetch maximum amounts: $response.statusCode');
      }
    } catch (e) {
      throw Exception('Error fetching maximum amounts: $e');
    }
  }

  static Future<SpendStatus> getSpendStatus() async {
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/spend-status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SpendStatus.fromJson(data);
      } else {
        throw Exception('Failed to fetch spend status: $response.statusCode');
      }
    } catch (e) {
      throw Exception('Error fetching spend status: $e');
    }
  }

  static Future<bool> validateLightningAddress(String lightningAddress) async {
    await initialize();
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
    await initialize();
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
    await initialize();
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
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check-spend-payment/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        throw Exception('Failed to check spend payment: $response.statusCode');
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
    await initialize();
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
    await initialize();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction-status/$shortId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Transaction.fromJson(data);
      } else {
        throw Exception('Failed to get transaction status: $response.statusCode');
      }
    } catch (e) {
      throw Exception('Error getting transaction status: $e');
    }
  }

  static Future<bool> testConnection() async {
    await initialize();
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
