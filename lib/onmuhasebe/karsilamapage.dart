import 'package:flutter/material.dart';
import 'package:hcastick/onmuhasebe/firmalogin.dart';
import 'package:hcastick/onmuhasebe/yenikayit.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Web uyumu
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Başlık
                Icon(Icons.account_balance, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  "Ön Muhasebe",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "İşlerinizi kolaylaştıran akıllı ön muhasebe programı",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 40),

                // Özellikler
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Pratik ve işlevsel ön muhasebe yönetimi"),
                    ),
                    ListTile(
                      leading: Icon(Icons.message, color: Colors.orange),
                      title: Text("Grup içi mesaj bırakma özelliği"),
                    ),
                    ListTile(
                      leading: Icon(Icons.smart_toy, color: Colors.purple),
                      title: Text("Yapay zeka destekli CRM"),
                    ),
                    ListTile(
                      leading: Icon(Icons.cloud, color: Colors.blue),
                      title: Text("Web ve mobil uyumlu kullanım"),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        "Kayıt Ol",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginWidget(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text(
                        "Giriş Yap",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Footer
                const Text(
                  "© 2025 HCA Yazılım",
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
