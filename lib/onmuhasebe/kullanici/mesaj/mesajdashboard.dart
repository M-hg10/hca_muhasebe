// lib/pages/messages_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/mesaj/alicilist.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Mesaj modeli
class Message {
  final int id;
  final String konu;
  final String icerik;
  final String? karsidaki;
  final DateTime createdAt;
  final bool isUnread;
  final String type;

  factory Message.fromJson(Map<String, dynamic> j, String type) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return Message._(
      id: (j['id'] ?? j['message_id'] ?? 0) as int,
      konu: (j['konu'] ?? j['subject'] ?? '').toString(),
      icerik: (j['mesaj'] ?? j['message'] ?? '').toString(),
      karsidaki: (j['gonderen'] ?? j['alici'] ?? j['user'] ?? j['name'])
          ?.toString(),
      createdAt: parseDate(j['created_at']),
      isUnread: (j['is_unread'] ?? j['okundu'] == false) ? true : false,
      type: type,
    );
  }

  const Message._({
    required this.id,
    required this.konu,
    required this.icerik,
    required this.createdAt,
    required this.isUnread,
    required this.type,
    this.karsidaki,
  });
}

/// Api servis
class ApiService {
  final String base;
  ApiService(this.base);

  Future<void> markAsRead(int firmaId, int kullaniciId, int mesajId) async {
    final url = Uri.parse(
      'https://n8n.hggrup.com/webhook/c8c3cff8-cb47-42a7-ad42-c0d9466cc5ee',
    );
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firma_id': firmaId,
        'kullanici_id': kullaniciId,
        'mesaj_id': mesajId,
      }),
    );
  }

  Future<List<Message>> fetchMessages({
    required int firmaId,
    required int kullaniciId,
    required String type,
  }) async {
    final url = Uri.parse(
      'https://n8n.hggrup.com/webhook/bb2c8b8e-6c70-4a18-8f41-f439e9ecfc95',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firma_id': firmaId,
        'kullanici_id': kullaniciId,
        'type': type,
      }),
    );

    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return list.map((e) => Message.fromJson(e, type)).toList();
  }
}

/// Ana sayfa
class MessagesPage extends StatefulWidget {
  final int firmaId;
  final int kullaniciId;
  final String n8nBaseUrl;
  final Duration pollInterval;

  const MessagesPage({
    super.key,
    required this.firmaId,
    required this.kullaniciId,
    required this.n8nBaseUrl,
    this.pollInterval = const Duration(seconds: 10),
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late final ApiService api;
  Timer? _timer;

  List<Message> _group = [];
  List<Message> _inbox = [];
  List<Message> _sent = [];

  bool _loading = false;
  String? _error;

  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    api = ApiService(widget.n8nBaseUrl);
    _fetchAll(initial: true);
    // _timer = Timer.periodic(widget.pollInterval, (_) => _fetchAll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAll({bool initial = false}) async {
    if (!mounted) return;
    setState(() {
      _loading = initial ? true : _loading;
      _error = null;
    });
    try {
      final results = await Future.wait([
        api.fetchMessages(
          firmaId: widget.firmaId,
          kullaniciId: widget.kullaniciId,
          type: "group",
        ),
        api.fetchMessages(
          firmaId: widget.firmaId,
          kullaniciId: widget.kullaniciId,
          type: "direct",
        ),
        api.fetchMessages(
          firmaId: widget.firmaId,
          kullaniciId: widget.kullaniciId,
          type: "sent",
        ),
      ]);

      setState(() {
        _group = results[0];
        _inbox = results[1];
        _sent = results[2];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Veri alınamadı: $e';
        _loading = false;
      });
    }
  }

  // Liste render
  Widget _buildList(List<Message> data, {required String emptyText}) {
    if (_loading && data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (data.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, i) {
          final m = data[i];
          return _AnimatedMessageCard(
            api: ApiService('https://n8n.hggrup.com'),
            key: ValueKey(m.id),
            message: m,
            baseColor: _getBaseColor(m),
            pulseColor: _getPulseColor(m),
          );
        },
      ),
    );
  }

  Color _getBaseColor(Message m) {
    if (m.isUnread) {
      switch (m.type) {
        case 'group':
          return Colors.deepPurple.shade200;
        case 'direct':
          return Colors.teal.shade200;
        case 'sent':
          return Colors.blue.shade100;
        default:
          return Colors.orange.shade200;
      }
    } else {
      switch (m.type) {
        case 'group':
          return Colors.deepPurple.shade50;
        case 'direct':
          return Colors.teal.shade50;
        case 'sent':
          return Colors.blueGrey.shade50;
        default:
          return Colors.grey.shade100;
      }
    }
  }

