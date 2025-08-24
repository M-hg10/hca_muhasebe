import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/mesaj/alicilist.dart';
import 'package:hcastick/onmuhasebe/kullanici/mesaj/mesajdashboard.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_hizli_satis.dart'
    hide Kullanici;
import 'package:hcastick/onmuhasebe/kullanici/profil.dart';
import 'package:hcastick/onmuhasebe/model.dart';
import 'package:hcastick/onmuhasebe/urun/urunlerpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: "hg_1993@windowslive.com",
  );
  final _sifreController = TextEditingController(text: "123456");
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  void sendResetLink(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lütfen email girin')));
      return;
    }

    final url = Uri.parse('https://soft.hggrup.com/auth/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"email": "$email"}',
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Dialog kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre sıfırlama linki gönderildi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email bulunamadı veya hata oluştu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sunucu hatası')));
    }
  }

  void showForgotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Şifremi Unuttum'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Emailinizi girin',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => sendResetLink(ctx),
              child: Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateCredentials(String email, String sifre) async {
    try {
      final response = await http.post(
        Uri.parse('https://soft.hggrup.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'sifre': sifre}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['message'] == 'Giriş başarılı') {
          final kullaniciData = data['kullanici'];
          aktifKullanici = Kullanici.fromJson(kullaniciData);

          return true;
        }
      }

      return false;
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final sifre = _sifreController.text.trim();

      final isValid = await _validateCredentials(email, sifre);

      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        // Başarılı giriş - Ana sayfaya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(email: email, sifre: sifre),
          ),
        );
      } else {
        // Hatalı giriş
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Email veya şifre hatalı!'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Card(
              elevation: 12,
              shadowColor: Colors.blue.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8FAFB)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo ve başlık
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Ön Muhasebe',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Sistemi',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hesaplarınızı yönetin, raporlarınızı görüntüleyin',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),

                        // Email Alanı
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-posta Adresi',
                            hintText: 'ornek@email.com',
                            prefixIcon: Container(
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF9FAFB),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta adresi gerekli';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Şifre Alanı
                        TextFormField(
                          controller: _sifreController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            hintText: 'Şifrenizi girin',
                            prefixIcon: Container(
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Color(0xFF6B7280),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF9FAFB),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),

                        // Giriş Butonu
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Giriş yapılıyor...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Şifremi unuttum linki
                        TextButton(
                          onPressed: () {
                            showForgotDialog(context);

                            setState(() {
                              emailController.text = _emailController.text;
                            });
                          },
                          child: Text(
                            'Şifremi unuttum',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// Ana sayfa - Ön Muhasebe Dashboard
class HomePage extends StatelessWidget {
  final String email;
  final String sifre;

  const HomePage({Key? key, required this.email, required this.sifre})
    : super(key: key);

  final double mobileBreakpoint = 600; // 600 px altı mobil kabul edelim

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 4; // masaüstü için
    if (screenWidth < mobileBreakpoint) {
      crossAxisCount = 2; // mobil için 2 sütun
    } else if (screenWidth < 900) {
      crossAxisCount = 3; // tablet gibi ara cihazlar için 3 sütun
    }
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          'Ön Muhasebe Sistemi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Color(0xFFE5E7EB)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF3B82F6),
              radius: 18,
              child: Text(
                email.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profil',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'ayarlar',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Ayarlar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'cikis',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'profil':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilSayfasi()),
                  );
                  break;
                case 'ayarlar':
                  // Ayarlar sayfasına git
                  break;
                case 'cikis':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginWidget()),
                  );
                  break;
              }
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hoş geldin mesajı
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz! 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Muhasebe işlemlerinizi kolayca yönetin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Hızlı işlemler başlığı
            Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 16),

            // Ana menü kartları
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              padding: const EdgeInsets.all(12),
              children: [
                _buildMenuCard(
                  context,
                  'Ürünler',
                  'Stok ve ürün takibi',
                  Icons.inventory_2_outlined,
                  const Color(0xFF10B981),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UrunListeSayfasi(firmaId: aktifKullanici.firma.id),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Firma içi Mesajlaşma',
                  'Grup içi yada Bireysel Planlama mesajlaşmaları',
                  Icons.people_outline,
                  const Color(0xFFF59E0B),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagesPage(
                          firmaId: aktifKullanici.firma.id,
                          kullaniciId: aktifKullanici.id,
                          n8nBaseUrl:
                              'https://n8n.hggrup.com/webhook-test/bb2c8b8e-6c70-4a18-8f41-f439e9ecfc95',
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Faturalar',
                  'Fatura oluşturma',
                  Icons.receipt_long_outlined,
                  const Color(0xFFEF4444),
                  () {
                    // Faturalar sayfasına git
                  },
                ),
                _buildMenuCard(
                  context,
                  'Raporlar',
                  'Mali analizler',
                  Icons.analytics_outlined,
                  const Color(0xFF8B5CF6),
                  () {
                    // Raporlar sayfasına git
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.darken(0.2), // extension method önerilir
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: color.darken(0.4)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
