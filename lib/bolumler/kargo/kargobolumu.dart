import 'package:flutter/material.dart';
import 'package:hcastick/ayarlar/info.dart';
import 'package:hcastick/bolumler/kargo/kargoteklifleri.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class kargohesap extends StatefulWidget {
  const kargohesap({super.key});

  @override
  State<kargohesap> createState() => _kargohesapState();
}

class _kargohesapState extends State<kargohesap> with TickerProviderStateMixin {
  final renkler = Renkler();
  final webhook = hcawebhook();
  final TextEditingController enController = TextEditingController();
  final TextEditingController boyController = TextEditingController();
  final TextEditingController yukseklikController = TextEditingController();
  final TextEditingController kgController = TextEditingController();

  double? hesaplananDesi;
  bool isLoading = false;

  // Animasyon controller'ları
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon controller'larını başlat
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animasyonları başlat
    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);

    // Otomatik hesaplama için listener ekle
    enController.addListener(desiHesapla);
    boyController.addListener(desiHesapla);
    yukseklikController.addListener(desiHesapla);
    kgController.addListener(desiHesapla);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> webhookaGonder() async {
    if (hesaplananDesi == null) {
      _showAnimatedSnackBar(
        "Lütfen tüm değerleri doldurun ve desi hesaplayın",
        Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(webhook.geliverkargosorgu).replace(
      queryParameters: {
        "length": enController.text,
        "width": boyController.text,
        "height": yukseklikController.text,
        "weight": kgController.text,
        "paramType": "parcel",
      },
    );

    try {
      final cevap = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer 5bf88765-2e50-4833-9c43-4d42392e6c7f",
        },
      );
      final veri = json.decode(cevap.body);
      final teklifler = veri["priceList"][0]["offers"];

      if (cevap.statusCode == 200 || cevap.statusCode == 201) {
        // Sayfaya yönlendirme - aşağıdan yukarı animasyonu ile
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                KargoTeklifleriSayfasi(
                  teklifler: teklifler,
                  en: enController.text,
                  boy: boyController.text,
                  yukseklik: yukseklikController.text,
                  agirlik: kgController.text,
                  hesaplananDesi: hesaplananDesi!,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: Duration(milliseconds: 400),
          ),
        );
      } else {
        _showAnimatedSnackBar(
          "Gönderim başarısız ❌: ${cevap.statusCode}",
          Colors.red,
        );
      }
    } catch (e) {
      _showAnimatedSnackBar("Hata oluştu 🚨: $e", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAnimatedSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void desiHesapla() {
    double en = double.tryParse(enController.text) ?? 0;
    double boy = double.tryParse(boyController.text) ?? 0;
    double yukseklik = double.tryParse(yukseklikController.text) ?? 0;
    double kg = double.tryParse(kgController.text) ?? 0;

    if (en > 0 && boy > 0 && yukseklik > 0 && kg > 0) {
      double hacimDesi = (en * boy * yukseklik) / 3000;
      double sonDesi = hacimDesi > kg ? hacimDesi : kg;

      setState(() {
        hesaplananDesi = double.parse(sonDesi.toStringAsFixed(2));
      });
    } else {
      setState(() {
        hesaplananDesi = null;
      });
    }
  }

  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String suffix = 'cm',
    Color? iconColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor ?? Colors.blue, size: 24),
                ),
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                suffixText: suffix,
                suffixStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
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
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            "Kargo Hesaplama",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Ana Kart
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Başlık
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calculate,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Desi Hesaplama',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Input alanları
                      buildInputField(
                        label: 'En (Genişlik)',
                        icon: Icons.width_full,
                        controller: enController,
                        iconColor: Colors.green,
                      ),
                      buildInputField(
                        label: 'Boy (Uzunluk)',
                        icon: Icons.height,
                        controller: boyController,
                        iconColor: Colors.orange,
                      ),
                      buildInputField(
                        label: 'Yükseklik',
                        icon: Icons.vertical_align_top,
                        controller: yukseklikController,
                        iconColor: Colors.purple,
                      ),
                      buildInputField(
                        label: 'Ağırlık',
                        icon: Icons.scale,
                        controller: kgController,
                        suffix: 'kg',
                        iconColor: Colors.red,
                      ),

                      SizedBox(height: 24),

                      // Desi Sonucu
                      if (hesaplananDesi != null)
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
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
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.done_all,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Hesaplanan Desi: $hesaplananDesi',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Şablonlar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, color: Colors.blue, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Hızlı Şablonlar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      buildSablonKart(
                        "Dosya Paketi",
                        21,
                        29.7,
                        2,
                        0.1,
                        Icons.description,
                        Colors.blue,
                      ),
                      SizedBox(height: 12),
                      buildSablonKart(
                        "Küçük Koli",
                        15,
                        27,
                        21,
                        6,
                        Icons.mail_outline,
                        Colors.green,
                      ),
                      SizedBox(height: 12),
                      buildSablonKart(
                        "Orta Kutu",
                        30,
                        40,
                        20,
                        12,
                        Icons.inventory,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Gönder Butonu
              Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                  onPressed: isLoading ? null : webhookaGonder,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                              "Hesaplanıyor...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Kargo Tekliflerini Getir",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSablonKart(
    String isim,
    double en,
    double boy,
    double yukseklik,
    double kilo,
    IconData ikon,
    Color renk,
  ) {
    return InkWell(
      onTap: () {
        enController.text = en.toString();
        boyController.text = boy.toString();
        yukseklikController.text = yukseklik.toString();
        kgController.text = kilo.toString();

        // Haptic feedback
        // HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: renk.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: renk.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(ikon, color: renk, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isim,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: renk,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "En: $en cm, Boy: $boy cm",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    "Yükseklik: $yukseklik cm, Kilo: $kilo kg",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: renk, size: 16),
          ],
        ),
      ),
    );
  }
}
