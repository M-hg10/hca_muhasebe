import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcastick/onmuhasebe/urun/urun_api_servis.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FiyatEkleWidget extends StatefulWidget {
  final Urun urun;

  const FiyatEkleWidget({Key? key, required this.urun}) : super(key: key);

  @override
  State<FiyatEkleWidget> createState() => _FiyatEkleWidgetState();
}

class _FiyatEkleWidgetState extends State<FiyatEkleWidget> {
  List<dynamic> fiyatTurleri = [];
  List<dynamic> paraBirimleri = [];

  dynamic seciliFiyatTurId;
  dynamic seciliParaBirimiId;

  TextEditingController fiyatController = TextEditingController();
  DateTime seciliTarih = DateTime.now();
  bool aktifMi = true;

  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    initializeDateFormatting('tr_TR', null);
  }

  Future<void> _verileriYukle() async {
    try {
      var fiyatTurRes = await http.get(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/9cd7e125-45f3-4684-9548-55eebc264f3b",
        ),
      );
      var paraBirimRes = await http.get(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/4d84c22c-38fe-48ff-a6a5-c743a02f59f3",
        ),
      );

      if (fiyatTurRes.statusCode == 200 && paraBirimRes.statusCode == 200) {
        setState(() {
          fiyatTurleri = json.decode(fiyatTurRes.body);
          paraBirimleri = json.decode(paraBirimRes.body);
        });
      }
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
    }
  }

  Future<void> _kaydet() async {
    if (seciliFiyatTurId == null ||
        seciliParaBirimiId == null ||
        fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Tüm alanları doldurun")));
      return;
    }

    setState(() => loading = true);

    try {
      var body = {
        "urun_id": widget.urun.id,
        "fiyat": double.tryParse(fiyatController.text) ?? 0,
        "tarih": DateFormat('yyyy-MM-dd').format(seciliTarih),
        "aktif": aktifMi,
        "para_birimi_id": seciliParaBirimiId,
        "fiyat_tur_id": seciliFiyatTurId,
      };

      var res = await http.post(
        Uri.parse(
          "https://n8n.hggrup.com/webhook/5a3ef498-34bf-48ff-93bd-ffd7e7a3b14b",
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fiyat kaydedildi")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: ${res.statusCode}")));
      }
    } catch (e) {
      debugPrint("Kaydetme hatası: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.urun.isim} - Fiyat Ekle"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Fiyat kaydediliyor...", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün Bilgi Kartı
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Ürün Görseli
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child:
                                  widget.urun.anaresim != null &&
                                      widget.urun.anaresim!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        widget.urun.anaresim!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey[400],
                                              );
                                            },
                                      ),
                                    )
                                  : Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                            ),
                            SizedBox(width: 16),
                            // Ürün Bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.urun.isim,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  if (widget.urun.kategoriAdi != null)
                                    Text(
                                      "Kategori: ${widget.urun.kategoriAdi}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (widget.urun.marka != null)
                                    Text(
                                      "Marka: ${widget.urun.marka}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Fiyat Bilgileri Başlığı
                    Text(
                      "Fiyat Bilgileri",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Fiyat Türü Dropdown
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: "Fiyat Türü",
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: seciliFiyatTurId,
                        items: fiyatTurleri.map<DropdownMenuItem>((item) {
                          return DropdownMenuItem(
                            value: item["id"],
                            child: Text(item["ad"] ?? "İsimsiz"),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => seciliFiyatTurId = value),
                        validator: (value) {
                          if (value == null) return "Fiyat türü seçiniz";
                          return null;
                        },
                      ),
                    ),

                    // Para Birimi ve Fiyat Satırı
                    Row(
                      children: [
                        // Para Birimi
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Para Birimi",
                                prefixIcon: Icon(Icons.currency_exchange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              value: seciliParaBirimiId,
                              items: paraBirimleri.map<DropdownMenuItem>((
                                item,
                              ) {
                                return DropdownMenuItem(
                                  value: item["id"],
                                  child: Row(
                                    children: [
                                      Text(item["simge"] ?? ""),
                                      SizedBox(width: 8),
                                      Text(item["birim_adi"] ?? "İsimsiz"),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => seciliParaBirimiId = value),
                              validator: (value) {
                                if (value == null) return "Para birimi seçiniz";
                                return null;
                              },
                            ),
                          ),
                        ),
                        // Fiyat
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            child: TextFormField(
                              controller: fiyatController,
                              decoration: InputDecoration(
                                labelText: "Fiyat",
                                prefixIcon: Icon(
                                  Icons.monetization_on_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: "0.00",
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Fiyat giriniz";
                                }
                                if (double.tryParse(value) == null) {
                                  return "Geçerli fiyat giriniz";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Aktiflik Durumu
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SwitchListTile(
                        title: Text(
                          "Aktif Fiyat",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          aktifMi
                              ? "Bu fiyat aktif olarak kullanılacak"
                              : "Bu fiyat pasif olarak kaydedilecek",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: aktifMi,
                        onChanged: (val) => setState(() => aktifMi = val),
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.grey[50],
                      ),
                    ),

                    // Kaydet Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _kaydet();
                          }
                        },
                        icon: Icon(Icons.save_outlined, size: 20),
                        label: Text(
                          "Fiyatı Kaydet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bilgi Notu
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Aktif fiyatlar ürün listesinde görüntülenir. Pasif fiyatlar sadece fiyat geçmişinde saklanır.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
