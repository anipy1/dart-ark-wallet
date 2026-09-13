import 'package:ark_wallet/ark_wallet.dart' as ark;
import 'package:ark_wallet_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendPage extends StatefulWidget {
  final ark.ArkWallet client;
  const SendPage({super.key, required this.client});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  int _balance = 0;
  bool _sending = false;
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    init();
  }

  void init() async {
    final balance = await widget.client.balance();
    _balance = balance.total.toInt();

    setState(() {});
  }

  void _pasteAddress() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _addressController.text = clipboardData!.text!;
    }
  }

  String? _validateAddress(String? address) {
    if (!ark.Utils.isArk(address: address!)) {
      return 'Invalid ARK address';
    }

    return null;
  }

  String? _validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }

    final amountInt = int.tryParse(amount);
    if (amountInt == null) {
      return 'Invalid amount';
    }

    if (amountInt <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amountInt > _balance) {
      return 'Amount exceeds balance ($_balance sats)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                readOnly: true,
                validator: _validateAddress,
                decoration: InputDecoration(
                  labelText: 'ARK Address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _pasteAddress,
                  ),
                  helperText: 'Tap paste button to enter address',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                validator: _validateAmount,
                decoration: InputDecoration(
                  labelText: 'Amount (sats)',
                  helperText: 'Available: $_balance sats',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _sending = true);
                          try {
                            // Must be awaited: without it the try/catch cannot see a failure and
                            // we would navigate away as though the send had succeeded.
                            final txid = await widget.client.sendOffChain(
                              address: _addressController.text,
                              sats: int.parse(_amountController.text),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sent: $txid')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          } catch (e) {
                            debugPrint(e.toString());
                            if (!context.mounted) return;
                            setState(() => _sending = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Send failed: $e')),
                            );
                          }
                        },
                  child: Text(_sending ? 'Sending...' : 'Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
