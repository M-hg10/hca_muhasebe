import 'package:flutter/material.dart';
import 'package:hcastick/admin/adminsatis.dart';
import 'package:hcastick/bolumler/urunler/urunlerdataservis.dart';

class AdminProductsPage extends StatefulWidget {
  @override
  _AdminProductsPageState createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _databaseService.getProductsFromApi();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _categories = products.map((p) => p.kategori).toSet().toList();
        _categories.sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Ürünler yüklenirken hata oluştu: $e');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            product.urunAdi.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product.barkod.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.marka.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory =
            _selectedCategory == null || product.kategori == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterProducts();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  void _showProductDialog([Product? product]) {
    showDialog(
      context: context,
      builder: (context) => ProductEditDialog(
        product: product,
        onSave: (updatedProduct) {
          _saveProduct(updatedProduct);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _saveProduct(Product product) async {
    try {
      setState(() {
        _isLoading = true;
      });

      Product savedProduct;

      if (product.urunId == 0) {
        // Yeni ürün ekleme
        savedProduct = await _databaseService.addProduct(product);
        setState(() {
          _products.add(savedProduct);
        });
        _showSuccessMessage('Ürün başarıyla eklendi');
      } else {
        // Mevcut ürünü güncelleme
        savedProduct = await _databaseService.updateProduct(product);
        setState(() {
          final index = _products.indexWhere((p) => p.urunId == product.urunId);
          if (index != -1) {
            _products[index] = savedProduct;
          }
        });
        _showSuccessMessage('Ürün başarıyla güncellendi');
      }

      // Kategorileri güncelle
      _categories = _products.map((p) => p.kategori).toSet().toList();
      _categories.sort();

      _filterProducts();
    } catch (e) {
      _showErrorDialog('Ürün kaydedilirken hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await _showConfirmDialog(
      'Ürün Silme',
      '${product.urunAdi} ürününü silmek istediğinizden emin misiniz?',
    );

    if (confirm) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _databaseService.deleteProduct(product.urunId);

        setState(() {
          _products.removeWhere((p) => p.urunId == product.urunId);
          // Kategorileri güncelle
          _categories = _products.map((p) => p.kategori).toSet().toList();
          _categories.sort();
        });

        _filterProducts();
        _showSuccessMessage('Ürün başarıyla silindi');
      } catch (e) {
        _showErrorDialog('Ürün silinirken hata oluştu: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Evet'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Yönetimi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtre Bölümü
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Arama Çubuğu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ürün adı, barkod veya marka ile ara...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                SizedBox(height: 12),
                // Kategori Filtresi
                Row(
                  children: [
                    Text('Kategori: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text('Tüm Kategoriler'),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tüm Kategoriler'),
                          ),
                          ..._categories.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                        ],
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ürün Listesi
          Expanded(
            child: Stack(
              children: [
                _isLoading && _products.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          _products.isEmpty
                              ? 'Ürün bulunamadı'
                              : 'Arama kriterlerine uygun ürün bulunamadı',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return ProductListItem(
                            product: product,
                            onEdit: () => _showProductDialog(product),
                            onDelete: () => _deleteProduct(product),
                          );
                        },
                      ),
                if (_isLoading && _products.isNotEmpty)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('İşlem yapılıyor...'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          product.urunAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${product.marka} - ${product.kategori}'),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: product.aktif ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            product.aktif ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.stokMiktari <= product.kritikStokMiktari)
              Icon(Icons.warning, color: Colors.orange, size: 20),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(product.birim, height: 200, width: 300),
                _buildDetailRow('Ürün Resmi', product.birim),
                _buildDetailRow('Barkod', product.barkod),
                _buildDetailRow('Tedarikçi', product.tedarikci),

                _buildDetailRow(
                  'Satış Adeti',
                  '${product.birimFiyat.toStringAsFixed(2)} ',
                ),
                _buildDetailRow(
                  'Alış Fiyatı',
                  '${product.alisFiyati.toStringAsFixed(2)} ₺',
                ),
                _buildDetailRow(
                  'KDV Oranı',
                  '%${product.kdvOrani.toStringAsFixed(1)}',
                ),
                _buildDetailRow('Stok Miktarı', '${product.stokMiktari}'),
                _buildDetailRow('Kritik Stok', '${product.kritikStokMiktari}'),
                if (product.toptanFiyat != null)
                  _buildDetailRow(
                    'Toptan Fiyat',
                    '${product.toptanFiyat!.toStringAsFixed(2)} ₺',
                  ),
                if (product.perakendeFiyat != null)
                  _buildDetailRow(
                    'Perakende Fiyat',
                    '${product.perakendeFiyat!.toStringAsFixed(2)} ₺',
                  ),
                if (product.aciklama != null && product.aciklama!.isNotEmpty)
                  _buildDetailRow('Açıklama', product.aciklama!),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green[100]),
                  ),
                  icon: Icon(Icons.shop),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductSalesWidget(product: product),
                      ),
                    );
                  },
                  label: Text("Ürün Satışı"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class ProductEditDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductEditDialog({Key? key, this.product, required this.onSave})
    : super(key: key);

  @override
  _ProductEditDialogState createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barkodController;
  late TextEditingController _urunAdiController;
  late TextEditingController _kategoriController;
  late TextEditingController _markaController;
  late TextEditingController _tedarikciController;
  late TextEditingController _birimController;
  late TextEditingController _birimFiyatController;
  late TextEditingController _alisFiyatiController;
  late TextEditingController _kdvOraniController;
  late TextEditingController _stokMiktariController;
  late TextEditingController _kritikStokController;
  late TextEditingController _aciklamaController;
  late TextEditingController _toptanFiyatController;
  late TextEditingController _perakendeFiyatController;
  late TextEditingController _kisaAciklamaController;
  bool _aktif = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final product = widget.product;
    _barkodController = TextEditingController(text: product?.barkod ?? '');
    _urunAdiController = TextEditingController(text: product?.urunAdi ?? '');
    _kategoriController = TextEditingController(text: product?.kategori ?? '');
    _markaController = TextEditingController(text: product?.marka ?? '');
    _tedarikciController = TextEditingController(
      text: product?.tedarikci ?? '',
    );
    _birimController = TextEditingController(text: product?.birim ?? '');
    _birimFiyatController = TextEditingController(
      text: product?.birimFiyat.toStringAsFixed(2) ?? '',
    );
    _alisFiyatiController = TextEditingController(
      text: product?.alisFiyati.toStringAsFixed(2) ?? '',
    );
    _kdvOraniController = TextEditingController(
      text: product?.kdvOrani.toStringAsFixed(1) ?? '',
    );
    _stokMiktariController = TextEditingController(
      text: product?.stokMiktari.toString() ?? '',
    );
    _kritikStokController = TextEditingController(
      text: product?.kritikStokMiktari.toString() ?? '',
    );
    _aciklamaController = TextEditingController(text: product?.aciklama ?? '');
    _toptanFiyatController = TextEditingController(
      text: product?.toptanFiyat?.toStringAsFixed(2) ?? '',
    );
    _perakendeFiyatController = TextEditingController(
      text: product?.perakendeFiyat?.toStringAsFixed(2) ?? '',
    );
    _kisaAciklamaController = TextEditingController(
      text: product?.kisaAciklama ?? '',
    );
    _aktif = product?.aktif ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.product == null ? 'Yeni Ürün Ekle' : 'Ürün Düzenle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        'Barkod',
                        _barkodController,
                        required: true,
                      ),
                      _buildTextField(
                        'Ürün Adı',
                        _urunAdiController,
                        required: true,
                      ),
                      _buildTextField(
                        'Kategori',
                        _kategoriController,
                        required: true,
                      ),
                      _buildTextField(
                        'Marka',
                        _markaController,
                        required: true,
                      ),
                      _buildTextField(
                        'Tedarikçi',
                        _tedarikciController,
                        required: true,
                      ),
                      _buildTextField(
                        'Birim',
                        _birimController,
                        required: true,
                      ),
                      _buildTextField(
                        'Birim Fiyat',
                        _birimFiyatController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        'Alış Fiyatı',
                        _alisFiyatiController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        'KDV Oranı',
                        _kdvOraniController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        'Stok Miktarı',
                        _stokMiktariController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        'Kritik Stok',
                        _kritikStokController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        'Toptan Fiyat',
                        _toptanFiyatController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        'Perakende Fiyat',
                        _perakendeFiyatController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField('Kısa Açıklama', _kisaAciklamaController),
                      _buildTextField(
                        'Açıklama',
                        _aciklamaController,
                        maxLines: 3,
                      ),
                      SwitchListTile(
                        title: Text('Aktif'),
                        value: _aktif,
                        onChanged: (value) {
                          setState(() {
                            _aktif = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('İptal'),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _saveProduct, child: Text('Kaydet')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label gereklidir';
                }
                return null;
              }
            : null,
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        urunId: widget.product?.urunId ?? 0,
        barkod: _barkodController.text,
        urunAdi: _urunAdiController.text,
        kategori: _kategoriController.text,
        marka: _markaController.text,
        tedarikci: _tedarikciController.text,
        birim: _birimController.text,
        birimFiyat: double.parse(_birimFiyatController.text),
        alisFiyati: double.parse(_alisFiyatiController.text),
        kdvOrani: double.parse(_kdvOraniController.text),
        stokMiktari: int.parse(_stokMiktariController.text),
        kritikStokMiktari: int.parse(_kritikStokController.text),
        aktif: _aktif,
        olusturmaTarihi: widget.product?.olusturmaTarihi ?? DateTime.now(),
        guncellemeTarihi: DateTime.now(),
        aciklama: _aciklamaController.text.isEmpty
            ? null
            : _aciklamaController.text,
        toptanFiyat: _toptanFiyatController.text.isEmpty
            ? null
            : double.parse(_toptanFiyatController.text),
        perakendeFiyat: _perakendeFiyatController.text.isEmpty
            ? null
            : double.parse(_perakendeFiyatController.text),
        kisaAciklama: _kisaAciklamaController.text.isEmpty
            ? null
            : _kisaAciklamaController.text,
      );

      widget.onSave(product);
    }
  }

  @override
  void dispose() {
    _barkodController.dispose();
    _urunAdiController.dispose();
    _kategoriController.dispose();
    _markaController.dispose();
    _tedarikciController.dispose();
    _birimController.dispose();
    _birimFiyatController.dispose();
    _alisFiyatiController.dispose();
    _kdvOraniController.dispose();
    _stokMiktariController.dispose();
    _kritikStokController.dispose();
    _aciklamaController.dispose();
    _toptanFiyatController.dispose();
    _perakendeFiyatController.dispose();
    _kisaAciklamaController.dispose();
    super.dispose();
  }
}
