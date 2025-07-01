// import 'package:flutter/material.dart';
// import 'services/api_service.dart';
// import 'dart:convert';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscureText = true;
//   bool _isLoading = false;
//   String? _errorMessage;

//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final data =
//           await ApiService.login(emailController.text, passwordController.text);
//       if (data != null) {
//         Navigator.pushReplacementNamed(
//           context,
//           '/home',
//           arguments: {
//             'email': data['user_email'],
//             'username': data['user_name'],
//             'userid': data['user_id'],
//             'balance': data['wallet_balance'],
//           },
//         );
//       } else {
//         setState(() {
//           _errorMessage = 'Login failed. Please try again.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xF3FDFEFF),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 80),
//             const Text('Welcome!',
//                 style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     shadows: [Shadow(blurRadius: 10, color: Colors.black26)])),
//             const SizedBox(height: 20),
//             Container(
//               decoration: BoxDecoration(
//                 color: Color(0xFF1A6BA2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Image.asset('assets/logo.png',
//                   height: 80), // Replace with your logo asset
//             ),
//             const SizedBox(height: 40),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email ID',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: passwordController,
//                     obscureText: _obscureText,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: const OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscureText
//                             ? Icons.visibility
//                             : Icons.visibility_off),
//                         onPressed: () {
//                           setState(() {
//                             _obscureText = !_obscureText;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Text(_errorMessage!,
//                           style: const TextStyle(color: Colors.red)),
//                     ),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF1A6BA2),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24)),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       onPressed: _isLoading ? null : _login,
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Sign in',
//                               style:
//                                   TextStyle(fontSize: 20, color: Colors.white)),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () {},
//                     child: const Text('Want to change password?'),
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     children: const [
//                       Expanded(child: Divider()),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Text('or sign in with'),
//                       ),
//                       Expanded(child: Divider()),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Image.asset(
//                             'assets/google.png'), // Replace with your Google icon asset
//                         iconSize: 36,
//                         onPressed: () {},
//                       ),
//                       const SizedBox(width: 16),
//                       IconButton(
//                         icon: Image.asset(
//                             'assets/facebook.png'), // Replace with your Facebook icon asset
//                         iconSize: 36,
//                         onPressed: () {},
//                       ),
//                       const SizedBox(width: 16),
//                       IconButton(
//                         icon: Image.asset(
//                             'assets/x.png'), // Replace with your X (Twitter) icon asset
//                         iconSize: 36,
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



















import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data =
          await ApiService.login(emailController.text, passwordController.text);
      if (data != null) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'email': data['user_email'],
            'username': data['user_name'],
            'userid': data['user_id'],
            'balance': data['wallet_balance'],
          },
        );
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF3FDFEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text('Welcome!',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 86, 128),
                          shadows: [Shadow(blurRadius: 5, color: Colors.black26)])),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6BA2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    //padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'lib/assets/logo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Color(0xFF1A6BA2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email ID',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6BA2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign in',
                                  style:
                                      TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Want to change password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}