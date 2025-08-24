import 'package:flutter/material.dart';
import 'package:hcastick/admin/firmagiris.dart';
import 'package:hcastick/bolumler/kargo/kargobolumu.dart';
import 'package:hcastick/bolumler/musteri/bizineden.dart';
import 'package:hcastick/bolumler/urunler/product_detail_page.dart';
import 'package:hcastick/bolumler/urunler/urunlerdataservis.dart';
import 'package:hcastick/customer/referanslar.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirmaGirisSayfasi()),
              );
            },
            child: Text("Firma Girişi", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReferanslarSayfasi()),
              );
            },
            label: Text("Referanslar"),
            icon: Icon(Icons.people),
          ),
        ],
        title: const Text(
          "HCA",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Benedict', // Buraya yaml'deki family adı yazılıyor
          ),
        ),

        backgroundColor: const Color.fromARGB(255, 5, 21, 18),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Bölümü
            _buildHeroSection(),

            // Ana İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: HizmetlerWidget(isMobile: isMobile),
                      ),
                      const SizedBox(height: 32),

                      // İletişim ve Referanslar
                      if (isMobile) ...[
                        WhyChooseUsWidget(),
                        //const HizliIletisimBolumu(),
                        const SizedBox(height: 24),
                        // const ReferanslarBolumu(),
                        const SizedBox(height: 24),
                        //CustomerFormPage(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            //    Expanded(child: HizliIletisimBolumu()),
                            SizedBox(width: 24),
                            //   Expanded(child: ReferanslarBolumu()),
                          ],
                        ),
                        WhyChooseUsWidget(),

                        const SizedBox(height: 24),
                        //CustomerFormPage(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 500,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 5, 21, 18),
            const Color.fromARGB(255, 18, 71, 60),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            height: 300,
            width: 300,

            "https://i.hizliresim.com/fejspdc.png",
            errorBuilder: (context, error, stackTrace) {
              return CircularProgressIndicator(); // Hata durumunda gösterilecek widget
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator(); // Yüklenirken gösterilecek
            },
          ),
          const SizedBox(height: 16),
          Text(
            "Kaliteli Ambalaj & Güvenli Kargo",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Benedict',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Stick ve kare ambalaj ürünlerinde uzman, hızlı kargo çözümleri",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HizmetlerWidget extends StatefulWidget {
  final bool isMobile;

  const HizmetlerWidget({Key? key, required this.isMobile}) : super(key: key);

  @override
  _HizmetlerWidgetState createState() => _HizmetlerWidgetState();
}

class _HizmetlerWidgetState extends State<HizmetlerWidget> {
  String? secilenHizmet; // null = ana görünüm, diğerleri = seçilen hizmet
  List<Product> urunler = [];
  bool isLoading = false;
  late DatabaseService _databaseService;

