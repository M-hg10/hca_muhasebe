import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kullaniciAdiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  bool _loading = false;
  String? _resultMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    final url = Uri.parse("https://soft.hggrup.com/auth/register");

    final body = {
      "kullanici_adi": _kullaniciAdiController.text,
      "email": _emailController.text,
      "telefon": _telefonController.text,
      "adres_metni": _adresController.text,
      "sifre": _sifreController.text,
      "firma_id": 1,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        jsonDecode(response.body);
        setState(() {
          _resultMessage = "✅ Kayıt başarılı. Lütfen firmaya danışın.";
        });
      } else {
        // JSON mu HTML mi kontrol et
        if (response.headers['content-type']?.contains("application/json") ??
            false) {
          final data = jsonDecode(response.body);
          // ignore: unnecessary_brace_in_string_interps, avoid_print
          print('data : ${data}');
          setState(() {
            _resultMessage = "⚠️ Hata: ${data['message']}";
          });
        } else {
          setState(() {
            _resultMessage =
                "⚠️ Sunucu JSON yerine HTML döndürdü. Muhtemelen yanlış endpoint veya yönlendirme hatası.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _resultMessage = "Sunucuya bağlanırken hata: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.blue.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ), // Web uyumlu
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _kullaniciAdiController,
                        decoration: _inputDecoration(
                          "Kullanıcı Adı",
                          Icons.person,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Bu alan boş bırakılamaz" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration(
                          "E-Posta",
                          Icons.email_outlined,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "E-posta giriniz" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonController,
                        decoration: _inputDecoration(
                          "Telefon",
                          Icons.phone_android,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adresController,
                        decoration: _inputDecoration("Adres", Icons.home),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sifreController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          "Şifre",
                          Icons.lock_outline,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Şifre giriniz" : null,
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _register,
                                child: const Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      if (_resultMessage != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          _resultMessage!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _resultMessage!.startsWith("✅")
                                ? Colors.green
                                : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
