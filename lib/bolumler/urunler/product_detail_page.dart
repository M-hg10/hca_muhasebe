import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hcastick/bolumler/urunler/urunlerdataservis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  double _quantity = 5; // Kaçar kaçar artacak/azalacak
  double _currentValue = 0; // Ekranda gösterilen miktar
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.birimFiyat;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sol Panel - Resim
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(60),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Hero(
                          tag: 'product-${widget.product.urunId}',
                          child: widget.product.birim.isNotEmpty
                              ? Image.network(
                                  widget.product.birim,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                )
                              : _buildImagePlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sağ Panel - Detaylar
        Expanded(
          flex: 4,
          child: Container(
            height: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildProductDetailsDesktop(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductHeaderDesktop(),
        const SizedBox(height: 40),
        _buildProductInfoDesktop(),
        const SizedBox(height: 40),
        _buildPriceSectionDesktop(),
        const SizedBox(height: 40),
        _buildQuantitySelectorDesktop(),
        const SizedBox(height: 50),
        _buildOrderButtonDesktop(),
      ],
    );
  }

  Widget _buildProductHeaderDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                widget.product.kategori,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                widget.product.marka,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          widget.product.urunAdi,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.product.kisaAciklama != null) ...[
          Text(
            widget.product.kisaAciklama!,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfoDesktop() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRowDesktop('Barkod', widget.product.barkod),
          const SizedBox(height: 20),
          _buildInfoRowDesktop('Kullanım Amacı', widget.product.tedarikci),
          const SizedBox(height: 20),
          _buildInfoRowDesktop('Kategori', widget.product.kategori),
          const SizedBox(height: 20),
          _buildInfoRowDesktop(
            'Stok Durumu',
            widget.product.stokMiktari > widget.product.kritikStokMiktari
                ? 'Stokta (${widget.product.stokMiktari} adet)'
                : 'Düşük Stok (${widget.product.stokMiktari} adet)',
            color: widget.product.stokMiktari > widget.product.kritikStokMiktari
                ? Colors.green
                : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowDesktop(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSectionDesktop() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fiyat',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.perakendeFiyat != null
                    ? '${widget.product.perakendeFiyat!.toStringAsFixed(2)} TL'
                    : 'Fiyat teklifi için iletişime geçin',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.product.perakendeFiyat != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelectorDesktop() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text(
            'Miktar:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: _currentValue - _quantity >= 0
                ? () => setState(() => _currentValue -= _quantity)
                : null,
          ),
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              _currentValue.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => setState(() => _currentValue += _quantity),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButtonDesktop() {
    return ScaleTransition(
      scale: _buttonAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 68,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _showOrderDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            elevation: 12,
            shadowColor: Colors.green.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      widget.product.perakendeFiyat != null
                          ? 'Sipariş Ver'
                          : 'Fiyat Teklifi Al',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Mobile Layout (Önceki kodun devamı)
  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildProductDetails(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'product-${widget.product.urunId}',
              child: widget.product.birim.isNotEmpty
                  ? Image.network(
                      widget.product.birim,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
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
            _buildProductHeader(),
            const SizedBox(height: 24),
            _buildProductInfo(),
            const SizedBox(height: 24),
            _buildPriceSection(),
            const SizedBox(height: 32),
            _buildQuantitySelector(),
            const SizedBox(height: 32),
            _buildOrderButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.product.kategori,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.product.marka,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.urunAdi,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.product.kisaAciklama != null) ...[
          Text(
            widget.product.kisaAciklama!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow('Barkod', widget.product.barkod),
          const Divider(height: 24),
          _buildInfoRow('Kullanım Amacı', widget.product.tedarikci),
          const Divider(height: 24),
          _buildInfoRow('Birim', widget.product.birim),
          const Divider(height: 24),
          _buildInfoRow(
            'Stok Durumu',
            widget.product.stokMiktari > widget.product.kritikStokMiktari
                ? 'Stokta (${widget.product.stokMiktari} adet)'
                : 'Düşük Stok (${widget.product.stokMiktari} adet)',
            color: widget.product.stokMiktari > widget.product.kritikStokMiktari
                ? Colors.green
                : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fiyat',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.perakendeFiyat != null
                    ? '${widget.product.perakendeFiyat!.toStringAsFixed(2)} TL'
                    : 'Fiyat teklifi için iletişime geçin',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.product.perakendeFiyat != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text(
            'Miktar:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: _currentValue - _quantity >= 0
                ? () => setState(() => _currentValue -= _quantity)
                : null,
          ),
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              _currentValue.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => setState(() => _currentValue += _quantity),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.green.shade600 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey.shade500,
          size: 18,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOrderButton() {
    return ScaleTransition(
      scale: _buttonAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _showOrderDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: Colors.green.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      widget.product.perakendeFiyat != null
                          ? 'Sipariş Ver'
                          : 'Fiyat Teklifi Al',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showOrderDialog() {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    if (isDesktop) {
      _showOrderDialogDesktop();
    } else {
      _showOrderDialogMobile();
    }
  }

  void _showOrderDialogDesktop() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sipariş Bilgileri',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          controller: _nameController,
                          label: 'Ad Soyad',
                          icon: Icons.person,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Ad soyad gerekli'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          controller: _phoneController,
                          label: 'Telefon',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Telefon gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _emailController,
                    label: 'E-posta',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'E-posta gerekli';
                      if (!value!.contains('@')) return 'Geçerli e-posta girin';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _addressController,
                    label: 'Adres',
                    icon: Icons.location_on,
                    maxLines: 3,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Adres gerekli' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: _notesController,
                    label: 'Notlar (Opsiyonel)',
                    icon: Icons.note,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sipariş Özeti',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ürün:',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                widget.product.urunAdi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Miktar:',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '$_currentValue adet',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (widget.product.perakendeFiyat != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam:',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${(widget.product.perakendeFiyat! * _currentValue).toStringAsFixed(2)} TL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.grey.shade700,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.green.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Siparişi Onayla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDialogMobile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sipariş Bilgileri',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildFormField(
                  controller: _nameController,
                  label: 'Ad Soyad',
                  icon: Icons.person,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ad soyad gerekli' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _phoneController,
                  label: 'Telefon',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Telefon gerekli' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _emailController,
                  label: 'E-posta',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'E-posta gerekli';
                    if (!value!.contains('@')) return 'Geçerli e-posta girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _addressController,
                  label: 'Adres',
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Adres gerekli' : null,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _notesController,
                  label: 'Notlar (Opsiyonel)',
                  icon: Icons.note,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sipariş Özeti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ürün:',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.product.urunAdi,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Miktar:',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$_currentValue adet',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (widget.product.perakendeFiyat != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam:',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${(widget.product.perakendeFiyat! * _currentValue).toStringAsFixed(2)} TL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.green.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Siparişi Onayla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Webhook’a gönderilecek sipariş verisi
      final siparis = {
        "kullanici": {
          "ad_soyad": _nameController.text.trim(),
          "telefon": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "adres": _addressController.text.trim(),
          "not": _notesController.text.trim(),
        },
        "urun": {
          "urun_id": widget.product.urunId,
          "barkod": widget.product.barkod,
          "urun_adi": widget.product.urunAdi,
          "kategori": widget.product.kategori,
          "marka": widget.product.marka,
          "tedarikci": widget.product.tedarikci,
          "birim": widget.product.birim,
          "birim_fiyat": widget.product.birimFiyat,
          "alis_fiyati": widget.product.alisFiyati,
          "kdv_orani": widget.product.kdvOrani,
          "stok_miktari": widget.product.stokMiktari,
          "kritik_stok_miktari": widget.product.kritikStokMiktari,
          "aktif": widget.product.aktif,
          "olusturma_tarihi": widget.product.olusturmaTarihi.toIso8601String(),
          "guncelleme_tarihi": widget.product.guncellemeTarihi
              .toIso8601String(),
          "aciklama": widget.product.aciklama,
          "toptan_fiyat": _currentValue,
          "perakende_fiyat": (widget.product.perakendeFiyat! * _quantity)
              .toStringAsFixed(2),
          "kisa_aciklama": widget.product.kisaAciklama,
        },
      };

      // 🌐 Webhook POST isteği
      final url = Uri.parse(
        'https://n8n.hggrup.com/webhook/c6350474-4617-4a57-9f90-f4dd445a6369',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(siparis),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Webhook başarıyla gönderildi.");
      } else {
        debugPrint("❌ Webhook gönderim hatası: ${response.statusCode}");
      }

      Navigator.of(context).pop(); // Dialog'u kapat
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(
        'Sipariş oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.',
      );
      debugPrint("🚨 Hata: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sipariş Başarılı!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.perakendeFiyat != null
                    ? 'Siparişiniz başarıyla alındı. En kısa sürede sizinle iletişime geçeceğiz.'
                    : 'Fiyat teklifi talebiniz alındı. En kısa sürede sizinle iletişime geçeceğiz.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Success dialog'u kapat
                    Navigator.of(
                      context,
                    ).pop(); // Product detail sayfasını kapat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.error, color: Colors.red.shade600, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hata!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
