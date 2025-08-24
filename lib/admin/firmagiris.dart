import 'package:flutter/material.dart';
import 'package:hcastick/admin/admindashboard.dart';

class FirmaGirisSayfasi extends StatefulWidget {
  @override
  _FirmaGirisSayfasiState createState() => _FirmaGirisSayfasiState();
}

class _FirmaGirisSayfasiState extends State<FirmaGirisSayfasi>
    with SingleTickerProviderStateMixin {
  final TextEditingController kodController = TextEditingController();
  final String dogruKod = "357852";

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Sayfa yüklenince animasyonu başlat
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void girisYap() {
    if (kodController.text.trim() == dogruKod) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OzelSayfa()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Hatalı firma kodu!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "👨‍💼 Firma Girişi",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: kodController,
                      decoration: InputDecoration(
                        labelText: "Firma Kodu",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: girisYap,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text("🔐 Giriş Yap"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
