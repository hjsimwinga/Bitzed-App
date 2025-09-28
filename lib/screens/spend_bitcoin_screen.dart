import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/app_state_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/transaction.dart';
import 'lightning_invoice_screen.dart';

class SpendBitcoinScreen extends StatefulWidget {
  const SpendBitcoinScreen({super.key});

  @override
  State<SpendBitcoinScreen> createState() => _SpendBitcoinScreenState();
}

class _SpendBitcoinScreenState extends State<SpendBitcoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _showQRCode = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Spend Bitcoin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<AppStateProvider, TransactionProvider>(
        builder: (context, appState, transactionProvider, child) {
          if (appState.isLoading) {
            return const AppLoadingWidget(message: 'Loading...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(context, appState),
                  
                  const SizedBox(height: 24),
                  
                  // Amount Input Card
                  _buildAmountCard(context, appState),
                  
                  const SizedBox(height: 20),
                  
                  // Phone Number Card
                  _buildPhoneCard(context),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  _buildSubmitButton(context, transactionProvider),
                  
                  const SizedBox(height: 20),
                  
                  // QR Code Section
                  if (_showQRCode && transactionProvider.currentTransaction != null)
                    _buildQRCodeSection(context, transactionProvider.currentTransaction!),
                  
                  // Error Display
                  if (transactionProvider.error != null)
                    _buildErrorCard(transactionProvider.error!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.payment,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spend Bitcoin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Convert Bitcoin to ZMW via Lightning',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Max: ${appState.maxSpendAmount.toStringAsFixed(0)} ZMW',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Amount in ZMW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: 'ZMW ',
              prefixStyle: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount > appState.maxSpendAmount) {
                return 'Amount exceeds maximum limit';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
          if (_amountController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'You will pay:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₿ ${appState.convertZMWToSats(double.tryParse(_amountController.text) ?? 0).toStringAsFixed(0)} sats',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green[600], size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Merchant Mobile Money Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                // Static "260" prefix
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '260',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Phone icon
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(Icons.phone, color: Colors.green[600]),
                ),
                // Input field for Zambian number
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '762149024',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter merchant mobile money number';
                      }
                      // Accept Zambian format: 07XXXXXXXX or 09XXXXXXXX (backend will add 260 prefix)
                      // Also accept 7XXXXXXXX or 9XXXXXXXX (without leading 0)
                      if (!RegExp(r'^(09|07)[5-9][0-9]{7}$').hasMatch(value) && 
                          !RegExp(r'^(9|7)[5-9][0-9]{7}$').hasMatch(value)) {
                        return 'Please enter a valid Zambian mobile number (e.g., 0762149024, 0967234567)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, TransactionProvider transactionProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: transactionProvider.isProcessing ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: transactionProvider.isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Create Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildQRCodeSection(BuildContext context, Transaction transaction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Lightning Invoice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: transaction.invoice ?? '',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Transaction Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${transaction.amount.toStringAsFixed(2)} ZMW'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sats:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${transaction.sats?.toStringAsFixed(0) ?? 'N/A'} sats'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      transaction.status,
                      style: TextStyle(
                        color: transaction.status == 'pending' ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: transaction.invoice ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invoice copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Invoice'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _checkPaymentStatus(transaction.id);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final phoneInput = _phoneController.text.trim();
    
    // Format phone number correctly for backend (must be exactly 12 digits: 260 + 9 digits)
    String phoneNumber;
    if (phoneInput.startsWith('0')) {
      // Remove leading 0 and add 260 prefix: 0762149024 -> 260762149024
      phoneNumber = '260${phoneInput.substring(1)}';
    } else {
      // No leading 0, just add 260 prefix: 762149024 -> 260762149024
      phoneNumber = '260$phoneInput';
    }
    
    final sats = Provider.of<AppStateProvider>(context, listen: false)
        .convertZMWToSats(amount);

    // Debug logging
    print('DEBUG: Original phone input: "$phoneInput"');
    print('DEBUG: Final phone number: "$phoneNumber"');
    print('DEBUG: Phone number length: ${phoneNumber.length}');
    print('DEBUG: Amount: $amount, Sats: $sats');

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      final transaction = await transactionProvider.createSpendTransaction(
        amount: amount,
        merchantPhone: phoneNumber,
        sats: sats,
      );

      if (mounted) {
        // Navigate to Lightning Invoice screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LightningInvoiceScreen(transaction: transaction),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkPaymentStatus(String transactionId) async {
    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.checkSpendPayment(transactionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment status updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}