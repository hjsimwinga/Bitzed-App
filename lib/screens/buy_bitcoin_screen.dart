import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/common_widgets.dart';

class BuyBitcoinScreen extends StatefulWidget {
  const BuyBitcoinScreen({super.key});

  @override
  State<BuyBitcoinScreen> createState() => _BuyBitcoinScreenState();
}

class _BuyBitcoinScreenState extends State<BuyBitcoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lightningController = TextEditingController();
  
  bool _isValidatingLightning = false;
  bool _isLightningValid = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Buy Bitcoin'),
        backgroundColor: Colors.green,
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
                  
                  const SizedBox(height: 20),
                  
                  // Lightning Address Card
                  _buildLightningCard(context),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  _buildSubmitButton(context, transactionProvider),
                  
                  const SizedBox(height: 20),
                  
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
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
                  Icons.shopping_cart,
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
                      'Buy Bitcoin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Convert ZMW to Bitcoin via Lightning',
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
              'Max: ${appState.maxBuyAmount.toStringAsFixed(0)} ZMW',
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
              Icon(Icons.attach_money, color: Colors.green[600], size: 24),
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
                color: Colors.green[600],
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
                borderSide: BorderSide(color: Colors.green[600]!, width: 2),
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
              if (amount > appState.maxBuyAmount) {
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
                    'You will receive:',
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
              Icon(Icons.phone, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Mobile Money Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '0762149024',
              prefixIcon: Icon(Icons.phone, color: Colors.blue[600]),
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
                return 'Please enter your mobile money number';
              }
              // Accept Zambian format: 07XXXXXXXX or 09XXXXXXXX (backend will add 260 prefix)
              if (!RegExp(r'^(09|07)[5-9][0-9]{7}$').hasMatch(value)) {
                return 'Please enter a valid Zambian mobile number (e.g., 0762149024, 0967234567)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLightningCard(BuildContext context) {
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
              Icon(Icons.flash_on, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Lightning Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lightningController,
            decoration: InputDecoration(
              hintText: 'yourname@domain.com',
              prefixIcon: Icon(Icons.flash_on, color: Colors.orange[600]),
              suffixIcon: _isValidatingLightning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _isLightningValid
                      ? Icon(Icons.check_circle, color: Colors.green[600])
                      : null,
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
                borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Lightning address';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                return 'Please enter a valid Lightning address';
              }
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                _validateLightningAddress(value);
              } else {
                setState(() {
                  _isLightningValid = false;
                });
              }
            },
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
          backgroundColor: Colors.green,
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
                'Buy Bitcoin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  void _validateLightningAddress(String address) async {
    setState(() {
      _isValidatingLightning = true;
    });

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final isValid = await appState.validateLightningAddress(address);
      
      setState(() {
        _isLightningValid = isValid;
        _isValidatingLightning = false;
      });
    } catch (e) {
      setState(() {
        _isLightningValid = false;
        _isValidatingLightning = false;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final phoneNumber = _phoneController.text;
    final lightningAddress = _lightningController.text;

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      await transactionProvider.createBuyTransaction(
        amount: amount,
        phoneNumber: phoneNumber,
        lightningAddress: lightningAddress,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created! Check your mobile money for payment instructions.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
}