  // Hizmet türleri
  static const String STICK_AMBALAJ = "stick_ambalaj";
  static const String KARE_AMBALAJ = "kare_ambalaj";
  static const String KARGO_HIZMETI = "kargo_hizmeti";

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHizmetlerSection(widget.isMobile, context);
  }

  Widget _buildHizmetlerSection(bool isMobile, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (secilenHizmet != null) ...[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    secilenHizmet = null;
                    urunler = [];
                  });
                },
              ),
              SizedBox(width: 8),
            ],
            Text(
              secilenHizmet == null
                  ? "Hizmetlerimiz"
                  : _getSelectedServiceTitle(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (secilenHizmet == null)
          _buildMainServiceCards(isMobile, context)
        else
          _buildSelectedServiceProducts(isMobile, context),
      ],
    );
  }

  Widget _buildMainServiceCards(bool isMobile, BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          HizmetKarti(
            resim: 'https://i.hizliresim.com/5hn6cu9.png',
            icon: Icons.inventory_2,
            baslik: "Stick Ambalaj Ürünleri",
            aciklama:
                "Stick şeker, baharat, tuz ve diğer gıda ürünleri için özel ambalaj çözümleri",
            renk: Colors.blue,
            ozellikler: [
              "Stick şeker ambalajı",
              "Baharat paketleme",
              "Tuz ambalajı",
              "Özel tasarım",
            ],
            onTap: () {
              setState(() {
                secilenHizmet = STICK_AMBALAJ;
              });
              _loadProducts();
            },
          ),
          const SizedBox(height: 16),
          HizmetKarti(
            resim: 'https://i.hizliresim.com/g4ocxkk.png',
            icon: Icons.crop_square,
            baslik: "Kare Ambalaj Ürünleri",
            aciklama:
                "Kare format ambalaj çözümleri ile ürünlerinizi güvenle paketliyoruz",
            renk: Colors.orange,
            ozellikler: [
              "Kare baharat kutuları",
              "Özel boyut seçenekleri",
              "Dayanıklı malzeme",
              "Hızlı üretim",
            ],
            onTap: () {
              setState(() {
                secilenHizmet = KARE_AMBALAJ;
              });
              _loadProducts();
            },
          ),
          const SizedBox(height: 16),
          HizmetKarti(
            resim: "https://i.hizliresim.com/e6vxgz1.png",
            icon: Icons.local_shipping,
            baslik: "Kargo Hizmetleri",
            aciklama:
                "Ürünlerinizi güvenle ve hızlı bir şekilde hedefe ulaştırıyoruz",
            renk: Colors.green,
            ozellikler: [
              "Hızlı teslimat",
              "Güvenli paketleme",
              "Takip sistemi",
              "Uygun fiyat",
            ],
            onTap: () {
              // Kargo için özel davranış - sayfa yönlendirmesi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => kargohesap()),
              );
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: HizmetKarti(
              resim: 'https://i.hizliresim.com/5hn6cu9.png',
              icon: Icons.inventory_2,
              baslik: "Stick Ambalaj",
              aciklama: "Stick şeker, baharat, tuz ambalajı",
              renk: Colors.blue,
              ozellikler: ["Stick şeker", "Baharat", "Tuz", "Özel tasarım"],
              onTap: () {
                setState(() {
                  secilenHizmet = STICK_AMBALAJ;
                });
                _loadProducts();
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: HizmetKarti(
              resim: 'https://i.hizliresim.com/g4ocxkk.png',
              icon: Icons.crop_square,
              baslik: "Kare Ambalaj",
              aciklama: "Kare format ambalaj çözümleri",
              renk: Colors.orange,
              ozellikler: [
                "Kare kutular",
                "Özel boyut",
                "Dayanıklı",
                "Hızlı üretim",
              ],
              onTap: () {
                setState(() {
                  secilenHizmet = KARE_AMBALAJ;
                });
                _loadProducts();
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: HizmetKarti(
              resim: "https://i.hizliresim.com/e6vxgz1.png",
              icon: Icons.local_shipping,
              baslik: "Kargo Hizmetleri",
              aciklama: "Güvenli ve hızlı kargo",
              renk: Colors.green,
              ozellikler: ["Hızlı teslimat", "Güvenli", "Takip", "Uygun fiyat"],
              onTap: () {
                // Kargo için özel davranış - sayfa yönlendirmesi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => kargohesap()),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSelectedServiceProducts(bool isMobile, BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_getServiceColor()),
            ),
            SizedBox(height: 16),
            Text("Ürünler yükleniyor..."),
          ],
        ),
      );
    }

    if (urunler.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Bu kategoride henüz ürün bulunmuyor.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProducts(),
              child: Text("Tekrar Dene"),
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: urunler
            .map(
              (urun) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildProductCard(urun, isMobile),
              ),
            )
            .toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          return _buildProductCard(urunler[index], isMobile);
        },
      );
    }
  }

  Widget _buildProductCard(Product urun, bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Ürün detay sayfasına yönlendirme
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: urun),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (urun.birim.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    urun.birim,
                    height: isMobile ? 120 : 245,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: isMobile ? 120 : 180,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
              ],
              Text(
                urun.urunAdi,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getServiceColor(),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${urun.aciklama}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (urun.perakendeFiyat != null) ...[
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Perakende Fiyatı: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '${urun.perakendeFiyat!.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (urun.toptanFiyat != null) ...[
                SizedBox(height: 8),
                Text(
                  'Fiyat teklifi için iletişime geçin',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getServiceColor() {
    switch (secilenHizmet) {
      case STICK_AMBALAJ:
        return Colors.blue;
      case KARE_AMBALAJ:
        return Colors.orange;
      case KARGO_HIZMETI:
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  String _getSelectedServiceTitle() {
    switch (secilenHizmet) {
      case STICK_AMBALAJ:
        return "Stick Ambalaj Ürünleri";
      case KARE_AMBALAJ:
        return "Kare Ambalaj Ürünleri";
      case KARGO_HIZMETI:
        return "Kargo Hizmetleri";
      default:
        return "Hizmetlerimiz";
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      String kategori = _getKategoriName();

      // Burada DatabaseService içinde yazdığımız getProductsFromApi kullanılıyor:
      List<Product> fetchedProducts = await _databaseService.getProductsFromApi(
        kategori: kategori,
      );

      setState(() {
        urunler = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        urunler = []; // Hata durumunda boş liste
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürünler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              onPressed: _loadProducts,
            ),
          ),
        );
      }
    }
  }

  String _getKategoriName() {
    switch (secilenHizmet) {
      case STICK_AMBALAJ:
        return "stick_ambalaj";
      case KARE_AMBALAJ:
        return "kare_ambalaj";
      case KARGO_HIZMETI:
        return "kargo_hizmeti";
      default:
        return "";
    }
  }
}

class HizmetKarti extends StatefulWidget {
  final IconData icon;
  final String baslik;
  final String aciklama;
  final Color renk;
  final List<String> ozellikler;
  final String resim;
  final VoidCallback? onTap;

  const HizmetKarti({
    super.key,
    required this.icon,
    required this.baslik,
    required this.aciklama,
    required this.renk,
    required this.ozellikler,
    required this.resim,
    this.onTap,
  });

  @override
  State<HizmetKarti> createState() => _HizmetKartiState();
}

class _HizmetKartiState extends State<HizmetKarti> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0)),
          child: Card(
            elevation: _isHovered ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: _isPressed ? widget.renk.withOpacity(0.1) : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? widget.renk : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resim Bölümü
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      height: 500,
                      width: double.infinity,
                      child: Image.network(
                        widget.resim,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: widget.renk.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.renk,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: widget.renk.withOpacity(0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(widget.icon, color: widget.renk, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'Resim yüklenemedi',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // İçerik Bölümü
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isHovered
                                    ? widget.renk.withOpacity(0.2)
                                    : widget.renk.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.renk,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isHovered
                                      ? widget.renk
                                      : Colors.grey.shade800,
                                ),
                                child: Text(
                                  widget.baslik,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Açıklama Metni
                        Text(
                          widget.aciklama,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),

                        // Özellikler Listesi
                        if (widget.ozellikler.isNotEmpty) ...[
                          Text(
                            'Özellikler:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.ozellikler.take(3).map((ozellik) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.renk.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.renk.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  ozellik,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: widget.renk.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          // Eğer 3'ten fazla özellik varsa "..." göster
                          if (widget.ozellikler.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '+${widget.ozellikler.length - 3} daha...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 16),

                        // Alt kısım - Detay butonu veya ok ikonu
                        if (widget.onTap != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? widget.renk
                                      : widget.renk.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: _isHovered
                                      ? Colors.white
                                      : widget.renk,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