  Color _getPulseColor(Message m) {
    if (m.isUnread) {
      switch (m.type) {
        case 'group':
          return Colors.deepPurple.shade300;
        case 'direct':
          return Colors.teal.shade300;
        case 'sent':
          return Colors.blue.shade200;
        default:
          return Colors.orange.shade300;
      }
    } else {
      switch (m.type) {
        case 'group':
          return Colors.deepPurple.shade100;
        case 'direct':
          return Colors.teal.shade100;
        case 'sent':
          return Colors.blueGrey.shade100;
        default:
          return Colors.grey.shade200;
      }
    }
  }

  int get _groupUnreadCount => _group.where((e) => e.isUnread).length;
  int get _inboxUnreadCount => _inbox.where((e) => e.isUnread).length;
  int get _sentCount => _sent.length;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabInfo(
        title: 'Grup',
        icon: Icons.groups_2_rounded,
        badge: _groupUnreadCount,
      ),
      _TabInfo(
        title: 'Gelen',
        icon: Icons.inbox_rounded,
        badge: _inboxUnreadCount,
      ),
      _TabInfo(title: 'Giden', icon: Icons.send_rounded, badge: _sentCount),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Mesajlar'),
          actions: [
            IconButton(
              tooltip: 'Yenile',
              onPressed: _fetchAll,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: TabBar(
            tabs: [
              for (final t in tabs)
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.icon),
                      const SizedBox(width: 6),
                      Text(t.title),
                      if (t.badge > 0) ...[
                        const SizedBox(width: 6),
                        _Badge(count: t.badge),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_group, emptyText: 'Grup mesajı yok'),
            _buildList(_inbox, emptyText: 'Yeni gelen mesaj yok'),
            _buildList(_sent, emptyText: 'Gönderilmiş mesaj yok'),
          ],
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          childrenAnimation: ExpandableFabAnimation.none,
          distance: 70,
          overlayStyle: ExpandableFabOverlayStyle(
            color: Colors.white.withOpacity(0.9),
          ),
          children: [
            Row(
              children: [
                const Text('Güncelle'),
                const SizedBox(width: 20),
                FloatingActionButton.small(
                  heroTag: null,
                  onPressed: _fetchAll,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Mail Gönder'),
                const SizedBox(width: 20),
                FloatingActionButton.small(
                  heroTag: null,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AliciListesiSayfasi(),
                    ),
                  ),
                  child: const Icon(Icons.email),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabInfo {
  final String title;
  final IconData icon;
  final int badge;
  _TabInfo({required this.title, required this.icon, required this.badge});
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AnimatedMessageCard extends StatefulWidget {
  final Message message;
  final Color baseColor;
  final Color pulseColor;
  final ApiService api;

  const _AnimatedMessageCard({
    super.key,
    required this.message,
    required this.baseColor,
    required this.pulseColor,
    required this.api,
  });

  @override
  State<_AnimatedMessageCard> createState() => _AnimatedMessageCardState();
}

class _AnimatedMessageCardState extends State<_AnimatedMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Color?> _bg;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bg = ColorTween(
      begin: widget.pulseColor,
      end: widget.baseColor,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedMessageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _c
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final date = DateFormat('dd.MM.yyyy HH:mm').format(m.createdAt);

    return AnimatedBuilder(
      animation: _bg,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          decoration: BoxDecoration(
            color: _bg.value,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 3),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: CircleAvatar(
              child: Icon(
                m.type == 'group'
                    ? Icons.groups_rounded
                    : (m.type == 'sent'
                          ? Icons.north_east_rounded
                          : Icons.person_rounded),
              ),
            ),
            title: Text(
              m.konu.isNotEmpty ? m.konu : '(Konu yok)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: m.isUnread ? FontWeight.w700 : FontWeight.w400,
                color: m.isUnread ? Colors.black : Colors.black54,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.karsidaki != null && m.karsidaki!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      m.type == 'sent'
                          ? 'Alıcı: ${m.karsidaki}'
                          : 'Gönderen: ${m.karsidaki}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                Text(m.icerik, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: const TextStyle(fontSize: 12)),
                    if (m.isUnread) const _UnreadDot(),
                  ],
                ),
              ],
            ),
            onTap: () async {
              try {
                await widget.api.markAsRead(
                  aktifKullanici.firma.id,
                  aktifKullanici.id,
                  m.id,
                );
                setState(() {
                  m.isUnread == false;
                });
              } catch (e) {
                debugPrint("Okundu bilgisi gönderilemedi: $e");
              }
            },
          ),
        );
      },
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}
