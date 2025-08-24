import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AnimatedProductForm extends StatefulWidget {
  @override
  _AnimatedProductFormState createState() => _AnimatedProductFormState();
}

class _AnimatedProductFormState extends State<AnimatedProductForm>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  // Controllers
  final barkodController = TextEditingController();
  final urunAdiController = TextEditingController();
  final kategoriController = TextEditingController();
  final markaController = TextEditingController();
  final tedarikciController = TextEditingController();
  final birimController = TextEditingController();
  final birimFiyatController = TextEditingController();
  final alisFiyatController = TextEditingController();
  final kdvOraniController = TextEditingController();
  final stokMiktariController = TextEditingController();
  final kritikStokMiktariController = TextEditingController();
  final olusturmaTarihiController = TextEditingController();
  final guncellemeTarihiController = TextEditingController();
  final aciklamaController = TextEditingController();
  final toptanFiyatController = TextEditingController();
  final perakandeFiyatController = TextEditingController();
  final kisaAciklamaController = TextEditingController();

  bool aktif = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Widget buildAnimatedTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    IconData? icon,
    int index = 0,
  }) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            50 *
                (1 - Curves.easeOutCubic.transform(_slideController.value)) *
                (1 - (index * 0.1).clamp(0, 1)),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Interval(
                  (index * 0.05).clamp(0, 0.8),
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: controller,
                keyboardType: isNumber
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: isNumber
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                    : null,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: icon != null
                      ? Icon(icon, color: Colors.blue.shade600)
                      : null,
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 2,
                    ),
                  ),
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '$label boş olamaz';
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedSwitch() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aktif ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: aktif ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            aktif ? Icons.check_circle : Icons.cancel,
            color: aktif ? Colors.green.shade600 : Colors.red.shade600,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Ürün Durumu",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: aktif ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          Switch(
            value: aktif,
            onChanged: (val) {
              setState(() => aktif = val);
              HapticFeedback.lightImpact();
            },
            activeColor: Colors.green.shade600,
            inactiveThumbColor: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  void gonderWebhook() async {
    setState(() => _isLoading = true);
    _buttonController.forward();

    final Map<String, dynamic> veri = {
      "barkod": barkodController.text,
      "urun_adi": urunAdiController.text,
      "kategori": kategoriController.text,
      "marka": markaController.text,
      "tedarikci": tedarikciController.text,
      "birim": birimController.text,
      "birim_fiyat": birimFiyatController.text,
      "alis_fiyati": alisFiyatController.text,
      "kdv_orani": kdvOraniController.text,
      "stok_miktari": stokMiktariController.text,
      "kritik_stok_miktari": kritikStokMiktariController.text,
      "aktif": aktif,
      "olusturma_tarihi": olusturmaTarihiController.text,
      "guncelleme_tarihi": guncellemeTarihiController.text,
      "aciklama": aciklamaController.text,
      "toptan_fiyat": toptanFiyatController.text,
      "perakande_fiyat": perakandeFiyatController.text,
      "kisa_aciklama": kisaAciklamaController.text,
    };

    try {
      const String webhookUrl =
          'https://n8n.hggrup.com/webhook/51665d45-9848-4f4a-85fa-1fe0aea92b8e';

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(veri),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ürün başarıyla gönderildi')));
      } else {
        throw Exception('Webhook gönderimi başarısız: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }

    setState(() => _isLoading = false);
    _buttonController.reverse();

    // Success animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Ürün başarıyla kaydedildi!"),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Ürün Giriş Formu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temel Bilgiler
              buildSectionHeader("Temel Bilgiler", Icons.info_outline),
              buildAnimatedTextField(
                "Barkod",
                barkodController,
                icon: Icons.qr_code,
                index: 0,
              ),
              buildAnimatedTextField(
                "Ürün Adı",
                urunAdiController,
                icon: Icons.inventory,
                index: 1,
              ),
              buildAnimatedTextField(
                "Kategori",
                kategoriController,
                icon: Icons.category,
                index: 2,
              ),
              buildAnimatedTextField(
                "Marka",
                markaController,
                icon: Icons.branding_watermark,
                index: 3,
              ),
              buildAnimatedTextField(
                "Tedarikçi",
                tedarikciController,
                icon: Icons.business,
                index: 4,
              ),
              buildAnimatedTextField(
                "Birim",
                birimController,
                icon: Icons.straighten,
                index: 5,
              ),

              // Fiyat Bilgileri
              buildSectionHeader("Fiyat Bilgileri", Icons.attach_money),
              buildAnimatedTextField(
                "Birim Fiyat",
                birimFiyatController,
                icon: Icons.price_change,
                index: 6,
              ),
              buildAnimatedTextField(
                "Alış Fiyatı",
                alisFiyatController,
                isNumber: true,
                icon: Icons.shopping_cart,
                index: 7,
              ),
              buildAnimatedTextField(
                "Toptan Fiyat",
                toptanFiyatController,
                isNumber: true,
                icon: Icons.store,
                index: 8,
              ),
              buildAnimatedTextField(
                "Perakende Fiyat",
                perakandeFiyatController,
                isNumber: true,
                icon: Icons.storefront,
                index: 9,
              ),
              buildAnimatedTextField(
                "KDV Oranı (%)",
                kdvOraniController,
                isNumber: true,
                icon: Icons.percent,
                index: 10,
              ),

              // Stok Bilgileri
              buildSectionHeader("Stok Bilgileri", Icons.inventory_2),
              buildAnimatedTextField(
                "Stok Miktarı",
                stokMiktariController,
                isNumber: true,
                icon: Icons.numbers,
                index: 11,
              ),
              buildAnimatedTextField(
                "Kritik Stok Miktarı",
                kritikStokMiktariController,
                isNumber: true,
                icon: Icons.warning,
                index: 12,
              ),

              // Durum
              buildSectionHeader("Durum", Icons.toggle_on),
              buildAnimatedSwitch(),

              // Tarih Bilgileri
              buildSectionHeader("Tarih Bilgileri", Icons.calendar_today),
              buildAnimatedTextField(
                "Oluşturma Tarihi (YYYY-MM-DD)",
                olusturmaTarihiController,
                icon: Icons.event,
                index: 13,
              ),
              buildAnimatedTextField(
                "Güncelleme Tarihi (YYYY-MM-DD)",
                guncellemeTarihiController,
                icon: Icons.update,
                index: 14,
              ),

              // Açıklamalar
              buildSectionHeader("Açıklamalar", Icons.description),
              buildAnimatedTextField(
                "Kısa Açıklama",
                kisaAciklamaController,
                icon: Icons.short_text,
                index: 15,
              ),
              buildAnimatedTextField(
                "Detaylı Açıklama",
                aciklamaController,
                maxLines: 3,
                icon: Icons.notes,
                index: 16,
              ),

              SizedBox(height: 32),

              // Kaydet Butonu
              AnimatedBuilder(
                animation: _buttonController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 - (_buttonController.value * 0.05),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                if (_formKey.currentState!.validate()) {
                                  print(
                                    "Ürün eklendi: ${urunAdiController.text}",
                                  );
                                  gonderWebhook();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.blue.shade300,
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
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Kaydediliyor...",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    "Kaydet",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
