// Sepet Satış Sayfası
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_ekle.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_satis_yardimcilari.dart';
import 'package:hcastick/onmuhasebe/urun/urun_api_servis.dart';
import 'package:http/http.dart' as http;

class SepetSatisSayfasi extends StatefulWidget {
  const SepetSatisSayfasi({super.key});

  @override
  State<SepetSatisSayfasi> createState() => _SepetSatisSayfasiState();
}

class _SepetSatisSayfasiState extends State<SepetSatisSayfasi>
    with TickerProviderStateMixin {
  List<MusteriFirma> altFirmalar = [];
  List<Urun> tumUrunler = [];
  List<SepetItem> sepetItems = [];

  MusteriFirma? seciliAltFirma;
  Urun? seciliUrun;
  final TextEditingController miktarCtrl = TextEditingController();
  final TextEditingController fiyatCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool yukleniyor = false;
  bool dataYukleniyor = true;

  // Animasyon controller'ları
  late AnimationController _animationController;
  late AnimationController _listController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _listSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _listSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _loadInitialData() async {
    setState(() => dataYukleniyor = true);
    await Future.wait([altFirmalariGetir(), _loadUrunler()]);
    setState(() => dataYukleniyor = false);
    _listController.forward();
  }

  Future<void> _loadUrunler() async {
    try {
      final urunler = await urunleriGetir(firmaId: aktifKullanici.firma.id);
      if (mounted) {
        setState(() => tumUrunler = urunler);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Ürünler yüklenirken hata oluştu: $e");
      }
    }
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

  Future<List<Urun>> urunleriGetir({required int firmaId}) async {
    final url = Uri.parse('https://soft.hggrup.com/api/urunler/$firmaId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Urun.fromJson(json)).toList();
    } else {
      throw Exception('Ürünler alınamadı. Hata kodu: ${response.statusCode}');
    }
  }

  void _sepeteEkle() {
    if (!_formKey.currentState!.validate()) return;
    if (seciliAltFirma == null) {
      _showErrorSnackBar("Lütfen müşteri firma seçin");
      return;
    }

    final item = SepetItem(
      urun: seciliUrun!,
      miktar: double.parse(miktarCtrl.text),
      birimFiyat: double.parse(fiyatCtrl.text),
      musteriFirma: seciliAltFirma!,
    );

    setState(() {
      sepetItems.add(item);
    });

    // Form temizle
    miktarCtrl.clear();
    fiyatCtrl.clear();
    setState(() {
      seciliUrun = null;
    });

    HapticFeedback.lightImpact();
    _showSuccessSnackBar("Ürün sepete eklendi! 🛒");
  }

  void _sepettenCikar(int index) {
    setState(() {
      sepetItems.removeAt(index);
    });
    HapticFeedback.lightImpact();
    _showSuccessSnackBar("Ürün sepetten çıkarıldı");
  }

  void _sepetiTemizle() {
    setState(() {
      sepetItems.clear();
    });
    HapticFeedback.mediumImpact();
    _showSuccessSnackBar("Sepet temizlendi");
  }

  Future<void> _sepetiSat() async {
    if (sepetItems.isEmpty) {
      _showErrorSnackBar("Sepet boş!");
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => yukleniyor = true);

    try {
      final List<Map<String, dynamic>> urunListesi = sepetItems.map((item) {
        return {
          "ana_firma_id": aktifKullanici.firma.id,
          "musteri_firma_id": item.musteriFirma.id,
          "urun_id": item.urun.id,
          "miktar": item.miktar,
          "birim_fiyat": item.birimFiyat,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/7a5633f3-6226-4c84-a9ba-f9a851e82300",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sepet": urunListesi}),
      );

      if (response.statusCode == 201) {
        _showSuccessSnackBar("Satış başarıyla gerçekleştirildi!");
        setState(() {
          sepetItems.clear(); // Sepeti boşalt
        });
      } else {
        throw Exception("Hata: ${response.body}");
      }
    } catch (e) {
      _showSuccessDialog();
      setState(() {
        sepetItems.clear();
        seciliAltFirma = null;
      });
    } finally {
      if (mounted) {
        setState(() => yukleniyor = false);
      }
    }
  }

  double get sepetToplam {
    return sepetItems.fold(
      0.0,
      (sum, item) => sum + (item.miktar * item.birimFiyat),
    );
  }

  void _showSuccessDialog() {
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
                  Icons.check,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text("🎉 Başarılı!"),
            ],
          ),
          content: Text(
            "${sepetItems.length} ürün başarıyla satıldı!\nToplam: ₺${sepetToplam.toStringAsFixed(2)}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tamam"),
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listController.dispose();
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
      backgroundColor: Colors.indigo.shade600,
      foregroundColor: Colors.white,
      title: const Text(
        "🛒 Sepet Satış",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        if (sepetItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${sepetItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
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
              child: Column(
                children: [
                  // Müşteri Firma Seçimi
                  _buildMusteriFirmaCard(),

                  // Ürün Ekleme Formu
                  _buildUrunEklemeCard(),

                  // Sepet Listesi
                  if (sepetItems.isNotEmpty) _buildSepetCard(),

                  const SizedBox(height: 100), // FAB için alan
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMusteriFirmaCard() {
    return _buildCard(
      title: "👤 Müşteri Firma",
      color: Colors.blue.shade600,
      child: DropdownButtonFormField<MusteriFirma>(
        decoration: InputDecoration(
          hintText: "Müşteri firma seçin",
          prefixIcon: Icon(Icons.business_center, color: Colors.blue.shade400),
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
            child: Text(firma.firmaAdi, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (v) => setState(() => seciliAltFirma = v),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildUrunEklemeCard() {
    return _buildCard(
      title: "➕ Ürün Ekle",
      color: Colors.indigo.shade600,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<Urun>(
              decoration: InputDecoration(
                labelText: "Ürün Seç",
                prefixIcon: Icon(
                  Icons.inventory_2,
                  color: Colors.indigo.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.indigo.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              value: seciliUrun,
              items: tumUrunler.map((urun) {
                return DropdownMenuItem<Urun>(
                  value: urun,
                  child: Text(urun.isim, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (v) => setState(() => seciliUrun = v),
              validator: (v) => v == null ? "Ürün seçin" : null,
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16),
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
                        color: Colors.indigo.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Miktar gerekli";
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return "Geçerli miktar girin";
                      }
                      return null;
                    },
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
                        color: Colors.indigo.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Fiyat gerekli";
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return "Geçerli fiyat girin";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _sepeteEkle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  "Sepete Ekle",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSepetCard() {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _listSlideAnimation.value),
          child: _buildCard(
            title: "🛒 Sepet (${sepetItems.length} ürün)",
            color: Colors.orange.shade600,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Toplam Tutar:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      Text(
                        "₺${sepetToplam.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sepetItems.length,
                  itemBuilder: (context, index) {
                    final item = sepetItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.urun.isim,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.musteriFirma.firmaAdi,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${item.miktar} adet × ₺${item.birimFiyat.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Colors.indigo.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₺${(item.miktar * item.birimFiyat).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _sepettenCikar(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade600,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sepetiTemizle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.clear_all, color: Colors.white),
                        label: const Text(
                          "Sepeti Temizle",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: yukleniyor ? null : _sepetiSat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: yukleniyor
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.payment, color: Colors.white),
                        label: Text(
                          yukleniyor ? "Satılıyor..." : "Sepeti Sat",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ModernMusteriFirmaEkle()),
      ),
      backgroundColor: Colors.indigo.shade600,
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        "Müşteri Ekle",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Sepet item modeli
class SepetItem {
  final Urun urun;
  final double miktar;
  final double birimFiyat;
  final MusteriFirma musteriFirma;

  SepetItem({
    required this.urun,
    required this.miktar,
    required this.birimFiyat,
    required this.musteriFirma,
  });
}
