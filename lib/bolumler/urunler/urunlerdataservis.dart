import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int urunId;
  final String barkod;
  final String urunAdi;
  final String kategori;
  final String marka;
  final String tedarikci;
  final String birim;
  final double birimFiyat;
  final double alisFiyati;
  final double kdvOrani;
  final int stokMiktari;
  final int kritikStokMiktari;
  final bool aktif;
  final DateTime olusturmaTarihi;
  final DateTime guncellemeTarihi;
  final String? aciklama;
  final double? toptanFiyat;
  final double? perakendeFiyat;
  final String? kisaAciklama;

  Product({
    required this.urunId,
    required this.barkod,
    required this.urunAdi,
    required this.kategori,
    required this.marka,
    required this.tedarikci,
    required this.birim,
    required this.birimFiyat,
    required this.alisFiyati,
    required this.kdvOrani,
    required this.stokMiktari,
    required this.kritikStokMiktari,
    required this.aktif,
    required this.olusturmaTarihi,
    required this.guncellemeTarihi,
    this.aciklama,
    this.toptanFiyat,
    this.perakendeFiyat,
    this.kisaAciklama,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      urunId: map['urun_id'] ?? 0,
      barkod: map['barkod'] ?? '',
      urunAdi: map['urun_adi'] ?? '',
      kategori: map['kategori'] ?? '',
      marka: map['marka'] ?? '',
      tedarikci: map['tedarikci'] ?? '',
      birim: map['birim'] ?? '',
      birimFiyat: _parseDouble(map['birim_fiyat']),
      alisFiyati: _parseDouble(map['alis_fiyati']),
      kdvOrani: _parseDouble(map['kdv_orani']),
      stokMiktari: map['stok_miktari'] ?? 0,
      kritikStokMiktari: map['kritik_stok_miktari'] ?? 0,
      aktif: map['aktif'] ?? true,
      olusturmaTarihi: _parseDateTime(map['olusturma_tarihi']),
      guncellemeTarihi: _parseDateTime(map['guncelleme_tarihi']),
      aciklama: map['aciklama'],
      toptanFiyat: map['toptan_fiyat'] != null
          ? _parseDouble(map['toptan_fiyat'])
          : null,
      perakendeFiyat: map['perakende_fiyat'] != null
          ? _parseDouble(map['perakende_fiyat'])
          : null,
      kisaAciklama: map['kisa_aciklama'],
    );
  }

  // Normal map (tüm alanlar dahil)
  Map<String, dynamic> toMap() {
    return {
      'urun_id': urunId,
      'barkod': barkod,
      'urun_adi': urunAdi,
      'kategori': kategori,
      'marka': marka,
      'tedarikci': tedarikci,
      'birim': birim,
      'birim_fiyat': birimFiyat.toStringAsFixed(2),
      'alis_fiyati': alisFiyati.toStringAsFixed(2),
      'kdv_orani': kdvOrani.toStringAsFixed(2),
      'stok_miktari': stokMiktari,
      'kritik_stok_miktari': kritikStokMiktari,
      'aktif': aktif,
      'olusturma_tarihi': olusturmaTarihi.toIso8601String(),
      'guncelleme_tarihi': guncellemeTarihi.toIso8601String(),
      'aciklama': aciklama,
      'toptan_fiyat': toptanFiyat?.toStringAsFixed(2),
      'perakende_fiyat': perakendeFiyat?.toStringAsFixed(2),
      'kisa_aciklama': kisaAciklama,
    };
  }

  // API'ye göndermek için özel map (ID ve tarih alanları hariç)
  Map<String, dynamic> toMapForApi() {
    return {
      'barkod': barkod,
      'urun_adi': urunAdi,
      'kategori': kategori,
      'marka': marka,
      'tedarikci': tedarikci,
      'birim': birim,
      'birim_fiyat': birimFiyat,
      'alis_fiyati': alisFiyati,
      'kdv_orani': kdvOrani,
      'stok_miktari': stokMiktari,
      'kritik_stok_miktari': kritikStokMiktari,
      'aktif': aktif,
      'aciklama': aciklama,
      'toptan_fiyat': toptanFiyat,
      'perakende_fiyat': perakendeFiyat,
      'kisa_aciklama': kisaAciklama,
    };
  }

  // Güvenli double parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Güvenli DateTime parsing
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Yeni ürün oluşturmak için factory constructor
  factory Product.create({
    required String barkod,
    required String urunAdi,
    required String kategori,
    required String marka,
    required String tedarikci,
    required String birim,
    required double birimFiyat,
    required double alisFiyati,
    required double kdvOrani,
    required int stokMiktari,
    required int kritikStokMiktari,
    bool aktif = true,
    String? aciklama,
    double? toptanFiyat,
    double? perakendeFiyat,
    String? kisaAciklama,
  }) {
    return Product(
      urunId: 0, // Yeni ürün için 0
      barkod: barkod,
      urunAdi: urunAdi,
      kategori: kategori,
      marka: marka,
      tedarikci: tedarikci,
      birim: birim,
      birimFiyat: birimFiyat,
      alisFiyati: alisFiyati,
      kdvOrani: kdvOrani,
      stokMiktari: stokMiktari,
      kritikStokMiktari: kritikStokMiktari,
      aktif: aktif,
      olusturmaTarihi: DateTime.now(),
      guncellemeTarihi: DateTime.now(),
      aciklama: aciklama,
      toptanFiyat: toptanFiyat,
      perakendeFiyat: perakendeFiyat,
      kisaAciklama: kisaAciklama,
    );
  }

  // copyWith metodu (güncelleme için)
  Product copyWith({
    int? urunId,
    String? barkod,
    String? urunAdi,
    String? kategori,
    String? marka,
    String? tedarikci,
    String? birim,
    double? birimFiyat,
    double? alisFiyati,
    double? kdvOrani,
    int? stokMiktari,
    int? kritikStokMiktari,
    bool? aktif,
    DateTime? olusturmaTarihi,
    DateTime? guncellemeTarihi,
    String? aciklama,
    double? toptanFiyat,
    double? perakendeFiyat,
    String? kisaAciklama,
  }) {
    return Product(
      urunId: urunId ?? this.urunId,
      barkod: barkod ?? this.barkod,
      urunAdi: urunAdi ?? this.urunAdi,
      kategori: kategori ?? this.kategori,
      marka: marka ?? this.marka,
      tedarikci: tedarikci ?? this.tedarikci,
      birim: birim ?? this.birim,
      birimFiyat: birimFiyat ?? this.birimFiyat,
      alisFiyati: alisFiyati ?? this.alisFiyati,
      kdvOrani: kdvOrani ?? this.kdvOrani,
      stokMiktari: stokMiktari ?? this.stokMiktari,
      kritikStokMiktari: kritikStokMiktari ?? this.kritikStokMiktari,
      aktif: aktif ?? this.aktif,
      olusturmaTarihi: olusturmaTarihi ?? this.olusturmaTarihi,
      guncellemeTarihi: guncellemeTarihi ?? DateTime.now(),
      aciklama: aciklama ?? this.aciklama,
      toptanFiyat: toptanFiyat ?? this.toptanFiyat,
      perakendeFiyat: perakendeFiyat ?? this.perakendeFiyat,
      kisaAciklama: kisaAciklama ?? this.kisaAciklama,
    );
  }

  // toString metodu (debug için)
  @override
  String toString() {
    return 'Product(urunId: $urunId, urunAdi: $urunAdi, kategori: $kategori, marka: $marka)';
  }

  // Equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.urunId == urunId;
  }

  // KDV dahil fiyat hesaplama
  double get kdvDahilFiyat => toptanFiyat! * (1 + kdvOrani / 100);

  // Düşük stok kontrolü
  bool get isLowStock => stokMiktari <= kritikStokMiktari;

  // KDV tutarı
  double get kdvTutari => toptanFiyat! * (kdvOrani / 100);

  @override
  int get hashCode => urunId.hashCode;

  // Kar marjı hesaplama (%)
  double get karMarji {
    if (alisFiyati == 0) return 0;
    return ((birimFiyat - alisFiyati) / alisFiyati) * 100;
  }
}

