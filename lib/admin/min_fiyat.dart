import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WebhookDataPage extends StatefulWidget {
  @override
  _WebhookDataPageState createState() => _WebhookDataPageState();
}

class _WebhookDataPageState extends State<WebhookDataPage> {
  List<Map<String, dynamic>> parameterList = [];
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  static const String webhookUrl =
      'https://n8n.hggrup.com/webhook/ea6324b6-9112-48e5-82be-6b3dc1479705';

  @override
  void initState() {
    super.initState();
    loadDataFromWebhook();
  }

  Future<void> loadDataFromWebhook() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(webhookUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          parameterList = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Veriler webhook\'tan yüklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Webhook\'tan veri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Hata durumunda örnek veriyi yükle
      loadFallbackData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Webhook bağlantısı başarısız, örnek veriler yüklendi',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void loadFallbackData() {
    // Webhook bağlantı hatası durumunda fallback data
    parameterList = [
      {"ad": "kdv_orani", "deger": "0.20", "aciklama": "KDV oranı %20"},
      {
        "ad": "asgari_ucret",
        "deger": "17002",
        "aciklama": "2025 yılı asgari ücret (brüt TL)",
      },
      {
        "ad": "baskılı_ambalaj",
        "deger": "134",
        "aciklama": "Özel baskılı ambalaj kg ucreti",
      },
      {"ad": "iscilik_orani", "deger": "0.25", "aciklama": "işcilik oranı"},
      {
        "ad": "fire",
        "deger": "0.03",
        "aciklama": "başlama asamasındaki fire oranı",
      },
      {
        "ad": "net_kar",
        "deger": "0.25",
        "aciklama": "giderler çıktıktan sonraki kar",
      },
      {"ad": "elektrik", "deger": "0.01", "aciklama": "elektrik gideri"},
      {"ad": "seker", "deger": "38", "aciklama": "guncel seker oranı"},
      {
        "ad": "karabiber",
        "deger": "345",
        "aciklama": "güncel ham madde fiyatı",
      },
      {"ad": "pulbiber", "deger": "245", "aciklama": "güncel ham madde fiyatı"},
      {
        "ad": "kekik ",
        "deger": "345",
        "aciklama": "güncel ham madde fiyatımız",
      },
      {
        "ad": "sinir_br_fiyat",
        "deger": "0.21",
        "aciklama": "çıkan sonuç bu değerin altındaysa karı arttırsın",
      },
      {"ad": "baskılı_min_ambalaj", "deger": "10", "aciklama": "kg miktar"},
    ];
  }

  String getCategoryIcon(String paramName) {
    if (paramName.contains('kdv') ||
        paramName.contains('kar') ||
        paramName.contains('orani')) {
      return '📊';
    } else if (paramName.contains('ucret') || paramName.contains('fiyat')) {
      return '💰';
    } else if (paramName.contains('ambalaj')) {
      return '📦';
    } else if (paramName.contains('seker') ||
        paramName.contains('biber') ||
        paramName.contains('kekik')) {
      return '🌿';
    } else if (paramName.contains('elektrik')) {
      return '⚡';
    } else if (paramName.contains('fire')) {
      return '⚠️';
    }
    return '⚙️';
  }

  Color getCategoryColor(String paramName) {
    if (paramName.contains('kdv') ||
        paramName.contains('kar') ||
        paramName.contains('orani')) {
      return Colors.blue;
    } else if (paramName.contains('ucret') || paramName.contains('fiyat')) {
      return Colors.green;
    } else if (paramName.contains('ambalaj')) {
      return Colors.orange;
    } else if (paramName.contains('seker') ||
        paramName.contains('biber') ||
        paramName.contains('kekik')) {
      return Colors.brown;
    } else if (paramName.contains('elektrik')) {
      return Colors.amber;
    } else if (paramName.contains('fire')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(
            "https://n8n.hggrup.com/webhook/406c2799-912c-4d4a-8efa-98044e9c8cc3",
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(parameterList),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Parametreler başarıyla webhook\'a kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Kaydetme başarısız: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Kaydetme hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addNewParameter() {
    showDialog(
      context: context,
      builder: (context) {
        String newAd = '';
        String newDeger = '';
        String newAciklama = '';

        return AlertDialog(
          title: Text('Yeni Parametre Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Parametre Adı'),
                onChanged: (value) => newAd = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Değer'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => newDeger = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Açıklama'),
                onChanged: (value) => newAciklama = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newAd.isNotEmpty && newDeger.isNotEmpty) {
                  setState(() {
                    parameterList.add({
                      'ad': newAd,
                      'deger': newDeger,
                      'aciklama': newAciklama,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maliyet Parametreleri'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Webhook'tan yeniden veri çek
              loadDataFromWebhook();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Üst bilgi kartı
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade100, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.indigo, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistem Parametreleri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        Text(
                          '${parameterList.length} parametre yüklendi',
                          style: TextStyle(color: Colors.indigo.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Liste
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: parameterList.length,
                itemBuilder: (context, index) {
                  final param = parameterList[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: getCategoryColor(
                                    param['ad'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  getCategoryIcon(param['ad']),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      param['ad']
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: getCategoryColor(param['ad']),
                                      ),
                                    ),
                                    if (param['aciklama'].isNotEmpty)
                                      Text(
                                        param['aciklama'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            initialValue: param['deger'],
                            decoration: InputDecoration(
                              labelText: 'Değer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bu alan boş bırakılamaz';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              param['deger'] = value;
                            },
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
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add",
            onPressed: addNewParameter,
            child: Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "save",
            onPressed: isLoading ? null : saveChanges,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.save),
            label: Text(isLoading ? 'Kaydediliyor...' : 'Kaydet'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
