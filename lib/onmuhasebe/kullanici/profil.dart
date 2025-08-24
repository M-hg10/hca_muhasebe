import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final kullanici = aktifKullanici;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.deepPurple,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kullanici.kullaniciAdi,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    kullanici.email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _profilSatiri("Firma", kullanici.firma.firmaAdi),
                  _profilSatiri("Adres", kullanici.firma.adres),
                  _profilSatiri("Telefon", kullanici.firma.telefon),
                  _profilSatiri("Durum", kullanici.aktif ? "Aktif" : "Pasif"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profilSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$baslik: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(deger)),
        ],
      ),
    );
  }
}
