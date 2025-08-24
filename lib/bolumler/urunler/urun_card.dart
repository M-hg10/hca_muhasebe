import 'package:flutter/material.dart';
import 'package:hcastick/bolumler/urunler/urun_detay.dart';

class UrunCard extends StatelessWidget {
  final String urunAdi;
  final String aciklama;
  final double fiyat;
  final String resimUrl; // Hero resim için
  final IconData ikon;

  const UrunCard({
    super.key,
    required this.urunAdi,
    required this.aciklama,
    required this.fiyat,
    required this.resimUrl,
    required this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return DetaySayfasi(
                urunAdi: urunAdi,
                fiyat: fiyat,
                aciklama: aciklama,
                resimUrl: resimUrl,
                ikon: ikon,
              );
            },
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        margin: const EdgeInsets.all(12),
        child: Column(
          children: [
            Hero(
              tag: urunAdi,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  resimUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(ikon, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        urunAdi,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(aciklama, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    "${fiyat.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
