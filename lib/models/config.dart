class AppConfig {
  final String apiBaseUrl;
  final double maxBuyAmount;
  final double maxSpendAmount;
  final bool spendEnabled;
  final List<String> supportedNetworks;

  AppConfig({
    required this.apiBaseUrl,
    required this.maxBuyAmount,
    required this.maxSpendAmount,
    required this.spendEnabled,
    required this.supportedNetworks,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiBaseUrl: json['apiBaseUrl'] ?? 'http://localhost:3000/api',
      maxBuyAmount: (json['maxBuyAmount'] ?? 120).toDouble(),
      maxSpendAmount: (json['maxSpendAmount'] ?? 80).toDouble(),
      spendEnabled: json['spendEnabled'] ?? true,
      supportedNetworks: List<String>.from(json['supportedNetworks'] ?? ['airtel', 'mtn', 'zamtel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiBaseUrl': apiBaseUrl,
      'maxBuyAmount': maxBuyAmount,
      'maxSpendAmount': maxSpendAmount,
      'spendEnabled': spendEnabled,
      'supportedNetworks': supportedNetworks,
    };
  }
}

class SpendStatus {
  final bool outOfStock;
  final String? message;
  final DateTime lastChecked;

  SpendStatus({
    required this.outOfStock,
    this.message,
    required this.lastChecked,
  });

  factory SpendStatus.fromJson(Map<String, dynamic> json) {
    return SpendStatus(
      outOfStock: json['outOfStock'] ?? false,
      message: json['message'],
      lastChecked: DateTime.parse(json['lastChecked'] ?? DateTime.now().toIso8601String()),
    );
  }
}
