import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  Transaction? _currentTransaction;
  bool _isProcessing = false;
  String? _error;

  Transaction? get currentTransaction => _currentTransaction;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  Future<Transaction> createBuyTransaction({
    required double amount,
    required String phoneNumber,
    required String lightningAddress,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final request = BuyTransactionRequest(
        amount: amount,
        phoneNumber: phoneNumber,
        lightningAddress: lightningAddress,
      );

      _currentTransaction = await ApiService.createBuyTransaction(request);
      notifyListeners();
      return _currentTransaction!;
    } catch (e) {
      _setError('Failed to create buy transaction: $e');
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<Transaction> createSpendTransaction({
    required double amount,
    required String merchantPhone,
    required double sats,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final request = SpendTransactionRequest(
        amount: amount,
        merchantPhone: merchantPhone,
        sats: sats,
      );

      _currentTransaction = await ApiService.createSpendTransaction(request);
      notifyListeners();
      return _currentTransaction!;
    } catch (e) {
      _setError('Failed to create spend transaction: $e');
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<Transaction> checkSpendPayment(String transactionId) async {
    try {
      final transaction = await ApiService.checkSpendPayment(transactionId);
      _currentTransaction = transaction;
      notifyListeners();
      return transaction;
    } catch (e) {
      _setError('Failed to check spend payment: $e');
      rethrow;
    }
  }

  Future<Transaction> processRefund({
    required String transactionId,
    required String lightningAddress,
    required double amount,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      final transaction = await ApiService.processRefund(
        transactionId: transactionId,
        lightningAddress: lightningAddress,
        amount: amount,
      );
      
      _currentTransaction = transaction;
      notifyListeners();
      return transaction;
    } catch (e) {
      _setError('Failed to process refund: $e');
      rethrow;
    } finally {
      _setProcessing(false);
    }
  }

  Future<Transaction> getTransactionStatus(String shortId) async {
    try {
      final transaction = await ApiService.getTransactionStatus(shortId);
      _currentTransaction = transaction;
      notifyListeners();
      return transaction;
    } catch (e) {
      _setError('Failed to get transaction status: $e');
      rethrow;
    }
  }

  void clearTransaction() {
    _currentTransaction = null;
    _clearError();
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
