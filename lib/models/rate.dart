class ExchangeRate {
  final double rate;
  final DateTime timestamp;
  final String source;

  ExchangeRate({
    required this.rate,
    required this.timestamp,
    required this.source,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      rate: (json['rate'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      source: json['source'] ?? 'coingecko',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }
}

class RateStats {
  final double currentRate;
  final double minRate;
  final double maxRate;
  final double averageRate;
  final int totalRequests;

  RateStats({
    required this.currentRate,
    required this.minRate,
    required this.maxRate,
    required this.averageRate,
    required this.totalRequests,
  });

  factory RateStats.fromJson(Map<String, dynamic> json) {
    return RateStats(
      currentRate: (json['currentRate'] ?? 0).toDouble(),
      minRate: (json['minRate'] ?? 0).toDouble(),
      maxRate: (json['maxRate'] ?? 0).toDouble(),
      averageRate: (json['averageRate'] ?? 0).toDouble(),
      totalRequests: json['totalRequests'] ?? 0,
    );
  }
}
