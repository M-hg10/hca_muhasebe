import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KargoFiyatlariPage extends StatefulWidget {
  const KargoFiyatlariPage({Key? key}) : super(key: key);

  @override
  State<KargoFiyatlariPage> createState() => _KargoFiyatlariPageState();
}

class _KargoFiyatlariPageState extends State<KargoFiyatlariPage> {
  List<Map<String, dynamic>> offers = [];
  bool loading = true;

  // Firma kodlarına göre renkler
  final Map<String, Color> firmaRenkleri = {
    "HEPSIJET": Colors.orange,
    "SURAT": Colors.green,
    "PTT": Colors.blue,
    "KOLAYGELSIN": Colors.purple,
    "ARAS": Colors.red,
    "YURTICI": Colors.indigo,
    "PAKETTAXI": Colors.brown,
  };

  // Firma kodlarına göre logo/ikon
  final Map<String, IconData> firmaIconlari = {
    "HEPSIJET": Icons.local_shipping,
    "SURAT": Icons.send,
    "PTT": Icons.mail,
    "KOLAYGELSIN": Icons.delivery_dining,
    "ARAS": Icons.local_mall,
    "YURTICI": Icons.flight_takeoff,
    "PAKETTAXI": Icons.taxi_alert,
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
      "https://n8n.hggrup.com/webhook/c1cf43de-1b23-4f37-9e17-297a65c83143",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final outerJson = jsonDecode(response.body);
      final dataString = outerJson[0]["data"];
      final innerJson = jsonDecode(dataString);
      final priceList = innerJson["priceList"] as List;

      if (priceList.isNotEmpty) {
        final firstPriceList = priceList.first;
        final offersList = firstPriceList["offers"] as List;

        setState(() {
          offers = offersList.map((e) => Map<String, dynamic>.from(e)).toList();
          loading = false;
        });
      }
    } else {
      throw Exception("Veri çekilemedi: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kargo Fiyatları"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final firma = offer["providerCode"];
                final renk = firmaRenkleri[firma] ?? Colors.grey;
                final icon = firmaIconlari[firma] ?? Icons.local_shipping;

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: renk,
                      child: Icon(icon, color: Colors.white),
                    ),
                    title: Text(
                      "$firma - ${offer["transportType"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: renk,
                      ),
                    ),
                    subtitle: Text(
                      "KDV: ${offer["amountVat"]} ${offer["currency"]}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: renk.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: renk, width: 1),
                      ),
                      child: Text(
                        "${offer["totalAmount"]} ${offer["currency"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: renk,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
