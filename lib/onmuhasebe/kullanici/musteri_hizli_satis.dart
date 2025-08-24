// Hızlı Satış Sayfası
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_ekle.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_satis_yardimcilari.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_sepet_satis.dart';
import 'package:hcastick/onmuhasebe/urun/urun_api_servis.dart';
import 'package:http/http.dart' as http;

class HizliSatisSayfasi extends StatefulWidget {
  final Urun urun;
  const HizliSatisSayfasi({super.key, required this.urun});

  @override
  State<HizliSatisSayfasi> createState() => _HizliSatisSayfasiState();
}

class _HizliSatisSayfasiState extends State<HizliSatisSayfasi>
    with TickerProviderStateMixin {
  List<MusteriFirma> altFirmalar = [];
  MusteriFirma? seciliAltFirma;

  final TextEditingController miktarCtrl = TextEditingController();
  final TextEditingController fiyatCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool yukleniyor = false;
  bool dataYukleniyor = true;

  // Animasyon controller'ları
  late AnimationController _animationController;
  late AnimationController _buttonController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _buttonController.forward();
  }

  Future<void> _loadInitialData() async {
    setState(() => dataYukleniyor = true);
    await altFirmalariGetir();
    setState(() => dataYukleniyor = false);
  }

  Future<void> altFirmalariGetir() async {
    try {
      final anaFirmaId = aktifKullanici.firma.id;
      final res = await http.get(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/6504f2cb-7cc4-4f75-b7d9-fd84c78e463b?ana_firma_id=$anaFirmaId",
        ),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            altFirmalar = data.map((e) => MusteriFirma.fromJson(e)).toList();
          });
        }
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Alt firmalar yüklenirken hata oluştu: $e");
      }
    }
  }

  Future<void> _hizliSatis() async {
    if (!_formKey.currentState!.validate()) {
      _buttonController.reverse().then((_) => _buttonController.forward());
      return;
    }

    if (seciliAltFirma == null) {
      _showErrorSnackBar("Lütfen müşteri firma seçin");
      _buttonController.reverse().then((_) => _buttonController.forward());
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => yukleniyor = true);

    try {
      final body = {
        "ana_firma_id": aktifKullanici.firma.id,
        "musteri_firma_id": seciliAltFirma!.id,
        "urun_id": widget.urun.id,
        "miktar": double.tryParse(miktarCtrl.text) ?? 0,
        "birim_fiyat": double.tryParse(fiyatCtrl.text) ?? 0,
      };

      final res = await http.post(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/67e74cbf-e628-427c-b8b9-c2b106985a11",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        _showSuccessDialog();
        _clearForm();
      } else {
        _showErrorSnackBar("Hata: ${res.body}");
      }
    } catch (e) {
      _showErrorSnackBar("Bağlantı hatası: $e");
    } finally {
      if (mounted) {
        setState(() => yukleniyor = false);
      }
    }
  }

  void _clearForm() {
    miktarCtrl.clear();
    fiyatCtrl.clear();
    setState(() {
      seciliAltFirma = null;
    });
  }

  void _showSuccessDialog() {
    final toplam =
        (double.tryParse(miktarCtrl.text) ?? 0) *
        (double.tryParse(fiyatCtrl.text) ?? 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flash_on,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text("⚡ Hızlı Satış Başarılı!"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.urun.isim} başarıyla satıldı!"),
              const SizedBox(height: 8),
              Text("Müşteri: ${seciliAltFirma?.firmaAdi}"),
              Text("Miktar: ${miktarCtrl.text}"),
              Text("Birim Fiyat: ₺${fiyatCtrl.text}"),
              const Divider(),
              Text(
                "Toplam: ₺${toplam.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Ana sayfaya dön
              },
              child: const Text("Tamam"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Devam Et"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonController.dispose();
    miktarCtrl.dispose();
    fiyatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: dataYukleniyor ? _buildLoadingScreen() : _buildMainContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.green.shade600,
      foregroundColor: Colors.white,
      title: Text(
        "⚡ ${widget.urun.isim} - Hızlı Satış",
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SepetSatisSayfasi()),
          ),
          icon: const Icon(Icons.shopping_cart),
          tooltip: "Sepet Satışa Geç",
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "Veriler yükleniyor...",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Ürün Bilgi Kartı
                    _buildUrunBilgiCard(),

                    // Müşteri Seçimi
                    _buildMusteriFirmaCard(),

                    // Satış Detayları
                    _buildSatisDetaylariCard(),

                    // Hızlı Satış Butonu
                    const SizedBox(height: 20),
                    _buildHizliSatisButton(),

                    const SizedBox(height: 100), // FAB için alan
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrunBilgiCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "⚡ Satılacak Ürün",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.green.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.urun.isim,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stok Kodu: ${widget.urun.id}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusteriFirmaCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "👤 Müşteri Firma Seç",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: DropdownButtonFormField<MusteriFirma>(
              decoration: InputDecoration(
                hintText: "Hangi firmaya satacaksınız?",
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.blue.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              value: seciliAltFirma,
              items: altFirmalar.map((firma) {
                return DropdownMenuItem<MusteriFirma>(
                  value: firma,
                  child: Text(
                    firma.firmaAdi,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => seciliAltFirma = v),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisDetaylariCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "💰 Satış Detayları",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: miktarCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Miktar",
                          prefixIcon: Icon(
                            Icons.inventory,
                            color: Colors.orange.shade400,
                          ),
                          suffixText: "adet",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.orange.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Miktar gerekli";
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return "Geçerli miktar girin";
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            setState(() {}), // Toplamı güncellemek için
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: fiyatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Birim Fiyat",
                          prefixIcon: Icon(
                            Icons.monetization_on,
                            color: Colors.orange.shade400,
                          ),
                          prefixText: "₺",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.orange.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Fiyat gerekli";
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return "Geçerli fiyat girin";
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            setState(() {}), // Toplamı güncellemek için
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Toplam gösterimi
                if (miktarCtrl.text.isNotEmpty && fiyatCtrl.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Toplam Tutar:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          "₺${((double.tryParse(miktarCtrl.text) ?? 0) * (double.tryParse(fiyatCtrl.text) ?? 0)).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHizliSatisButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.teal.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: yukleniyor ? null : _hizliSatis,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (yukleniyor)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      const SizedBox(width: 12),
                      Text(
                        yukleniyor ? "Satış Yapılıyor..." : "⚡ Hızlı Satış Yap",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "sepet_sat",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SepetSatisSayfasi()),
          ),
          backgroundColor: Colors.indigo.shade600,
          child: const Icon(Icons.shopping_cart, color: Colors.white),
          tooltip: "Sepet Satışa Geç",
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: "add_customer",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ModernMusteriFirmaEkle()),
          ),
          backgroundColor: Colors.blue.shade600,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text(
            "Müşteri Ekle",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
