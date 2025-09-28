// Test script to verify phone number formatting logic
void main() {
  // Test cases for phone number formatting
  List<String> testCases = [
    '0762149024',  // With leading 0 (10 digits)
    '762149024',   // Without leading 0 (9 digits)
    '0967234567',  // With leading 0, different prefix (10 digits)
    '967234567',   // Without leading 0, different prefix (9 digits)
  ];

  print('=== Phone Number Formatting Tests ===\n');

  for (String phoneInput in testCases) {
    String phoneNumber;
    if (phoneInput.startsWith('0')) {
      // Remove leading 0 and add 260 prefix: 0762149024 -> 260762149024
      phoneNumber = '260${phoneInput.substring(1)}';
    } else {
      // No leading 0, just add 260 prefix: 762149024 -> 260762149024
      phoneNumber = '260$phoneInput';
    }

    print('Input: "$phoneInput" (${phoneInput.length} digits)');
    print('Output: "$phoneNumber" (${phoneNumber.length} digits)');
    print('Valid: ${phoneNumber.length == 12 ? "✅" : "❌"}');
    print('Regex test: ${RegExp(r'^260[0-9]{9}$').hasMatch(phoneNumber) ? "✅" : "❌"}');
    print('---');
  }
}
