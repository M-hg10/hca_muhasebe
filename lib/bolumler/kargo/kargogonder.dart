import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcastick/ayarlar/info.dart';
import 'package:http/http.dart' as http;

class Kargogonder extends StatefulWidget {
  final String kargoFirmasi;
  final String paket;
  final String en;
  final String boy;
  final String yukseklik;
  final String gercekfiyat;
  final String teklif;
  final String agirlik;
  final String desi;

  const Kargogonder({
    super.key,
    required this.kargoFirmasi,
    required this.paket,
    required this.en,
    required this.boy,
    required this.yukseklik,
    required this.gercekfiyat,
    required this.teklif,
    required this.agirlik,
    required this.desi,
  });

  @override
  State<Kargogonder> createState() => _KargogonderState();
}

class _KargogonderState extends State<Kargogonder>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final webhook = hcawebhook();

  // Controllers
  final TextEditingController gondericiAdresController =
      TextEditingController();
  final TextEditingController gondericiTelefonController =
      TextEditingController();
  final TextEditingController aliciAdresController = TextEditingController();
  final TextEditingController aliciTelefonController = TextEditingController();
  final TextEditingController aliciController = TextEditingController();

  bool isLoading = false;
  int currentStep = 0;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;


  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _successController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );


    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    gondericiAdresController.dispose();
    gondericiTelefonController.dispose();
    aliciAdresController.dispose();
    aliciTelefonController.dispose();
    aliciController.dispose();
    super.dispose();
  }

  Future<void> _sendWebhook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    // Show loading animation
    _showLoadingDialog();

    final Map<String, dynamic> payload = {
      'kargoFirmasi': widget.kargoFirmasi,
      'paket': widget.paket,
      'en': widget.en,
      'boy': widget.boy,
      'yukseklik': widget.yukseklik,
      'gercekfiyat': widget.gercekfiyat,
      'teklif': widget.teklif,
      'agirlik': widget.agirlik,
      'desi': widget.desi,
      'gondericiAdres': gondericiAdresController.text,
      'gondericiTelefon': gondericiTelefonController.text,
      'aliciAdres': aliciAdresController.text,
      'aliciTelefon': aliciTelefonController.text,
      'alici': aliciController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(webhook.kargoentegrasyon),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close loading dialog
        await _showSuccessDialog();
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        throw Exception('Sunucudan beklenmeyen cevap: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Gönderim hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Kargonuz hazırlanıyor...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Lütfen bekleyiniz',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 50),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Başarılı!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kargonuz başarıyla gönderildi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Tamam', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Widget buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: iconColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Kargo Gönderimi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Kargo Bilgileri Kartı
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.deepPurple.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Kargo Detayları',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              '🚚 Kargo Firması',
                              widget.kargoFirmasi,
                            ),
                            _buildInfoRow(
                              '📦 Paket & Ağırlık',
                              '${widget.paket} - ${widget.agirlik} kg',
                            ),
                            _buildInfoRow(
                              '📏 Boyutlar',
                              '${widget.en} x ${widget.boy} x ${widget.yukseklik} cm',
                            ),
                            _buildInfoRow(
                              '💰 Teklif Fiyatı',
                              '${widget.teklif} ₺',
                            ),
                            _buildInfoRow('⚖️ Desi', '${widget.desi}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),

                // Gönderici Bilgileri Başlığı
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Gönderici Bilgileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Gönderici Form Alanları
                buildAnimatedTextField(
                  controller: gondericiAdresController,
                  label: 'Gönderici Adresi',
                  icon: Icons.location_on,
                  iconColor: Colors.blue,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Gönderici adresi gerekli'
                      : null,
                  delay: 100,
                ),

                buildAnimatedTextField(
                  controller: gondericiTelefonController,
                  label: 'Gönderici Telefonu',
                  icon: Icons.phone,
                  iconColor: Colors.green,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Telefon numarası gerekli'
                      : null,
                  delay: 200,
                ),

                SizedBox(height: 24),

                // Alıcı Bilgileri Başlığı
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_pin_circle,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Alıcı Bilgileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Alıcı Form Alanları
                buildAnimatedTextField(
                  controller: aliciController,
                  label: 'Alıcı Ad Soyad',
                  icon: Icons.person,
                  iconColor: Colors.orange,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Alıcı adı gerekli' : null,
                  delay: 300,
                ),

                buildAnimatedTextField(
                  controller: aliciAdresController,
                  label: 'Alıcı Adresi',
                  icon: Icons.location_city,
                  iconColor: Colors.orange,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Alıcı adresi gerekli'
                      : null,
                  delay: 400,
                ),

                buildAnimatedTextField(
                  controller: aliciTelefonController,
                  label: 'Alıcı Telefonu',
                  icon: Icons.phone_android,
                  iconColor: Colors.red,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Telefon numarası gerekli'
                      : null,
                  delay: 500,
                ),

                SizedBox(height: 24),

                // Ödeme Bilgileri Kartı
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Ödeme Bilgileri',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kargo gönderimi sonrası bakiye yüklemeniz gerekecektir.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  _buildPaymentInfoRow(
                                    '🏦 Banka',
                                    'KUVEYT TÜRK',
                                  ),
                                  _buildPaymentInfoRow(
                                    '🔢 IBAN',
                                    'TR75 0020 5000 0971 6288 4000 01',
                                  ),
                                  _buildPaymentInfoRow(
                                    '👤 Alıcı',
                                    'Halil GEZER',
                                  ),
                                  _buildPaymentInfoRow(
                                    '📌 Açıklama',
                                    'ASDASEFEV',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),

                // Gönder Butonu
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                    ),
                    onPressed: isLoading ? null : _sendWebhook,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Gönderiliyor...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Kargoyu Gönder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
