import 'package:flutter/material.dart';

class WhyChooseUsWidget extends StatefulWidget {
  const WhyChooseUsWidget({Key? key}) : super(key: key);

  @override
  State<WhyChooseUsWidget> createState() => _WhyChooseUsWidgetState();
}

class _WhyChooseUsWidgetState extends State<WhyChooseUsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
          ),
        )
        .toList();

    // Start animations with delay
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Main Title
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Text(
              'Neden Bizi Seçmelisiniz?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Features Grid
          LayoutBuilder(
            builder: (context, constraints) {
              return _buildResponsiveGrid(context, constraints);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    // Determine grid layout based on screen width
    int crossAxisCount = 1;
    double childAspectRatio = 1.2;

    if (constraints.maxWidth >= 1200) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else if (constraints.maxWidth >= 768) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
    }

    if (crossAxisCount == 1) {
      // Mobile layout - Column
      return Column(
        children: [
          _buildFeatureCard(context, 0),
          const SizedBox(height: 24),
          _buildFeatureCard(context, 1),
          const SizedBox(height: 24),
          _buildFeatureCard(context, 2),
        ],
      );
    } else {
      // Tablet/Desktop layout - Grid
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24.0,
          mainAxisSpacing: 24.0,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: 3,
        itemBuilder: (context, index) => _buildFeatureCard(context, index),
      );
    }
  }

  Widget _buildFeatureCard(BuildContext context, int index) {
    final features = [
      {
        'icon': '✂️',
        'title': 'Özel Tasarım',
        'description': 'Markanıza özel tasarım ve baskı seçenekleri',
        'color': const Color(0xFFff6b6b),
        'gradient': const LinearGradient(
          colors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
        ),
      },
      {
        'icon': '⚡',
        'title': 'Kaliteli Üretim',
        'description': 'Modern makine parkuru ile profesyonel dolum hizmeti',
        'color': const Color(0xFF4ecdc4),
        'gradient': const LinearGradient(
          colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
        ),
      },
      {
        'icon': '🚀',
        'title': 'Hızlı Teslimat',
        'description': 'Zamanında ve güvenilir teslimat garantisi',
        'color': const Color(0xFFff8a65),
        'gradient': const LinearGradient(
          colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
        ),
      },
    ];

    final feature = features[index];

    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animations[index].value)),
          child: Opacity(
            opacity: _animations[index].value,
            child: _FeatureCard(
              icon: feature['icon'] as String,
              title: feature['title'] as String,
              description: feature['description'] as String,
              iconColor: feature['color'] as Color,
              iconGradient: feature['gradient'] as LinearGradient,
            ),
          ),
        );
      },
    );
  }

  double _getResponsiveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 28;
    if (width < 1200) return 32;
    return 36;
  }
}

class _FeatureCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final Color iconColor;
  final LinearGradient iconGradient;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconGradient,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            child: Card(
              elevation: _elevationAnimation.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white.withOpacity(0.95)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: widget.iconGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2d3748),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF718096),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
