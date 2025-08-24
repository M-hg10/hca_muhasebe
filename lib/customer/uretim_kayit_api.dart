import 'dart:convert';
import 'package:hcastick/customer/referanslar.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.hggrup.com';

  // ==========================
  // ÜRETİM KAYIT ENDPOINTLERİ
  // ==========================

  /// 🔽 Tüm Üretim Kayıtlarını Getir
  static Future<List<ProductionModel>> getProductions() async {
    final response = await http.get(Uri.parse('$baseUrl/uretim'));

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => ProductionModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Üretim kayıtları alınamadı. Kod: ${response.statusCode}',
      );
    }
  }

  /// 🔼 Yeni Üretim Kaydı Oluştur (isteğe bağlı kullanılabilir)
  static Future<void> createProduction(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uretim'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Üretim kaydı oluşturulamadı. Kod: ${response.statusCode}',
      );
    }
  }

  /// 🔁 Üretim Kaydı Güncelle
  static Future<void> updateProduction(
    int id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/uretim/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Güncelleme başarısız. Kod: ${response.statusCode}');
    }
  }

  /// ❌ Üretim Kaydı Sil
  static Future<void> deleteProduction(int id) async {
    final url = Uri.parse('$baseUrl/uretim/$id');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Silme başarısız. Kod: ${response.statusCode}');
    }
  }

  // ==========================
  // ÜRETİM TAKİP ENDPOINTLERİ
  // ==========================

  /// 🔽 Belirli Üretim ID’sine Ait Takip Kayıtlarını Getir
  static Future<List<UretimTakipModel>> getTakipByUretimId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/uretim-takip/$id'));

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => UretimTakipModel.fromJson(e)).toList();
    } else {
      throw Exception('Takip kayıtları alınamadı. Kod: ${response.statusCode}');
    }
  }

  /// 🔼 Yeni Takip Kaydı Oluştur
  static Future<void> createTakip(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uretim-takip'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Takip kaydı oluşturulamadı. Kod: ${response.statusCode}',
      );
    }
  }

  /// 🔁 Takip Kaydı Güncelle
  static Future<void> updateTakip(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/uretim-takip/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Takip güncellemesi başarısız. Kod: ${response.statusCode}',
      );
    }
  }

  /// ❌ Takip Kaydı Sil
  static Future<void> deleteTakip(int id) async {
    final url = Uri.parse('$baseUrl/uretim-takip/$id');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Takip kaydı silinemedi. Kod: ${response.statusCode}');
    }
  }

  /// 🔍 Tekil Takip Kaydını Getir
  static Future<UretimTakipModel> getTakipById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/uretim-takip/$id'));

    if (response.statusCode == 200) {
      return UretimTakipModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Takip kaydı alınamadı. Kod: ${response.statusCode}');
    }
  }
}
