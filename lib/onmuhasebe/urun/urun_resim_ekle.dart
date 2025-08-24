import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hcastick/onmuhasebe/urun/fiyat_gor.dart';
import 'package:hcastick/onmuhasebe/urun/urun_api_servis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UrunResimEklemePage extends StatefulWidget {
  final Urun urun;
  const UrunResimEklemePage({super.key, required this.urun});

  @override
  State<UrunResimEklemePage> createState() => _UrunResimEklemePageState();
}

class _UrunResimEklemePageState extends State<UrunResimEklemePage>
    with TickerProviderStateMixin {
  bool _loading = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<ProductImage> _productImages = [];

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Future<void> _uploadImageUrl() async {
    if (!_formKey.currentState!.validate()) {
      _scaleController.forward().then((_) => _scaleController.reverse());
      return;
    }

    setState(() => _loading = true);
    _fadeController.forward();

    try {
      final response = await http.post(
        Uri.parse(
          'https://n8n.hggrup.com/webhook/6aa61ae3-3cf6-46b7-af51-55e6d35cb059?urunId=${widget.urun.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageUrl': _urlController.text.trim(),
          'aciklama': _aciklamaController.text.trim(),
          'urun_id': widget.urun.id.toString(),
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final jsonData = jsonDecode(response.body);
            print("Sunucu cevabı: $jsonData");
          } catch (e) {
            print("JSON parse hatası: $e");
          }
        }

        _urlController.clear();
        _aciklamaController.clear();
        _fetchImages();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Resim başarıyla eklendi!"),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        print("Resim yükleme başarısız, kod: ${response.statusCode}");
        print("Sunucu cevabı: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text("Yükleme başarısız: ${response.statusCode}"),
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
    } catch (e) {
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Text("Hata: $e"),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    _fadeController.reverse();
    setState(() => _loading = false);
  }

  Future<void> _fetchImages() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://n8n.hggrup.com/webhook/ba56f087-f6bd-49d0-92c0-a95bd98c239d',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'urunId': widget.urun.id, 'action': 'get_images'}),
      );

      print('response : ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<ProductImage> productImages = data
            .map((e) => ProductImage.fromJson(e))
            .toList();

        setState(() {
          _productImages = productImages;
        });
      }
    } catch (e) {
      print('Resim yükleme hatası: $e');
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Resim URL\'si gerekli';
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAbsolutePath) {
      return 'Geçerli bir URL girin';
    }

    if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
      return 'URL http:// veya https:// ile başlamalı';
    }

    final path = uri.path.toLowerCase();
    if (!path.contains('.jpg') &&
        !path.contains('.jpeg') &&
        !path.contains('.png') &&
        !path.contains('.gif') &&
        !path.contains('.webp')) {
      return 'Geçerli bir resim URL\'si girin (.jpg, .png, .gif, .webp)';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _fetchImages();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _aciklamaController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("${widget.urun.isim} Resimleri"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Gradient Header
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.purple[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // URL Giriş Formu
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🖼️ Yeni Resim Ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Resim URL\'si',
                        hintText: 'https://example.com/resim.jpg',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.link, color: Colors.blue[600]),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.blue[400]!,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.red[400]!,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _validateUrl,
                      keyboardType: TextInputType.url,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Açıklama Alanı
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: TextFormField(
                      controller: _aciklamaController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: 'Resim Açıklaması (Opsiyonel)',
                        hintText:
                            'Bu resim hakkında kısa bir açıklama yazın...',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.description,
                            color: Colors.green[600],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.green[400]!,
                            width: 2,
                          ),
                        ),
                        counterStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: _loading
                                  ? [Colors.grey[400]!, Colors.grey[500]!]
                                  : [Colors.blue[600]!, Colors.purple[600]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_loading ? Colors.grey : Colors.blue)
                                    .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _uploadImageUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: _loading
                                ? FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.cloud_upload,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _loading ? 'Yükleniyor...' : '✨ Resim Ekle',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Resim Listesi
          Expanded(
            child: _loading && _productImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Resimler yükleniyor...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : _productImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '📷 Henüz resim eklenmemiş',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yukarıdaki form ile resim ekleyebilirsiniz',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _productImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'image_$index',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _productImages[index].resimUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red[100]!,
                                            Colors.red[200]!,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: Colors.red[400],
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Resim yüklenemedi',
                                            style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue[50]!,
                                                Colors.purple[50]!,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.blue[400]!,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              ),
                              // Açıklama overlay'i
                              if (_productImages[index].aciklama != null &&
                                  _productImages[index].aciklama!.isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      _productImages[index].aciklama!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
