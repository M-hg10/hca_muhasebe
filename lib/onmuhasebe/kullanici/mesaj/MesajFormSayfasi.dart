import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/mesaj/alicilist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MesajFormSayfasi extends StatefulWidget {
  final MesajKullanici alici;
  final int gonderenId;
  final int aliciId;
  final String chat_type;

  const MesajFormSayfasi({
    Key? key,
    required this.gonderenId,
    required this.aliciId,
    required this.chat_type,
    required this.alici,
  }) : super(key: key);

  @override
  _MesajFormSayfasiState createState() => _MesajFormSayfasiState();
}

class _MesajFormSayfasiState extends State<MesajFormSayfasi> {
  final TextEditingController _konuController = TextEditingController();
  final TextEditingController _mesajController = TextEditingController();
  bool _yukleniyor = false;

  void mesajGonder() async {
    if (_konuController.text.isEmpty || _mesajController.text.isEmpty) return;

    setState(() {
      _yukleniyor = true;
    });

    try {
      String url =
          'https://n8n.hggrup.com/webhook/bb18de84-6656-42fc-a402-00dbc789fc55';

      if (widget.chat_type == 'direct') {
        // direct ise alıcı belli
        url = '$url?chat_type=direct';
      } else if (widget.chat_type == 'group') {
        // group ise herkes alıcı
        url = '$url?chat_type=group';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'konu': _konuController.text,
          'mesaj': _mesajController.text,
          'alici_id': widget.alici.id,
          'gonderici_id': aktifKullanici.id,
          'firmaId': aktifKullanici.firma.id,
          if (widget.chat_type == 'group') 'groupId': 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mesaj gönderildi ✅'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Gönderim sonrası UI temizleme
        _konuController.clear();
        _mesajController.clear();
      } else {
        print('Mesaj gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    } finally {
      setState(() {
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chat_type == 'direct'
                                ? "Yeni Mesaj Gönder"
                                : "Grup Mesajı Gönder",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.chat_type == 'direct'
                                ? "Birebir Sohbet"
                                : "Grup Sohbeti",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.chat_type == 'direct'
                            ? Colors.green.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.chat_type == 'direct'
                            ? Icons.person
                            : Icons.group,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient Info (for direct messages)
                        if (widget.chat_type == 'direct')
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade50,
                                  Colors.green.shade100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Alıcı",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      widget.alici.kullaniciAdi,
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Subject Field
                        const Text(
                          "Konu",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _konuController,
                            decoration: InputDecoration(
                              hintText: "Mesaj konusunu giriniz",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              prefixIcon: Icon(
                                Icons.subject,
                                color: Colors.blue.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade400,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey.shade300,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Message Field
                        const Text(
                          "Mesaj İçeriği",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _mesajController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: "Mesajınızı yazınız...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    left: 12,
                                  ),
                                  child: Icon(
                                    Icons.message,
                                    color: Colors.purple.shade400,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.purple.shade400,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Send Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _yukleniyor
                                  ? [Colors.grey.shade300, Colors.grey.shade400]
                                  : [
                                      Colors.blue.shade400,
                                      Colors.purple.shade500,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _yukleniyor
                                    ? Colors.grey.shade300
                                    : Colors.blue.shade300.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _yukleniyor ? null : mesajGonder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _yukleniyor
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Gönderiliyor...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Mesajı Gönder",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
