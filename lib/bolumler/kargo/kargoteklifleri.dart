// Yeni sayfa olarak KargoTeklifleriSayfasi
import 'package:flutter/material.dart';
import 'package:hcastick/bolumler/kargo/kargogonder.dart';

class KargoTeklifleriSayfasi extends StatefulWidget {
  final List<dynamic> teklifler;
  final String en;
  final String boy;
  final String yukseklik;
  final String agirlik;
  final double hesaplananDesi;

  const KargoTeklifleriSayfasi({
    Key? key,
    required this.teklifler,
    required this.en,
    required this.boy,
    required this.yukseklik,
    required this.agirlik,
    required this.hesaplananDesi,
  }) : super(key: key);

  @override
  State<KargoTeklifleriSayfasi> createState() => _KargoTeklifleriSayfasiState();
}

class _KargoTeklifleriSayfasiState extends State<KargoTeklifleriSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "Kargo Teklifleri",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: buildTeklifKartlari(widget.teklifler)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Kapat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeklifKartlari(List<dynamic> teklifler) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(16),
      itemCount: teklifler.length,
      itemBuilder: (context, index) {
        final teklif = teklifler[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Kargogonder(
                        kargoFirmasi:
                            "${teklif["providerCode"]} - ${teklif["transportType"]}",
                        paket: "hcapaket",
                        en: widget.en,
                        boy: widget.boy,
                        yukseklik: widget.yukseklik,
                        agirlik: widget.agirlik,
                        gercekfiyat: (double.parse(
                          teklif["totalAmount"],
                        )).toStringAsFixed(2),
                        teklif: (double.parse(teklif["totalAmount"]) * 1.25)
                            .toStringAsFixed(2),
                        desi: widget.hesaplananDesi.toStringAsFixed(2),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${teklif["providerCode"]} - ${teklif["transportType"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Teklif: ${(double.parse(teklif["amount"]) * 1.25).toStringAsFixed(2)} ₺",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "KDV: ${(double.parse(teklif["amountVat"]) * 1.25).toStringAsFixed(2)} ₺ | Vergi: ${(double.parse(teklif["amountTax"]) * 1.25).toStringAsFixed(2)} ₺",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${(double.parse(teklif["totalAmount"]) * 1.25).toStringAsFixed(2)} ${teklif["currency"]}",
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "Toplam",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
