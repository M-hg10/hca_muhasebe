import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Urunekle extends StatefulWidget {
  final Kullanici kullanici;

  const Urunekle({super.key, required this.kullanici});

  @override
  State<Urunekle> createState() => _UrunekleState();
}

class _UrunekleState extends State<Urunekle> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _kisaAciklamaController = TextEditingController();
  final _markaController = TextEditingController();
  final _barkodController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dropdown değerleri
  List<Kategori> _kategoriler = [];
  List<AltKategori> _altKategoriler = [];
  List<UrunDurumu> _urunDurumlari = [];
  int? selectedKategoriId;
  int? selectedAltKategoriId;

  List<AltKategori> filteredAltKategoriler = [];

  // Seçilen değerler
  int? _secilenKategoriId;
  int? _secilenAltKategoriId;
  int? _secilenUrunDurumuId;
  bool _aktif = true;

  bool _isLoading = true;
  bool _isSaving = false;

  late Firma firma;

  @override
  void initState() {
    super.initState();
    firma = aktifKullanici.firma;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    initsatemanuel();
  }

  Future<void> initsatemanuel() async {
    await ApiService.instance.loadDropdownData();
    setState(() {
      _kategoriler = ApiService.instance.kategoriler;
      _altKategoriler = ApiService.instance.altKategoriler;
      _urunDurumlari = ApiService.instance.urunDurumlari;
      _isLoading = false;
    });

    _animationController.forward();

    print(_kategoriler[0].isim);
    print(_altKategoriler.length);
    print(_urunDurumlari[0].ad);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final body = {
        'isim': _isimController.text,
        'barkod': _barkodController.text,
        'aciklama': _aciklamaController.text.isEmpty
            ? null
            : _aciklamaController.text,
        'kisa_aciklama': _kisaAciklamaController.text.isEmpty
            ? null
            : _kisaAciklamaController.text,
        'aktif': _aktif,
        'kategori_id': _secilenKategoriId,
        'marka': _markaController.text.isEmpty ? null : _markaController.text,
        'urun_durumu_id': _secilenUrunDurumuId,
        'alt_kategori_id': _secilenAltKategoriId,
        'firma_id': aktifKullanici.firma.id,
      };
      print("post body ${body}");

      final response = await http.post(
        // https://n8n.hggrup.com/webhook-test/996b8225-9d47-4ab1-a39c-85ca633290bb
        // https://soft.hggrup.com/api/urunler/
        Uri.parse(
          'https://n8n.hggrup.com/webhook/996b8225-9d47-4ab1-a39c-85ca633290bb',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Ürün başarıyla eklendi');
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Bilinmeyen hata');
      }
    } catch (error) {
      _showErrorSnackBar('Ürün eklenirken hata oluştu: $error');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
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
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildModernCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
          ),
        ),
        child: Column(
          children: [
            // Modern AppBar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Yeni Ürün Ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isSaving)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF667eea),
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),

                                    // Header Card
                                    _buildModernCard(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF667eea),
                                                  Color(0xFF764ba2),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Ürün Bilgileri',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Yeni ürününüzün detaylarını giriniz',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Basic Info Card
                                    _buildModernCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Temel Bilgiler',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _buildModernTextField(
                                            controller: _isimController,
                                            label: 'Ürün İsmi',
                                            icon: Icons.inventory_2,
                                            isRequired: true,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Ürün ismi zorunludur';
                                              }
                                              return null;
                                            },
                                          ),
                                          _buildModernTextField(
                                            controller: _barkodController,
                                            label: 'Varsa Barkod',
                                            icon: Icons.bar_chart_rounded,
                                            isRequired: true,
                                          ),

                                          _buildModernTextField(
                                            controller: _markaController,
                                            label: 'Marka',
                                            icon: Icons.business_center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Category Card
                                    _buildModernCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Kategori Seçimi',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _buildModernDropdown<int>(
                                            value: selectedKategoriId,
                                            hint: 'Kategori Seç',
                                            icon: Icons.category,
                                            items: ApiService
                                                .instance
                                                .kategoriler
                                                .map(
                                                  (kategori) =>
                                                      DropdownMenuItem<int>(
                                                        value: kategori.id,
                                                        child: Text(
                                                          kategori.isim,
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedKategoriId = value;
                                                _secilenKategoriId = value;
                                                filteredAltKategoriler = ApiService
                                                    .instance
                                                    .getAltKategorilerByKategoriId(
                                                      value!,
                                                    );
                                                selectedAltKategoriId = null;
                                                _secilenAltKategoriId = null;
                                              });
                                            },
                                          ),

                                          _buildModernDropdown<int>(
                                            value: selectedAltKategoriId,
                                            hint: 'Alt Kategori Seç',
                                            icon:
                                                Icons.subdirectory_arrow_right,
                                            items: filteredAltKategoriler
                                                .map(
                                                  (alt) =>
                                                      DropdownMenuItem<int>(
                                                        value: alt.id,
                                                        child: Text(alt.isim),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedAltKategoriId = value;
                                                _secilenAltKategoriId = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status Card
                                    _buildModernCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Durum Bilgileri',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _buildModernDropdown<int>(
                                            value: _secilenUrunDurumuId,
                                            hint: 'Ürün Durumu',
                                            icon: Icons.info_outline,
                                            items: _urunDurumlari.map((durum) {
                                              return DropdownMenuItem<int>(
                                                value: durum.id,
                                                child: Text(durum.ad),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(
                                                () => _secilenUrunDurumuId =
                                                    value,
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 16),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: _aktif
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _aktif
                                                    ? Colors.green.shade200
                                                    : Colors.red.shade200,
                                              ),
                                            ),
                                            child: SwitchListTile(
                                              title: Text(
                                                'Aktif Durumu',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: _aktif
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                ),
                                              ),
                                              subtitle: Text(
                                                _aktif
                                                    ? 'Ürün aktif durumda'
                                                    : 'Ürün pasif durumda',
                                                style: TextStyle(
                                                  color: _aktif
                                                      ? Colors.green.shade600
                                                      : Colors.red.shade600,
                                                ),
                                              ),
                                              value: _aktif,
                                              activeColor: Colors.green,
                                              onChanged: (value) {
                                                setState(() => _aktif = value);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Description Card
                                    _buildModernCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Açıklamalar',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _buildModernTextField(
                                            controller: _kisaAciklamaController,
                                            label: 'Kısa Açıklama',
                                            icon: Icons.short_text,
                                            maxLines: 2,
                                          ),

                                          _buildModernTextField(
                                            controller: _aciklamaController,
                                            label: 'Detaylı Açıklama',
                                            icon: Icons.description,
                                            maxLines: 4,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Save Button
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF667eea,
                                            ).withOpacity(0.3),
                                            spreadRadius: 0,
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isSaving
                                            ? null
                                            : _saveProduct,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: _isSaving
                                            ? const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Kaydediliyor...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Text(
                                                'Ürünü Kaydet',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // Info Card
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade50,
                                            Colors.indigo.shade50,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.lightbulb_outline,
                                              color: Colors.blue.shade600,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Bilgi',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Ürün İsmi zorunlu alandır. Diğer alanlar isteğe bağlıdır.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isimController.dispose();
    _aciklamaController.dispose();
    _kisaAciklamaController.dispose();
    _markaController.dispose();
    super.dispose();
  }
}
