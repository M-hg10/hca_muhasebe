import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hcastick/bolumler/urunler/urunlerdataservis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Sipariş callback fonksiyonu için typedef
typedef OnOrderCallback = Future<bool> Function(Map<String, dynamic> orderData);

// Ana Satış Widget'ı
class ProductSalesWidget extends StatefulWidget {
  final Product product;
  final String? webhookUrl;
  final OnOrderCallback? onOrderSubmit;
  final bool showWebhookInput;
  final int initialQuantity;
  final int maxQuantity;
  final VoidCallback? onBack;
  final String? customTitle;

  const ProductSalesWidget({
    Key? key,
    required this.product,
    this.webhookUrl,
    this.onOrderSubmit,
    this.showWebhookInput = true,
    this.initialQuantity = 1,
    this.maxQuantity = 999,
    this.onBack,
    this.customTitle,
  }) : super(key: key);

  @override
  State<ProductSalesWidget> createState() => _ProductSalesWidgetState();
}

class _ProductSalesWidgetState extends State<ProductSalesWidget> {
  late int quantity;
  late double total;
  late double kdvDahilTotal;
  bool isLoading = false;
  String status = '';

  late TextEditingController quantityController;
  late TextEditingController Alici;

  TextEditingController ekHizmet = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    quantityController = TextEditingController(text: quantity.toString());
    Alici = TextEditingController(text: widget.webhookUrl ?? '');

    quantityController.addListener(_calculateTotal);
    _calculateTotal();
  }

  double unitPrice = 0.0;

  void _calculateTotal() {
    final q = int.tryParse(quantityController.text) ?? 0;
    final p = double.tryParse(unitPriceController.text) ?? 0.0;
    final e = double.tryParse(ekHizmet.text) ?? 0.0;

    setState(() {
      quantity = q;
      unitPrice = p;
      total = quantity * unitPrice + e;
      kdvDahilTotal =
          total * (widget.product.kdvOrani / 100) + total; // %20 KDV
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  final TextEditingController unitPriceController = TextEditingController();

  Future<void> _submitOrder() async {
    // Validasyonlar
    if (quantity <= 0) {
      _showSnackBar('Geçerli bir miktar girin', Colors.red);
      return;
    }

    if (quantity > widget.product.stokMiktari) {
      _showSnackBar(
        'Yetersiz stok! Mevcut stok: ${widget.product.stokMiktari}',
        Colors.red,
      );
      return;
    }

    setState(() {
      isLoading = true;
      status = 'Sipariş işleniyor...';
    });

    final orderData = _createOrderData();
    _sendToWebhook(orderData);

    try {
      bool success = false;

      // Önce custom callback'i dene
      if (widget.onOrderSubmit != null) {
        success = await widget.onOrderSubmit!(orderData);
      }

      setState(() {
        isLoading = false;
        status = success
            ? 'Sipariş başarıyla gönderildi!'
            : 'Sipariş gönderilemedi';
      });

      _showSnackBar(
        success ? 'Sipariş başarıyla oluşturuldu!' : 'Sipariş oluşturulamadı',
        success ? Colors.green : Colors.red,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        status = 'Hata oluştu: $e';
      });
      _showSnackBar('Sipariş gönderilirken hata oluştu', Colors.red);
    }
  }

  Map<String, dynamic> _createOrderData() {
    return {
      'product': widget.product.toMap(),
      'miktar': quantity,
      'birimFiyat': unitPrice,
      'toplamTutar': total,
      'kdvDahilToplam': kdvDahilTotal,
      'kdvTutari': widget.product.kdvTutari * quantity,
      'hesaplama':
          '($quantity × $unitPrice ₺)+ $ekHizmet ₺ = ${total.toStringAsFixed(2)} ₺',
      'siparisTarihi': DateTime.now().toIso8601String(),
      'paraBirimi': 'TRY',
      'tedarikci': widget.product.tedarikci,
      'musteri': {'siparisZamani': DateTime.now().toIso8601String()},
      'Alici': Alici.text,
      'Ek_hizmet': ekHizmet.text,
    };
  }

  Future<bool> _sendToWebhook(Map<String, dynamic> orderData) async {
    try {
      String webhook =
          "https://n8n.hggrup.com/webhook/480813dc-3ee8-4b66-9475-efbbba553484";
      final response = await http.post(
        Uri.parse(webhook),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customTitle ?? 'Ürün Satış'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Durum göstergesi
              if (status.isNotEmpty) _buildStatusCard(),

              const SizedBox(height: 16),

              // Ürün bilgileri kartı
              _buildProductInfoCard(),

              const SizedBox(height: 16),

              // Sipariş hesaplama kartı
              _buildOrderCalculationCard(),

              const SizedBox(height: 16),

              // Webhook kartı (isteğe bağlı)
              if (widget.showWebhookInput) _buildWebhookCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: status.contains('hata') || status.contains('gönderilemedi')
          ? Colors.red.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              status.contains('hata') || status.contains('gönderilemedi')
                  ? Icons.error
                  : Icons.info,
              color: status.contains('hata') || status.contains('gönderilemedi')
                  ? Colors.red
                  : Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(status)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Ürün Bilgileri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Ürün resmi (varsa)
            if (widget.product.birim.isNotEmpty)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.product.birim),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Ürün adı ve barkod
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.urunAdi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.product.kisaAciklama != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.product.kisaAciklama!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Barkod: ${widget.product.barkod}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detay bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Kategori',
                    widget.product.kategori,
                    Icons.category,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    'Marka',
                    widget.product.marka,
                    Icons.business,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Tedarikçi',
                    widget.product.tedarikci,
                    Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    'Birim',
                    widget.product.birim,
                    Icons.scale,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Fiyat bilgileri
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Birim Fiyat:'),
                      Text(
                        '${widget.product.toptanFiyat!.toStringAsFixed(3)} ₺',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KDV Dahil:'),
                      Text(
                        '${(unitPrice * (1 + (widget.product.kdvOrani / 100))).toStringAsFixed(4)} ₺',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KDV Oranı:'),
                      Text('%${widget.product.kdvOrani.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stok bilgisi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.product.isLowStock
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.product.isLowStock
                      ? Colors.red.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.product.isLowStock
                        ? Icons.warning
                        : Icons.inventory_2,
                    color: widget.product.isLowStock ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text('Stok: ${widget.product.stokMiktari} Adt'),
                  if (widget.product.isLowStock) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'DÜŞÜK STOK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCalculationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Sipariş Hesaplama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Miktar girişi
            Row(
              children: [
                const Text(
                  'Miktar:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixText: "Adt",
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Birim fiyat girişi
            Row(
              children: [
                const Text(
                  'Birim Fiyat:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: unitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixText: "₺",
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hesaplama gösterimi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(' × ', style: TextStyle(fontSize: 20)),
                      Text(
                        '${unitPrice.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(' = ', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${total.toStringAsFixed(4)} ₺',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KDV Dahil: ${kdvDahilTotal.toStringAsFixed(4)} ₺',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebhookCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.webhook, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Satış Gönderme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: Alici,
              decoration: const InputDecoration(
                labelText: 'Firma Bilgisi',
                hintText: 'Alıcı firma/Kişi Bilgisi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ekHizmet,
              decoration: const InputDecoration(
                labelText: 'Ek Hizmet',
                hintText: 'Ek Hizmet İçin eklenen ücreti temsil eder',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submitOrder,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(isLoading ? 'Gönderiliyor...' : 'Siparişi Onayla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
