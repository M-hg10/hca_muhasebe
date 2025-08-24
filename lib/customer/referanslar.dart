import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:intl/intl.dart';
import 'package:hcastick/customer/uretim_kayit_api.dart';

class ReferanslarSayfasi extends StatefulWidget {
  @override
  _ReferanslarSayfasiState createState() => _ReferanslarSayfasiState();
}

class _ReferanslarSayfasiState extends State<ReferanslarSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Referanslar"),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<ProductionModel>>(
        future: ApiService.getProductions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];
          final Map<String, List<ProductionModel>> grouped = {};

          for (var item in data) {
            grouped.putIfAbsent(item.firma, () => []).add(item);
          }

          return Center(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: grouped.entries.map((entry) {
                final renk = Colors
                    .primaries[entry.key.hashCode % Colors.primaries.length];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: renk.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900
                            ? 3
                            : constraints.maxWidth > 600
                            ? 2
                            : 1;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.5,
                              ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final prod = entry.value[index];
                            final cardController = FlipCardController();

                            return GestureDetector(
                              onTap: () {
                                cardController.flipcard();
                              },
                              child: FlipCard(
                                controller: cardController,
                                rotateSide: RotateSide.right,
                                frontWidget: _buildFrontCard(prod, renk),
                                backWidget: _buildBackCard(prod, renk),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildFrontCard(ProductionModel prod, MaterialColor renk) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: prod.Klise_img.isNotEmpty
              ? Image.network(prod.Klise_img, fit: BoxFit.cover)
              : Container(color: renk.shade100),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              prod.firma,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBackCard(ProductionModel prod, MaterialColor renk) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    color: renk.shade50,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ürün: ${prod.urunler}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("Üretim ID: ${prod.id}"),
          Text("Miktar: ${prod.uretimMiktari}"),
          Text(
            "Tarih: ${DateFormat("dd.MM.yyyy").format(prod.createdAt.toLocal())}",
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<UretimTakipModel>>(
              future: ApiService.getTakipByUretimId(prod.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text("Takip verisi alınamadı");
                }
                final takipList = snapshot.data ?? [];
                if (takipList.isEmpty) {
                  return const Text("Takip bilgisi yok.");
                }
                return ListView.builder(
                  itemCount: takipList.length,
                  itemBuilder: (context, index) {
                    final t = takipList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "${DateFormat("dd.MM.yyyy HH:mm").format(t.tarihSaat.toLocal())} • ${t.durum}: ${t.aciklama}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductionModel {
  final int id;
  final String firma;
  final String urunler;
  final String uretimMiktari;
  final DateTime createdAt;
  final String Klise_img;

  ProductionModel({
    required this.id,
    required this.firma,
    required this.urunler,
    required this.uretimMiktari,
    required this.createdAt,
    required this.Klise_img,
  });

  factory ProductionModel.fromJson(Map<String, dynamic> json) {
    return ProductionModel(
      id: json["id"],
      firma: json["firma"],
      urunler: json["urunler"],
      uretimMiktari: json["uretim_miktari"],
      Klise_img: json["klise_img"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}

class UretimTakipModel {
  final int id;
  final int uretimkayitId;
  final String durum;
  final String aciklama;
  final DateTime tarihSaat;
  final String kullanici;

  UretimTakipModel({
    required this.id,
    required this.uretimkayitId,
    required this.durum,
    required this.aciklama,
    required this.tarihSaat,
    required this.kullanici,
  });

  factory UretimTakipModel.fromJson(Map<String, dynamic> json) {
    return UretimTakipModel(
      id: json['id'],
      uretimkayitId: json['uretimkayit_id'],
      durum: json['durum'],
      aciklama: json['aciklama'],
      tarihSaat: DateTime.parse(json['tarih_saat']),
      kullanici: json['kullanici'],
    );
  }
}
