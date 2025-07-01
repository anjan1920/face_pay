import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({Key? key}) : super(key: key);

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _userId;
  String? _userName;
  String? _statusMessage;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['userid'] != null) _userId = args['userid'].toString();
      if (args['username'] != null) _userName = args['username'].toString();
    }
  }

  Future<void> _addMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (_userId == null || _userName == null || amount == null) {
      setState(() {
        _statusMessage = 'Please enter a valid amount.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    bool success = await ApiService.updateWallet(
      userId: _userId!,
      userName: _userName!,
      amount: amount,
    );
    setState(() {
      _isLoading = false;
      _statusMessage =
          success ? 'Money added successfully!' : 'Failed to add money.';
    });
    if (success) {
      final updatedUser = await ApiService.getUserDetailsById(_userId!);
      await Future.delayed(const Duration(seconds: 1));
      if (updatedUser != null) {
        Navigator.pop(context, updatedUser);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF3FDFEFF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A6BA2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 16),
            child: Column(
              children: const [
                Icon(Icons.attach_money, size: 120, color: Colors.white),
                SizedBox(height: 16),
                Text('Enter amount',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 24),
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (_isLoading) const CircularProgressIndicator(),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_statusMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            width: 220,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6BA2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: _isLoading ? null : _addMoney,
              child: const Text('Add',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
