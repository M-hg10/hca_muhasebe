import 'package:flutter/material.dart';
import 'package:hcastick/admin/adminproductpage.dart';
import 'package:hcastick/admin/maliyetanaliz.dart';
import 'package:hcastick/admin/min_fiyat.dart';
import 'package:hcastick/admin/siparis_fiyat.dart';
import 'package:hcastick/bolumler/kargo/kargofiyatlar.dart';
import 'package:hcastick/bolumler/urunler/urunekle.dart';

class OzelSayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firma Paneli"),
        backgroundColor: const Color.fromARGB(255, 235, 239, 205),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: const Color.fromARGB(255, 36, 125, 9),
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(child: Text("Ambalajdan Maliyet Hesaplama")),
              title: Center(
                child: Text(
                  "Ambalaj Maliyet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaliyetHesaplamaSayfasi(),
                  ),
                );
              },
            ),
          ),
          Card(
            color: Colors.blueGrey,
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(
                child: Text("Ürün Ekleme Sayfasına Yönlendirir"),
              ),
              title: Center(
                child: Text(
                  "Ürün Ekleme",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimatedProductForm(),
                  ),
                );
              },
            ),
          ),
          Card(
            color: Colors.blueGrey,
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(child: Text("Geliver kargo fiyatları")),
              title: Center(
                child: Text(
                  "Kargo Fiyatları",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KargoFiyatlariPage()),
                );
              },
            ),
          ),
          Card(
            color: const Color.fromARGB(255, 243, 111, 2),
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(child: Text("Ürün yönetim Sayfası")),
              title: Center(child: Text("Ürün yönetimi")),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProductsPage()),
                );
              },
            ),
          ),
          Card(
            color: const Color.fromARGB(255, 234, 192, 156),
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(child: Text("Sabitler Hesaplama Sayfası")),
              title: Center(child: Text("Fiyatlar hesaplama yönetimi")),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebhookDataPage()),
                );
              },
            ),
          ),
          Card(
            color: const Color.fromARGB(255, 134, 216, 228),
            child: ListTile(
              hoverColor: Colors.amber,
              subtitle: Center(child: Text("Siparis Hesaplama Sayfası")),
              title: Center(child: Text("Siparis fiyat hesaplama yönetimi")),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductionCalculatorPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
