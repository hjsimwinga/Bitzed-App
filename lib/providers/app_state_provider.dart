import 'package:flutter/foundation.dart';
import '../models/rate.dart';
import '../models/config.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  ExchangeRate? _currentRate;
  Map<String, double> _maximumAmounts = {'maxBuyAmount': 120, 'maxSpendAmount': 80};
  SpendStatus? _spendStatus;
  bool _isLoading = false;
  String? _error;

  ExchangeRate? get currentRate => _currentRate;
  Map<String, double> get maximumAmounts => _maximumAmounts;
  SpendStatus? get spendStatus => _spendStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get maxBuyAmount => _maximumAmounts['maxBuyAmount'] ?? 120;
  double get maxSpendAmount => _maximumAmounts['maxSpendAmount'] ?? 80;

  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      await Future.wait([
        fetchExchangeRate(),
        fetchMaximumAmounts(),
        fetchSpendStatus(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchExchangeRate() async {
    try {
      _currentRate = await ApiService.getExchangeRate();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch exchange rate: $e');
    }
  }

  Future<void> fetchMaximumAmounts() async {
    try {
      _maximumAmounts = await ApiService.getMaximumAmounts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch maximum amounts: $e');
    }
  }

  Future<void> fetchSpendStatus() async {
    try {
      _spendStatus = await ApiService.getSpendStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch spend status: $e');
    }
  }

  double convertZMWToSats(double zmwAmount) {
    if (_currentRate == null) return 0;
    // Rate is ZMW per Bitcoin, so we need to convert to sats per ZMW
    // 1 Bitcoin = 100,000,000 sats
    // So: sats = zmwAmount * (100,000,000 / rate)
    return zmwAmount * (100000000 / _currentRate!.rate);
  }

  double convertSatsToZMW(double sats) {
    if (_currentRate == null) return 0;
    // Rate is ZMW per Bitcoin, so we need to convert from sats to ZMW
    // So: zmw = sats * (rate / 100,000,000)
    return sats * (_currentRate!.rate / 100000000);
  }

  Future<bool> validateLightningAddress(String address) async {
    try {
      // Basic validation - check if it's a valid email format
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      return emailRegex.hasMatch(address);
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
