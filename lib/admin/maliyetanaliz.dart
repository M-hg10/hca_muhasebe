import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MaliyetHesaplamaSayfasi extends StatefulWidget {
  @override
  _MaliyetHesaplamaSayfasiState createState() =>
      _MaliyetHesaplamaSayfasiState();
}

class _MaliyetHesaplamaSayfasiState extends State<MaliyetHesaplamaSayfasi>
    with TickerProviderStateMixin {
  final TextEditingController enController = TextEditingController();
  final TextEditingController boyController = TextEditingController();
  final TextEditingController gramController = TextEditingController();
  final TextEditingController ambalajFiyatController = TextEditingController();

  List<HamMadde> hamMaddeler = [];
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Form değişikliklerini dinle
    enController.addListener(_onFormChanged);
    boyController.addListener(_onFormChanged);
    gramController.addListener(_onFormChanged);
    ambalajFiyatController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {}); // Form her değiştiğinde UI'ı güncelle
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    enController.dispose();
    boyController.dispose();
    gramController.dispose();
    ambalajFiyatController.dispose();
    for (var madde in hamMaddeler) {
      madde.dispose();
    }
    super.dispose();
  }

  void _hamMaddeEkle() {
    setState(() {
      var yeniMadde = HamMadde(onChanged: _onFormChanged);
      hamMaddeler.add(yeniMadde);
      _chartAnimationController.reset();
      _chartAnimationController.forward();
    });
  }

  void _hamMaddeSil(int index) {
    setState(() {
      hamMaddeler[index].dispose();
      hamMaddeler.removeAt(index);
      _chartAnimationController.reset();
      _chartAnimationController.forward();
    });
  }

  double get en => double.tryParse(enController.text) ?? 0;
  double get boy => double.tryParse(boyController.text) ?? 0;
  double get paketGram => double.tryParse(gramController.text) ?? 0;
  double get kgFiyat => double.tryParse(ambalajFiyatController.text) ?? 0;

  double get alan => en * boy;
  double get gramaj => alan > 0 ? (paketGram * 10000) / alan : 0;
  double get m2Fiyat => gramaj * (kgFiyat / 1000);
  double get paketFiyati => (alan / 10000) * m2Fiyat;

  double get icerikFiyati {
    double toplam = 0;
    for (var madde in hamMaddeler) {
      double gram = double.tryParse(madde.gramController.text) ?? 0;
      double fiyat = double.tryParse(madde.kgFiyatController.text) ?? 0;
      toplam += (gram * fiyat) / 1000;
    }
    return toplam;
  }

  List<ChartData> get chartData {
    List<ChartData> data = [];
    if (paketFiyati > 0) {
      data.add(ChartData('Ambalaj', paketFiyati, Colors.blue));
    }
    if (icerikFiyati > 0) {
      data.add(ChartData('İçerik', icerikFiyati, Colors.green));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    double toplam = paketFiyati + icerikFiyati;
    bool hasData = toplam > 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Maliyet Hesaplama",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAmbalajBilgileri(),
                    SizedBox(height: 16),
                    _buildHamMaddeler(),
                    SizedBox(height: 16),
                    if (hasData) _buildSonuclar(toplam),
                    SizedBox(height: 16),
                    if (hasData) _buildChart(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmbalajBilgileri() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.blue[700], size: 28),
                SizedBox(width: 12),
                Text(
                  "Ambalaj Bilgileri",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedTextField(
                    controller: enController,
                    label: "En (cm)",
                    icon: Icons.straighten,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildAnimatedTextField(
                    controller: boyController,
                    label: "Boy (cm)",
                    icon: Icons.straighten,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: gramController,
              label: "Paket Gramajı (g)",
              icon: Icons.scale,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: ambalajFiyatController,
              label: "1 kg Ambalaj Fiyatı (₺)",
              icon: Icons.attach_money,
              color: Colors.blue,
            ),
            if (alan > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      "Hesaplanan Değerler",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Alan: ${alan.toStringAsFixed(2)} cm²"),
                        Text("Gramaj: ${gramaj.toStringAsFixed(2)} g/m²"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHamMaddeler() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.science, color: Colors.green[700], size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Ham Maddeler",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _hamMaddeEkle,
                    icon: Icon(Icons.add, color: Colors.white),
                    tooltip: "Ham Madde Ekle",
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (hamMaddeler.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Henüz ham madde eklenmedi",
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Yukarıdaki + butonuna tıklayarak ham madde ekleyin",
                      style: TextStyle(color: Colors.green[500], fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ...hamMaddeler.asMap().entries.map((entry) {
                int index = entry.key;
                HamMadde madde = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: madde.build(context, index, _hamMaddeSil),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSonuclar(double toplam) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.orange[700], size: 28),
                SizedBox(width: 12),
                Text(
                  "Maliyet Sonuçları",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSonucSatiri(
              "Ambalaj Maliyeti",
              paketFiyati,
              Icons.inventory_2,
              Colors.blue,
            ),
            SizedBox(height: 12),
            _buildSonucSatiri(
              "İçerik Maliyeti",
              icerikFiyati,
              Icons.science,
              Colors.green,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.purple[200]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[300]!, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.purple[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        "TOPLAM MALİYET",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${(toplam * 100).toStringAsFixed(2)} kuruş",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.purple[800],
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

  Widget _buildSonucSatiri(
    String baslik,
    double deger,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                baslik,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            "${(deger * 100).toStringAsFixed(2)} kuruş",
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (chartData.isEmpty) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _chartAnimationController,
      builder: (context, child) {
        return Container(
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SfCircularChart(
              title: ChartTitle(
                text: 'Maliyet Dağılımı',
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: TextStyle(fontSize: 14),
              ),
              series: <CircularSeries<ChartData, String>>[
                DoughnutSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.name,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  pointColorMapper: (ChartData data, _) => data.color,
                  innerRadius: '50%',
                  explode: true,
                  explodeIndex: 0,
                  animationDuration: 1200,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}

class HamMadde {
  final TextEditingController adController = TextEditingController();
  final TextEditingController gramController = TextEditingController();
  final TextEditingController kgFiyatController = TextEditingController();
  final VoidCallback? onChanged;

  HamMadde({this.onChanged}) {
    adController.addListener(() => onChanged?.call());
    gramController.addListener(() => onChanged?.call());
    kgFiyatController.addListener(() => onChanged?.call());
  }

  void dispose() {
    adController.dispose();
    gramController.dispose();
    kgFiyatController.dispose();
  }

  Widget build(BuildContext context, int index, Function(int) onDelete) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ham Madde ${index + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                IconButton(
                  onPressed: () => onDelete(index),
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  tooltip: "Sil",
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: adController,
              decoration: InputDecoration(
                labelText: "Madde Adı",
                prefixIcon: Icon(Icons.label, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: gramController,
                    decoration: InputDecoration(
                      labelText: "Miktar (gr)",
                      prefixIcon: Icon(Icons.scale, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: kgFiyatController,
                    decoration: InputDecoration(
                      labelText: "1 kg Fiyat (₺)",
                      prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String name;
  final double value;
  final Color color;

  ChartData(this.name, this.value, this.color);
}
