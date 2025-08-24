import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductionCalculatorPage extends StatefulWidget {
  @override
  _ProductionCalculatorPageState createState() =>
      _ProductionCalculatorPageState();
}

class _ProductionCalculatorPageState extends State<ProductionCalculatorPage> {
  // Webhook parametreleri
  Map<String, dynamic> parameters = {};
  bool parametersLoaded = false;

  // Form controllers
  final TextEditingController _baskiliAmbalajMiktarController =
      TextEditingController();
  final TextEditingController _gramajController = TextEditingController();
  final TextEditingController _adetController = TextEditingController();

  // Hammadde kg fiyatları (manuel giriş)
  final TextEditingController _sekerFiyatController = TextEditingController();
  final TextEditingController _karabiberFiyatController =
      TextEditingController();
  final TextEditingController _pulbiberFiyatController =
      TextEditingController();
  final TextEditingController _kekikFiyatController = TextEditingController();

  // Hammadde miktarları (gram cinsinden - reçete)
  final TextEditingController _sekerMiktarController = TextEditingController(
    text: "0",
  );
  final TextEditingController _karabiberMiktarController =
      TextEditingController(text: "0");
  final TextEditingController _pulbiberMiktarController = TextEditingController(
    text: "0",
  );
  final TextEditingController _kekikMiktarController = TextEditingController(
    text: "0",
  );

  // Hesaplama sonuçları
  double baskiliAmbalajMaliyeti = 0;
  double hammaddeMaliyeti = 0;
  double toplamMaliyet = 0;
  double birimFiyat = 0;
  double toplamTutar = 0;

  static const String webhookUrl =
      'https://n8n.hggrup.com/webhook/ea6324b6-9112-48e5-82be-6b3dc1479705';

  @override
  void initState() {
    super.initState();
    loadParametersFromWebhook();
  }

