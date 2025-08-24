import 'package:flutter/material.dart';

class DetaySayfasi extends StatelessWidget {
  final String urunAdi;
  final String aciklama;
  final double fiyat;
  final String resimUrl;
  final IconData ikon;

  const DetaySayfasi({
    super.key,
    required this.urunAdi,
    required this.aciklama,
    required this.fiyat,
    required this.resimUrl,
    required this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(urunAdi)),
      body: Column(
        children: [
          Hero(
            tag: urunAdi,
            child: Image.network(
              resimUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(ikon, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      urunAdi,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aciklama,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(
                  "${fiyat.toStringAsFixed(2)} ₺",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Sepete ekle vs.
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Sepete Ekle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
