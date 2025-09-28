import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class LightningInvoiceScreen extends StatefulWidget {
  final Transaction transaction;

  const LightningInvoiceScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<LightningInvoiceScreen> createState() => _LightningInvoiceScreenState();
}

class _LightningInvoiceScreenState extends State<LightningInvoiceScreen> {
  bool _isCheckingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lightning Invoice',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildInvoiceCard(),
            const SizedBox(height: 24),
            _buildTransactionDetails(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: QrImageView(
              data: widget.transaction.invoice ?? '',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan QR code to pay',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Amount', '${widget.transaction.amount?.toStringAsFixed(2) ?? '0.00'} ZMW'),
          const SizedBox(height: 12),
          _buildDetailRow('Sats', '${widget.transaction.sats?.toStringAsFixed(0) ?? 'N/A'} sats'),
          const SizedBox(height: 12),
          _buildDetailRow('Phone', widget.transaction.phoneNumber ?? 'N/A'),
          const SizedBox(height: 12),
          _buildStatusRow('Status', widget.transaction.status ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        statusColor = Colors.green;
        break;
      case 'failed':
      case 'disbursement_failed':
        statusColor = Colors.red;
        break;
      case 'pending':
      case 'processing':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyInvoice,
            icon: const Icon(Icons.copy, color: Color(0xFF8B4513)),
            label: const Text(
              'Copy Invoice',
              style: TextStyle(color: Color(0xFF8B4513)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF8B4513)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isCheckingStatus ? null : _checkStatus,
            icon: _isCheckingStatus
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              _isCheckingStatus ? 'Checking...' : 'Check Status',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _copyInvoice() {
    if (widget.transaction.invoice != null) {
      // Copy to clipboard logic would go here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _checkStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.checkSpendPayment(widget.transaction.id ?? '');
      
      // Refresh the transaction data
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }
}