  Future<void> loadParametersFromWebhook() async {
    try {
      final response = await http.get(Uri.parse(webhookUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Parametreleri map'e çevir
        for (var item in data) {
          parameters[item['ad']] = double.tryParse(item['deger']) ?? 0.0;
        }

        setState(() {
          parametersLoaded = true;
          // Manuel fiyat alanlarını webhook değerleriyle doldur
          _sekerFiyatController.text = (parameters['seker'] ?? 38).toString();
          _karabiberFiyatController.text = (parameters['karabiber'] ?? 345)
              .toString();
          _pulbiberFiyatController.text = (parameters['pulbiber'] ?? 245)
              .toString();
          _kekikFiyatController.text = (parameters['kekik '] ?? 345).toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Parametreler yüklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Fallback parametreler
      parameters = {
        'kdv_orani': 0.20,
        'asgari_ucret': 17002,
        'baskılı_ambalaj': 134,
        'iscilik_orani': 0.25,
        'fire': 0.03,
        'net_kar': 0.25,
        'elektrik': 0.01,
        'seker': 38,
        'karabiber': 345,
        'pulbiber': 245,
        'kekik ': 345,
        'sinir_br_fiyat': 0.21,
        'baskılı_min_ambalaj': 10,
      };
      setState(() {
        parametersLoaded = true;
        // Manuel fiyat alanlarını fallback değerlerle doldur
        _sekerFiyatController.text = (parameters['seker'] ?? 38).toString();
        _karabiberFiyatController.text = (parameters['karabiber'] ?? 345)
            .toString();
        _pulbiberFiyatController.text = (parameters['pulbiber'] ?? 245)
            .toString();
        _kekikFiyatController.text = (parameters['kekik '] ?? 345).toString();
      });
    }
  }

  void hesapla() {
    if (!parametersLoaded) return;

    double baskiliAmbalajMiktar =
        double.tryParse(_baskiliAmbalajMiktarController.text) ?? 0;
    double gramaj = double.tryParse(_gramajController.text) ?? 0;
    double adet = double.tryParse(_adetController.text) ?? 0;

    // Manuel girilen fiyatları al
    double sekerFiyat = double.tryParse(_sekerFiyatController.text) ?? 0;
    double karabiberFiyat =
        double.tryParse(_karabiberFiyatController.text) ?? 0;
    double pulbiberFiyat = double.tryParse(_pulbiberFiyatController.text) ?? 0;
    double kekikFiyat = double.tryParse(_kekikFiyatController.text) ?? 0;

    // Hammadde miktarları (gram)
    double sekerMiktar = double.tryParse(_sekerMiktarController.text) ?? 0;
    double karabiberMiktar =
        double.tryParse(_karabiberMiktarController.text) ?? 0;
    double pulbiberMiktar =
        double.tryParse(_pulbiberMiktarController.text) ?? 0;
    double kekikMiktar = double.tryParse(_kekikMiktarController.text) ?? 0;

    if (adet <= 0) return;

    // 1. Baskılı ambalaj maliyeti
    double minAmbalaj = parameters['baskılı_min_ambalaj'] ?? 10;
    double ambalajBirimFiyat = parameters['baskılı_ambalaj'] ?? 134;

    // Minimum miktar kontrolü
    double kullanilacakAmbalaj = baskiliAmbalajMiktar > minAmbalaj
        ? baskiliAmbalajMiktar
        : minAmbalaj;
    baskiliAmbalajMaliyeti = kullanilacakAmbalaj * ambalajBirimFiyat;

    // 2. Hammadde maliyeti (toplam gramaj için)
    double toplamGramaj = adet;
    double toplamSekerMaliyet =
        (toplamGramaj * sekerMiktar / 1000) * sekerFiyat;
    double toplamKarabiberMaliyet =
        (toplamGramaj * karabiberMiktar / 1000) * karabiberFiyat;
    double toplamPulbiberMaliyet =
        (toplamGramaj * pulbiberMiktar / 1000) * pulbiberFiyat;
    double toplamKekikMaliyet =
        (toplamGramaj * kekikMiktar / 1000) * kekikFiyat;

    hammaddeMaliyeti =
        toplamSekerMaliyet +
        toplamKarabiberMaliyet +
        toplamPulbiberMaliyet +
        toplamKekikMaliyet;

    // Fire hesabı
    double fireOrani = parameters['fire'] ?? 0.03;
    hammaddeMaliyeti = hammaddeMaliyeti * (1 + fireOrani);

    // 3. Temel maliyet (ambalaj + hammadde)
    double temelMaliyet = baskiliAmbalajMaliyeti + hammaddeMaliyeti;

    // 4. Genel giderler
    double iscilikOrani = parameters['iscilik_orani'] ?? 0.25;
    double elektrikOrani = parameters['elektrik'] ?? 0.01;
    double netKarOrani = parameters['net_kar'] ?? 0.25;

    double iscilikGideri = temelMaliyet * iscilikOrani;
    double elektrikGideri = temelMaliyet * elektrikOrani;
    double karMiktari = temelMaliyet * netKarOrani;

    // 5. Toplam maliyet
    toplamMaliyet = temelMaliyet + iscilikGideri + elektrikGideri + karMiktari;

    // 6. KDV dahil hesap
    double kdvOrani = parameters['kdv_orani'] ?? 0.20;
    double kdvDahilToplam = toplamMaliyet * (1 + kdvOrani);

    // 7. Birim fiyat ve toplam tutar
    birimFiyat = kdvDahilToplam / adet;
    toplamTutar = kdvDahilToplam;

    // Sınır fiyat kontrolü
    double sinirFiyat = parameters['sinir_br_fiyat'] ?? 0.21;
    if (birimFiyat < sinirFiyat) {
      // Karı arttır
      double eklenenKar = (sinirFiyat - birimFiyat) * adet;
      toplamTutar += eklenenKar;
      birimFiyat = sinirFiyat;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Üretim Maliyet Hesaplama'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: !parametersLoaded
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sipariş bilgileri
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 Sipariş Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _gramajController,
                                  decoration: InputDecoration(
                                    labelText: 'Paket Gramajı',
                                    suffixText: 'gr',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _adetController,
                                  decoration: InputDecoration(
                                    labelText: 'İstenen Adet',
                                    suffixText: 'adet',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _baskiliAmbalajMiktarController,
                            decoration: InputDecoration(
                              labelText: 'Baskılı Ambalaj Miktarı',
                              suffixText: 'kg',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Min: ${parameters['baskılı_min_ambalaj']} kg',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => hesapla(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Hammadde reçetesi
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🌿 Hammadde Reçetesi ve Fiyatları',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Şeker
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _sekerFiyatController,
                                  decoration: InputDecoration(
                                    labelText: 'Şeker Kg Fiyatı',
                                    suffixText: '₺/kg',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _sekerMiktarController,
                                  decoration: InputDecoration(
                                    labelText: 'Miktar',
                                    suffixText: 'gr',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Webhook',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '${(parameters['seker'] ?? 0).toStringAsFixed(0)}₺',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Karabiber
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _karabiberFiyatController,
                                  decoration: InputDecoration(
                                    labelText: 'Karabiber Kg Fiyatı',
                                    suffixText: '₺/kg',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _karabiberMiktarController,
                                  decoration: InputDecoration(
                                    labelText: 'Miktar',
                                    suffixText: 'gr',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Webhook',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '${(parameters['karabiber'] ?? 0).toStringAsFixed(0)}₺',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Pul Biber
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _pulbiberFiyatController,
                                  decoration: InputDecoration(
                                    labelText: 'Pul Biber Kg Fiyatı',
                                    suffixText: '₺/kg',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _pulbiberMiktarController,
                                  decoration: InputDecoration(
                                    labelText: 'Miktar',
                                    suffixText: 'gr',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Webhook',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '${(parameters['pulbiber'] ?? 0).toStringAsFixed(0)}₺',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Kekik
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _kekikFiyatController,
                                  decoration: InputDecoration(
                                    labelText: 'Kekik Kg Fiyatı',
                                    suffixText: '₺/kg',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _kekikMiktarController,
                                  decoration: InputDecoration(
                                    labelText: 'Miktar',
                                    suffixText: 'gr',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => hesapla(),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Webhook',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '${(parameters['kekik '] ?? 0).toStringAsFixed(0)}₺',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Maliyet hesabı
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💰 Maliyet Dağılımı',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildMaliyetSatiri(
                            '📦 Baskılı Ambalaj',
                            baskiliAmbalajMaliyeti,
                          ),
                          _buildMaliyetSatiri(
                            '🌿 Hammadde (Fire Dahil)',
                            hammaddeMaliyeti,
                          ),
                          _buildMaliyetSatiri(
                            '👷 İşçilik (%${((parameters['iscilik_orani'] ?? 0) * 100).toStringAsFixed(0)})',
                            (baskiliAmbalajMaliyeti + hammaddeMaliyeti) *
                                (parameters['iscilik_orani'] ?? 0),
                          ),
                          _buildMaliyetSatiri(
                            '⚡ Elektrik (%${((parameters['elektrik'] ?? 0) * 100).toStringAsFixed(0)})',
                            (baskiliAmbalajMaliyeti + hammaddeMaliyeti) *
                                (parameters['elektrik'] ?? 0),
                          ),
                          _buildMaliyetSatiri(
                            '📈 Kar Marjı (%${((parameters['net_kar'] ?? 0) * 100).toStringAsFixed(0)})',
                            (baskiliAmbalajMaliyeti + hammaddeMaliyeti) *
                                (parameters['net_kar'] ?? 0),
                          ),
                          Divider(thickness: 2),
                          _buildMaliyetSatiri(
                            '💯 KDV Hariç Toplam',
                            toplamMaliyet,
                            bold: true,
                          ),
                          _buildMaliyetSatiri(
                            '🧾 KDV (%${((parameters['kdv_orani'] ?? 0) * 100).toStringAsFixed(0)})',
                            toplamMaliyet * (parameters['kdv_orani'] ?? 0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Sonuç
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '💲 SONUÇ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Birim Fiyat:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${birimFiyat.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam Tutar:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${toplamTutar.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          if (birimFiyat >=
                              (parameters['sinir_br_fiyat'] ?? 0.21))
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⚠️ Sınır fiyat uygulandı',
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMaliyetSatiri(String baslik, double tutar, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            baslik,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${tutar.toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sekerFiyatController.dispose();
    _karabiberFiyatController.dispose();
    _pulbiberFiyatController.dispose();
    _kekikFiyatController.dispose();
    _baskiliAmbalajMiktarController.dispose();
    _gramajController.dispose();
    _adetController.dispose();
    _sekerMiktarController.dispose();
    _karabiberMiktarController.dispose();
    _pulbiberMiktarController.dispose();
    _kekikMiktarController.dispose();
    super.dispose();
  }
}
