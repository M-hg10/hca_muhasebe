import 'package:flutter/material.dart';
import 'package:hcastick/ayarlar/info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class alisform extends StatefulWidget {
  const alisform({super.key});

  @override
  State<alisform> createState() => _alisformState();
}

class _alisformState extends State<alisform> {
  // 🔽 Sabit listeler (sonradan DB'den çekilebilir)
  final List<String> urunListesi = ['Klişe', 'Sticker', 'Etiket'];
  final List<String> firmaListesi = ['Kalibre', 'HCA', 'BaskıJet'];

  String? secilenUrun;
  String? secilenFirma;

  final TextEditingController tutarController = TextEditingController();
  final TextEditingController miktarController = TextEditingController();
  final TextEditingController ekHizmetController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();
  final webhookalis = hcawebhook();
  late double birimFiyat = 0;

  @override
  void initState() {
    super.initState();

    tutarController.addListener(_birimFiyatHesapla);
    miktarController.addListener(_birimFiyatHesapla);
  }

  void _birimFiyatHesapla() {
    double tutar = double.tryParse(tutarController.text) ?? 0;
    int miktar = int.tryParse(miktarController.text) ?? 0;

    setState(() {
      if (miktar > 0) {
        birimFiyat = tutar / miktar;
      } else {
        birimFiyat = 0;
      }
    });
  }

  Future<void> veriGonder() async {
    final Map<String, dynamic> veri = {
      "Ürün Adı": secilenUrun,
      "Firma Adı": secilenFirma,
      "Ödenen tutar": double.tryParse(tutarController.text) ?? 0,
      "Miktar": int.tryParse(miktarController.text) ?? 0,
      "Ek Hizmet": double.tryParse(ekHizmetController.text) ?? 0,
      "Açıklama": aciklamaController.text,
      "submittedAt": DateTime.now().toIso8601String(),
      "formMode": "test",
    };

    final response = await http.post(
      Uri.parse(webhookalis.tahsilatformu),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode([veri]), // 📦 Liste olarak gönderiyoruz
    );

    if (response.statusCode == 200) {
      // 🟢 Başarılı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Veri başarıyla gönderildi.")),
      );
    } else {
      // 🔴 Hata
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Hata oluştu: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📤 Ürün Alım Formu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "🧾 Ürün Adı"),
              value: secilenUrun,
              items: urunListesi.map((urun) {
                return DropdownMenuItem(value: urun, child: Text(urun));
              }).toList(),
              onChanged: (deger) => setState(() => secilenUrun = deger),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "🏢 Firma Adı"),
              value: secilenFirma,
              items: firmaListesi.map((firma) {
                return DropdownMenuItem(value: firma, child: Text(firma));
              }).toList(),
              onChanged: (deger) => setState(() => secilenFirma = deger),
            ),
            SizedBox(height: 10),
            Card(
              child: Text(
                "🔹 Birim Fiyat: ${birimFiyat.toStringAsFixed(2)} ₺",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 247, 89, 3),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: tutarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "💸 Ödenen Tutar"),
            ),
            TextField(
              controller: miktarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "📦 Miktar"),
            ),
            TextField(
              controller: ekHizmetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "➕ Ek Hizmet"),
            ),
            TextField(
              controller: aciklamaController,
              decoration: const InputDecoration(labelText: "📝 Açıklama"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: veriGonder,
              icon: const Icon(Icons.send),
              label: const Text("Alış Formunu Gönder"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
