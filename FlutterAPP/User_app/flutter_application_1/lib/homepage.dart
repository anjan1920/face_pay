import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/server_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userInfo = {};
  var amount = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userInfo.isEmpty) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        userInfo = Map<String, dynamic>.from(args);
      }
    }
  }

  void _updateUserInfo(Map<String, dynamic> updatedUser) {
    setState(() {
      userInfo = updatedUser;
    });
  }

  Future<void> wallet_check() async {
    final url = Uri.parse('${ServerConfig.baseUrl}/wallet_check');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userInfo['userid'],
        }),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['amount'] != null) {
          setState(() {
            amount = decoded['amount'];
          });
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username = userInfo['username'] ?? 'User Name';
    final String email = userInfo['email'] ?? 'user@email.com';
    final String userid = userInfo['userid']?.toString() ?? '';
    final double balance =
        (userInfo['balance'] is num) ? userInfo['balance'].toDouble() : 0.0;

    amount = (amount==0.0)?balance:amount;
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      await wallet_check();
    });

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
            padding: const EdgeInsets.only(top: 60, bottom: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu,
                          color: Colors.cyanAccent, size: 32),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.cyanAccent, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 64, color: Color(0xFF1A6BA2)),
                ),
                const SizedBox(height: 12),
                Text(username.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.cyanAccent)),
                if (userid.isNotEmpty)
                  Text('User ID: $userid',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.cyanAccent)),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Balance',
                          style: TextStyle(
                              fontSize: 20, color: Color(0xFF1A6BA2))),
                      const SizedBox(height: 4),
                      Text('₹ $amount',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A6BA2))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/biometric',
                        arguments: {
                          'userid': userid,
                          'username': username,
                        },
                      );
                    },
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.face_retouching_natural,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Register\nBiometric',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final updatedUser = await Navigator.pushNamed(
                        context,
                        '/addmoney',
                        arguments: {
                          'userid': userid,
                          'username': username,
                        },
                      );
                      if (updatedUser is Map<String, dynamic>) {
                        _updateUserInfo(updatedUser);
                      }
                    },
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.currency_rupee,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add Money\nto Wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