class DatabaseService {
  final String baseUrl = 'https://api.hggrup.com/urunler';

  // Tüm ürünleri getir (kategori filtrelemeli)
  Future<List<Product>> getProductsFromApi({String? kategori}) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<Product> allProducts = data
            .map((item) => Product.fromMap(item))
            .toList();

        if (kategori != null) {
          return allProducts.where((p) => p.kategori == kategori).toList();
        }

        return allProducts;
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('API\'dan ürün çekme hatası: $e');
      rethrow;
    }
  }

  // ID ile tek ürün getir
  Future<Product> getProductById(int urunId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$urunId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromMap(data);
      } else {
        throw Exception('Ürün getirme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Ürün getirme hatası: $e');
      rethrow;
    }
  }

  // Yeni ürün ekle
  Future<Product> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toMapForApi()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromMap(data);
      } else {
        throw Exception(
          'Ürün ekleme hatası: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Ürün ekleme hatası: $e');
      rethrow;
    }
  }

  // Ürün güncelle
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${product.urunId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(product.toMapForApi()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromMap(data);
      } else {
        throw Exception(
          'Ürün güncelleme hatası: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Ürün güncelleme hatası: $e');
      rethrow;
    }
  }

  // Ürün sil
  Future<void> deleteProduct(int urunId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$urunId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Ürün silme hatası: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Ürün silme hatası: $e');
      rethrow;
    }
  }

  // Kategori listesini getir (unique kategoriler)
  Future<List<String>> getCategories() async {
    try {
      final products = await getProductsFromApi();
      final categories = products.map((p) => p.kategori).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      print('Kategori listesi alma hatası: $e');
      rethrow;
    }
  }

  // Kritik stok seviyesindeki ürünleri getir
  Future<List<Product>> getCriticalStockProducts() async {
    try {
      final products = await getProductsFromApi();
      return products
          .where((p) => p.stokMiktari <= p.kritikStokMiktari)
          .toList();
    } catch (e) {
      print('Kritik stok ürünleri alma hatası: $e');
      rethrow;
    }
  }

  // Aktif ürünleri getir
  Future<List<Product>> getActiveProducts({String? kategori}) async {
    try {
      final products = await getProductsFromApi(kategori: kategori);
      return products.where((p) => p.aktif).toList();
    } catch (e) {
      print('Aktif ürünler alma hatası: $e');
      rethrow;
    }
  }

  // Barkod ile ürün ara
  Future<Product?> getProductByBarcode(String barkod) async {
    try {
      final products = await getProductsFromApi();
      final product = products.where((p) => p.barkod == barkod).firstOrNull;
      return product;
    } catch (e) {
      print('Barkod ile ürün arama hatası: $e');
      rethrow;
    }
  }

  // Ürün adı ile arama (fuzzy search)
  Future<List<Product>> searchProductsByName(String query) async {
    try {
      final products = await getProductsFromApi();
      return products
          .where((p) => p.urunAdi.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Ürün adı ile arama hatası: $e');
      rethrow;
    }
  }

  // Marka ile arama
  Future<List<Product>> getProductsByBrand(String marka) async {
    try {
      final products = await getProductsFromApi();
      return products
          .where((p) => p.marka.toLowerCase() == marka.toLowerCase())
          .toList();
    } catch (e) {
      print('Marka ile ürün arama hatası: $e');
      rethrow;
    }
  }

  // Tedarikçi ile arama
  Future<List<Product>> getProductsBySupplier(String tedarikci) async {
    try {
      final products = await getProductsFromApi();
      return products
          .where((p) => p.tedarikci.toLowerCase() == tedarikci.toLowerCase())
          .toList();
    } catch (e) {
      print('Tedarikçi ile ürün arama hatası: $e');
      rethrow;
    }
  }

  // Fiyat aralığına göre ürün getir
  Future<List<Product>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final products = await getProductsFromApi();
      return products
          .where((p) => p.birimFiyat >= minPrice && p.birimFiyat <= maxPrice)
          .toList();
    } catch (e) {
      print('Fiyat aralığı ile ürün arama hatası: $e');
      rethrow;
    }
  }
}
