import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ModernMusteriFirmaEkle extends StatefulWidget {
  @override
  _ModernMusteriFirmaEkleState createState() => _ModernMusteriFirmaEkleState();
}

class _ModernMusteriFirmaEkleState extends State<ModernMusteriFirmaEkle>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firmaAdiController = TextEditingController();
  final TextEditingController ticariUnvanController = TextEditingController();
  final TextEditingController vergiNoController = TextEditingController();
  final TextEditingController vergiDairesiController = TextEditingController();
  final TextEditingController telefonController = TextEditingController();
  final TextEditingController cepTelefonuController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController webSiteController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController ilController = TextEditingController();
  final TextEditingController ilceController = TextEditingController();
  final TextEditingController postaKoduController = TextEditingController();

  bool aktif = true;
  bool isLoading = false;

  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _buttonController;
  late AnimationController _switchController;
  late List<AnimationController> _fieldControllers;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _switchAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _pageController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _switchController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Her form alanı için ayrı controller
    _fieldControllers = List.generate(12, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      );
    });

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeIn));

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _switchAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _switchController, curve: Curves.bounceOut),
    );
  }

  void _startAnimations() {
    _pageController.forward();
    _buttonController.forward();
    _switchController.forward();

    // Form alanlarını sırayla animasyonla göster
    for (int i = 0; i < _fieldControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _fieldControllers[i].forward();
        }
      });
    }
  }

  void sendData() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Button animation
    _buttonController.reverse().then((_) => _buttonController.forward());

    setState(() => isLoading = true);

    try {
      // Simulated API call
      final url = Uri.parse('https://webhook-adresiniz.com/api/musteri_firma');

      // JSON yapısı MusteriFirma modeline uygun hazırlanıyor
      final Map<String, dynamic> data = {
        "id": 0, // backend otomatik atayacaksa 0 veya null gönderilebilir
        "ana_firma_id": 1, // sabit ya da form ile alınabilir
        "firma_adi": firmaAdiController.text,
        "ticari_unvan": ticariUnvanController.text,
        "vergi_no": vergiNoController.text,
        "vergi_dairesi": vergiDairesiController.text,
        "telefon": telefonController.text,
        "cep_telefonu": cepTelefonuController.text,
        "email": emailController.text.isEmpty ? null : emailController.text,
        "web_site": webSiteController.text.isEmpty
            ? null
            : webSiteController.text,
        "adres": adresController.text.isEmpty ? null : adresController.text,
        "il": ilController.text.isEmpty ? null : ilController.text,
        "ilce": ilceController.text.isEmpty ? null : ilceController.text,
        "posta_kodu": postaKoduController.text.isEmpty
            ? null
            : postaKoduController.text,
        "aktif": aktif,
        "kayit_tarihi": DateTime.now().toIso8601String(),
        "guncelleme_tarihi": null,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı
        // Show success dialog
        _showSuccessDialog();
        _formKey.currentState!.reset();
      } else {
        // Hata durumu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderme hatası: ${response.statusCode}')),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Hata oluştu: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text("Başarılı!"),
            ],
          ),
          content: Text("Müşteri firma başarıyla eklendi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    firmaAdiController.clear();
    ticariUnvanController.clear();
    vergiNoController.clear();
    vergiDairesiController.clear();
    telefonController.clear();
    cepTelefonuController.clear();
    emailController.clear();
    webSiteController.clear();
    adresController.clear();
    ilController.clear();
    ilceController.clear();
    postaKoduController.clear();
    setState(() => aktif = true);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonController.dispose();
    _switchController.dispose();
    for (var controller in _fieldControllers) {
      controller.dispose();
    }

    // Dispose text controllers
    firmaAdiController.dispose();
    ticariUnvanController.dispose();
    vergiNoController.dispose();
    vergiDairesiController.dispose();
    telefonController.dispose();
    cepTelefonuController.dispose();
    emailController.dispose();
    webSiteController.dispose();
    adresController.dispose();
    ilController.dispose();
    ilceController.dispose();
    postaKoduController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingScreen() : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      title: Text(
        'Müşteri Firma Ekle',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            "Müşteri kaydediliyor...",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: "Temel Bilgiler",
                      icon: Icons.business,
                      children: [
                        _buildAnimatedTextField(
                          controller: firmaAdiController,
                          label: 'Firma Adı',
                          icon: Icons.business_center,
                          required: true,
                          animationIndex: 0,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen firma adını giriniz';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: ticariUnvanController,
                          label: 'Ticari Unvan',
                          icon: Icons.account_balance,
                          required: true,
                          animationIndex: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen ticari unvanı giriniz';
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Vergi Bilgileri",
                      icon: Icons.receipt_long,
                      children: [
                        _buildAnimatedTextField(
                          controller: vergiNoController,
                          label: 'Vergi No',
                          icon: Icons.receipt,
                          required: true,
                          animationIndex: 2,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen vergi numarasını giriniz';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: vergiDairesiController,
                          label: 'Vergi Dairesi',
                          icon: Icons.location_city,
                          required: true,
                          animationIndex: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen vergi dairesi giriniz';
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSectionCard(
                      title: "İletişim Bilgileri",
                      icon: Icons.contact_phone,
                      children: [
                        _buildAnimatedTextField(
                          controller: telefonController,
                          label: 'Telefon',
                          icon: Icons.phone,
                          required: true,
                          animationIndex: 4,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen telefon numarası giriniz';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: cepTelefonuController,
                          label: 'Cep Telefonu',
                          icon: Icons.smartphone,
                          required: true,
                          animationIndex: 5,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Lütfen cep telefonu giriniz';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                          animationIndex: 6,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: webSiteController,
                          label: 'Web Site',
                          icon: Icons.language,
                          animationIndex: 7,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Adres Bilgileri",
                      icon: Icons.location_on,
                      children: [
                        _buildAnimatedTextField(
                          controller: adresController,
                          label: 'Adres',
                          icon: Icons.home,
                          animationIndex: 8,
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAnimatedTextField(
                                controller: ilController,
                                label: 'İl',
                                icon: Icons.location_city,
                                animationIndex: 9,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildAnimatedTextField(
                                controller: ilceController,
                                label: 'İlçe',
                                icon: Icons.map,
                                animationIndex: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildAnimatedTextField(
                          controller: postaKoduController,
                          label: 'Posta Kodu',
                          icon: Icons.markunread_mailbox,
                          animationIndex: 11,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildAnimatedSwitch(),
                    SizedBox(height: 30),
                    _buildSubmitButton(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.teal.shade600, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int animationIndex,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return AnimatedBuilder(
      animation: _fieldControllers[animationIndex],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - _fieldControllers[animationIndex].value), 0),
          child: Opacity(
            opacity: _fieldControllers[animationIndex].value,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: required ? '$label *' : label,
                prefixIcon: Icon(icon, color: Colors.teal.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSwitch() {
    return AnimatedBuilder(
      animation: _switchController,
      builder: (context, child) {
        return Transform.scale(
          scale: _switchAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SwitchListTile(
              title: Text(
                'Aktif mi?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                aktif ? 'Firma aktif durumda' : 'Firma pasif durumda',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              value: aktif,
              activeColor: Colors.teal.shade600,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => aktif = val);
              },
              secondary: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: aktif ? Colors.teal.shade100 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  aktif ? Icons.check_circle : Icons.cancel,
                  color: aktif ? Colors.teal.shade600 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    sendData();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Gönder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
