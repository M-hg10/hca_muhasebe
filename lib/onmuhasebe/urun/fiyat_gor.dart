import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductInfoPage extends StatelessWidget {
  final dynamic data;

  const ProductInfoPage({Key? key, required this.data}) : super(key: key);

  List<Map<String, dynamic>> get _processedData {
    if (data is List) {
      return (data as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final processedData = _processedData;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ürün Bilgisi'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: processedData.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz ürün bilgisi bulunmuyor',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: processedData.length,
              itemBuilder: (context, index) {
                final urun = processedData[index];
                return ProductCard(product: urun);
              },
            ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPriceExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchProductImages(widget.product['id']);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [_buildHeader(), _buildBasicInfo(), _buildPriceSection()],
      ),
    );
  }

  Widget _buildHeader() {
    if (_productImages.isEmpty) return SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.indigo[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_productImages.isNotEmpty)
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _productImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 12),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _productImages[0].resimUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.error_outline),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 10),
                Text(
                  widget.product['isim'] ?? 'Ürün İsmi Belirtilmemiş',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ürün Detayları',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.business_outlined,
            'Marka',
            widget.product['marka'],
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.qr_code_outlined,
            'Barkod',
            widget.product['barkod'],
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? 'Belirtilmemiş',
                style: TextStyle(
                  fontSize: 16,
                  color: value != null ? Colors.grey[800] : Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontStyle: value != null
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isPriceExpanded = !_isPriceExpanded;
                if (_isPriceExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.monetization_on_outlined,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fiyat Bilgileri',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _isPriceExpanded ? 'Gizle' : _getPricePreview(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isPriceExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isPriceExpanded
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          Divider(color: Colors.grey[300], height: 1),
                          const SizedBox(height: 16),
                          _buildPriceInfoRow(
                            Icons.category_outlined,
                            'Fiyat Türü',
                            widget.product['fiyat_turu'],
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildPriceInfoRow(
                            Icons.attach_money,
                            'Fiyat',
                            _formatPrice(),
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfoRow(
    IconData icon,
    String label,
    String? value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? 'Belirtilmemiş',
                style: TextStyle(
                  fontSize: 15,
                  color: value != null ? Colors.grey[800] : Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontStyle: value != null
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fetchProductImages(int urunId) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://n8n.hggrup.com/webhook/ba56f087-f6bd-49d0-92c0-a95bd98c239d',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'urunId': urunId, 'action': 'get_images'}),
      );
      // ignore: unnecessary_brace_in_string_interps, avoid_print
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

  // Widget'ta kullanım:
  List<ProductImage> _productImages = [];

  String _getPricePreview() {
    final fiyatTuru = widget.product['fiyat_turu'];
    final fiyat = _formatPrice();

    if (fiyatTuru != null && fiyat != null) {
      return '$fiyatTuru';
    } else if (fiyatTuru != null) {
      return fiyatTuru;
    } else if (fiyat != null) {
      return fiyat;
    } else {
      return 'Görüntüle';
    }
  }

  String? _formatPrice() {
    final fiyat = widget.product['fiyat'];
    final paraBirimi = widget.product['para_birimi'];

    if (fiyat == null) return null;

    String formattedPrice;
    if (fiyat is num) {
      formattedPrice = fiyat.toString();
    } else {
      formattedPrice = fiyat.toString();
    }

    return paraBirimi != null ? '$formattedPrice $paraBirimi' : formattedPrice;
  }
}

class ProductImage {
  final int id;
  final int urunId;
  final String resimUrl;
  final int siraNo;
  final String aciklama;
  final bool aktif;

  ProductImage({
    required this.id,
    required this.urunId,
    required this.resimUrl,
    required this.siraNo,
    required this.aciklama,
    required this.aktif,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      urunId: json['urun_id'] ?? 0,
      resimUrl: json['resim_url'] ?? '',
      siraNo: json['sira_no'] ?? 0,
      aciklama: json['aciklama'] ?? '',
      aktif: json['aktif'] ?? false,
    );
  }
}
