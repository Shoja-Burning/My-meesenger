import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String projectId = 'pulsechat-20752';
const String baseUrl = 'https://googleapis.com';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseChatApp());
}

Route createSmoothRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.07, 0.0), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class FirestoreRest {
  static Map<String, dynamic> _parseFields(Map<String, dynamic>? fields) {
    if (fields == null) return {};
    final res = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v.containsKey('stringValue')) res[k] = v['stringValue'];
      else if (v.containsKey('booleanValue')) res[k] = v['booleanValue'];
      else if (v.containsKey('integerValue')) res[k] = int.tryParse(v['integerValue'].toString()) ?? 0;
    });
    return res;
  }

  static Map<String, dynamic> _toFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((k, v) {
      if (v is String) fields[k] = {'stringValue': v};
      else if (v is bool) fields[k] = {'booleanValue': v};
      else if (v is int) fields[k] = {'integerValue': v.toString()};
    });
    return {'fields': fields};
  }

  static Future<Map<String, dynamic>?> getDoc(String path) async {
    final res = await http.get(Uri.parse('$baseUrl/$path')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return _parseFields(jsonDecode(res.body)['fields']);
    if (res.statusCode == 404) return null;
    throw Exception('Ошибка сервера (${res.statusCode})');
  }

  static Future<void> setDoc(String path, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_toFields(data)),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Ошибка сохранения (${res.statusCode})');
  }

  static Future<void> addDoc(String collectionPath, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$collectionPath'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_toFields(data)),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Ошибка отправки (${res.statusCode})');
  }

  static Future<void> deleteDoc(String fullPath) async {
    await http.delete(Uri.parse('$baseUrl/$fullPath')).timeout(const Duration(seconds: 10));
  }

  static Future<List<Map<String, dynamic>>> getCollection(String collectionPath) async {
    final res = await http.get(Uri.parse('$baseUrl/$collectionPath?pageSize=100')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final docs = (jsonDecode(res.body)['documents'] as List?) ?? [];
      return docs.map((d) {
        final parsed = _parseFields(d['fields']);
        parsed['_id'] = (d['name'] as String).split('/').last;
        return parsed;
      }).toList();
    }
    return [];
  }
}

class ShopItem {
  final String id;
  final String name;
  final String type;
  final int price;
  final List<Color> colors;
  final IconData icon;
  const ShopItem({required this.id, required this.name, required this.type, required this.price, required this.colors, required this.icon});
}

class ShopCatalog {
  static const List<ShopItem> backgrounds = [
    ShopItem(id: 'bg_default', name: 'Стандарт', type: 'bg', price: 0, colors: [Color(0xFF1E293B), Color(0xFF0F172A)], icon: Icons.layers),
    ShopItem(id: 'bg_cyber', name: 'Киберпанк Неон', type: 'bg', price: 20, colors: [Color(0xFFEC4899), Color(0xFF6366F1), Color(0xFF06B6D4)], icon: Icons.bolt),
    ShopItem(id: 'bg_sunset', name: 'Золотой Закат', type: 'bg', price: 30, colors: [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF7C3AED)], icon: Icons.wb_twilight),
    ShopItem(id: 'bg_matrix', name: 'Изумрудный Код', type: 'bg', price: 40, colors: [Color(0xFF059669), Color(0xFF064E3B), Color(0xFF10B981)], icon: Icons.code),
    ShopItem(id: 'bg_royal', name: 'Королевский Аметист', type: 'bg', price: 60, colors: [Color(0xFF7E22CE), Color(0xFFD97706), Color(0xFF1E1B4B)], icon: Icons.auto_awesome),
  ];

  static const List<ShopItem> frames = [
    ShopItem(id: 'frame_none', name: 'Без рамки', type: 'frame', price: 0, colors: [Colors.transparent, Colors.transparent], icon: Icons.circle_outlined),
    ShopItem(id: 'frame_neon', name: 'Неоновый Пульс', type: 'frame', price: 15, colors: [Color(0xFF00F5D4), Color(0xFF6366F1), Color(0xFF00F5D4)], icon: Icons.blur_circular),
    ShopItem(id: 'frame_fire', name: 'Огненное Кольцо', type: 'frame', price: 25, colors: [Color(0xFFFACC15), Color(0xFFEF4444), Color(0xFFF97316)], icon: Icons.local_fire_department),
    ShopItem(id: 'frame_rgb', name: 'Discord RGB', type: 'frame', price: 40, colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red], icon: Icons.all_inclusive),
    ShopItem(id: 'frame_crown', name: 'Золото Создателя', type: 'frame', price: 50, colors: [Color(0xFFFDE047), Color(0xFFD97706), Color(0xFFFEF08A)], icon: Icons.workspace_premium),
  ];

  static ShopItem getBg(String? id) => backgrounds.firstWhere((e) => e.id == id, orElse: () => backgrounds.first);
  static ShopItem getFrame(String? id) => frames.firstWhere((e) => e.id == id, orElse: () => frames.first);
}

class ProfileBanner extends StatelessWidget {
  final String? bgId;
  final Widget child;
  const ProfileBanner({super.key, required this.bgId, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = ShopCatalog.getBg(bgId);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg.colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: bg.colors.first.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class UserAvatar extends StatefulWidget {
  final String base64Str;
  final String name;
  final double radius;
  final String? frameId;
  const UserAvatar({super.key, required this.base64Str, required this.name, this.radius = 22, this.frameId});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = ShopCatalog.getFrame(widget.frameId);
    final hasFrame = frame.id != 'frame_none';

    Widget avatarCore;
    if (widget.base64Str.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(widget.base64Str);
        avatarCore = CircleAvatar(radius: widget.radius, backgroundImage: MemoryImage(bytes));
      } catch (_) {
        avatarCore = _fallbackAvatar();
      }
    } else {
      avatarCore = _fallbackAvatar();
    }

    if (!hasFrame) return avatarCore;

    final borderThickness = (widget.radius * 0.14).clamp(2.5, 5.5);
    return AnimatedBuilder(
      animation: _rotCtrl,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(borderThickness),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: frame.colors,
              transform: GradientRotation(_rotCtrl.value * 2 * math.pi),
            ),
            boxShadow: [BoxShadow(color: frame.colors.first.withOpacity(0.45), blurRadius: 10)],
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0B1120)),
            child: child,
          ),
        );
      },
      child: avatarCore,
    );
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: const Color(0xFF334155),
      child: Text(
        widget.name.isNotEmpty ? widget.name.toUpperCase() : '?',
        style: TextStyle(fontSize: widget.radius * 0.85, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class PulseChatApp extends StatefulWidget {
  const PulseChatApp({super.key});
  static _PulseChatAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_PulseChatAppState>();
  @override
  State<PulseChatApp> createState() => _PulseChatAppState();
}

class _PulseChatAppState extends State<PulseChatApp> {
  Color _accentColor = const Color(0xFF6366F1);
  double _fontSize = 16.0;
  bool _isDark = true;

  Color get accentColor => _accentColor;
  double get fontSize => _fontSize;
  bool get isDark => _isDark;

  void updateTheme({Color? color, double? size, bool? dark}) {
    setState(() {
      if (color != null) _accentColor = color;
      if (size != null) _fontSize = size;
      if (dark != null) _isDark = dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _isDark
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0B1120),
            primaryColor: _accentColor,
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF151F32), elevation: 0),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF1F5F9),
            primaryColor: _accentColor,
            appBarTheme: AppBarTheme(backgroundColor: _accentColor, elevation: 0),
          );

    return MaterialApp(
      title: 'PulseChat',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      builder: (context, child) => AnimatedTheme(data: themeData, duration: const Duration(milliseconds: 400), child: child!),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _nickController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nick = _nickController.text.trim();
    final pass = _passController.text.trim();
    if (nick.length < 3 || nick.length > 18) {
      setState(() => _error = 'Ник от 3 до 18 символов');
      return;
    }
    if (pass.length < 4) {
      setState(() => _error = 'Пароль минимум 4 символа');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final nickLower = nick.toLowerCase();
    try {
      final doc = await FirestoreRest.getDoc('users/$nickLower');
      if (_isLogin) {
        if (doc == null) {
          setState(() => _error = 'Пользователь не найден');
        } else if (doc['password'] != pass) {
          setState(() => _error = 'Неверный пароль');
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(context, createSmoothRoute(HomeScreen(currentUserId: nickLower)));
        }
      } else {
        if (doc != null) {
          setState(() => _error = 'Ник уже занят');
        } else {
          final allUsers = await FirestoreRest.getCollection('users');
          final isCreator = allUsers.isEmpty;
          await FirestoreRest.setDoc('users/$nickLower', {
            'username': nick,
            'usernameLower': nickLower,
            'password': pass,
            'bio': isCreator ? 'Создатель PulseChat 👑' : 'На связи в PulseChat ⚡',
            'avatarBase64': '',
            'isCreator': isCreator,
            'showOnline': true,
            'xp': isCreator ? 100 : 20,
            'ownedItems': 'bg_default,frame_none',
            'activeBg': 'bg_default',
            'activeFrame': 'frame_none',
          });
          if (!mounted) return;
          Navigator.pushReplacement(context, createSmoothRoute(HomeScreen(currentUserId: nickLower)));
        }
      }
    } catch (e) {
      setState(() => _error = 'Ошибка связи с сервером');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF0B1120), accent.withOpacity(0.22), const Color(0xFF0B1120)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.92, end: 1.08).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.16),
                        boxShadow: [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 32, spreadRadius: 4)],
                      ),
                      child: Icon(Icons.bolt, size: 64, color: accent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('PulseChat', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_isLogin ? 'Вход в аккаунт' : 'Регистрация (+20 XP бонус ⚡)', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nickController,
                    maxLength: 18,
                    decoration: InputDecoration(
                      labelText: 'Никнейм',
                      prefixIcon: const Icon(Icons.alternate_email),
                      filled: true,
                      fillColor: const Color(0xFF151F32),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: const Color(0xFF151F32),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  if (_error != null)
                    Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isLogin ? 'Войти' : 'Создать аккаунт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                    child: Text(_isLogin ? 'Нет аккаунта? Регистрация' : 'Уже есть аккаунт? Войти'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  Map<String, dynamic>? _me;
  List<Map<String, dynamic>> _users = [];
  Timer? _syncTimer;
  Timer? _xpTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) => _loadData());
    _xpTimer = Timer.periodic(const Duration(minutes: 10), (_) => _reward10MinXp());
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _xpTimer?.cancel();
    super.dispose();
  }

  Future<void> _reward10MinXp() async {
    if (_me == null) return;
    final currentXp = (_me!['xp'] as int?) ?? 0;
    final updated = Map<String, dynamic>.from(_me!);
    updated['xp'] = currentXp + 10;
    await FirestoreRest.setDoc('users/${widget.currentUserId}', updated);
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ +10 XP за 10 минут активности в PulseChat!'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final me = await FirestoreRest.getDoc('users/${widget.currentUserId}');
      final all = await FirestoreRest.getCollection('users');
      if (!mounted) return;
      setState(() {
        _me = me;
        _users = all;
      });
    } catch (_) {}
  }

  String _getChatId(String u1, String u2) {
    final list = [u1, u2]..sort();
    return '${list}_${list}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    if (_me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final me = _me!;
    final xp = (me['xp'] as int?) ?? 0;

    final filtered = _users.where((data) {
      if (data['usernameLower'] == widget.currentUserId) return false;
      if (_searchQuery.isEmpty) return true;
      return (data['usernameLower'] ?? '').toString().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Colors.amber),
            SizedBox(width: 6),
            Text('PulseChat', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, createSmoothRoute(ShopScreen(userId: widget.currentUserId)));
              _loadData();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text('$xp XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, createSmoothRoute(SettingsScreen(userId: widget.currentUserId)));
              _loadData();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF151F32),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ProfileBanner(
              bgId: me['activeBg'],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(base64Str: me['avatarBase64'] ?? '', name: me['username'] ?? '', radius: 34, frameId: me['activeFrame']),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(me['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)),
                        if (me['isCreator'] == true) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.verified, color: Colors.amber, size: 18)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(me['bio'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Chip(label: Text('⚡ Баланс: $xp XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), backgroundColor: Colors.black45),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: Colors.amber),
              title: const Text('Магазин фонов и рамок'),
              subtitle: const Text('+10 XP каждые 10 мин онлайн'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, createSmoothRoute(ShopScreen(userId: widget.currentUserId)));
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Общий чат PulseChat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, createSmoothRoute(ChatRoomScreen(chatId: 'global_chat', chatTitle: 'Общий чат ⚡', currentUser: me, isGlobal: true)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Мой профиль и настройки'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, createSmoothRoute(SettingsScreen(userId: widget.currentUserId)));
                _loadData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Выйти', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pushAndRemoveUntil(context, createSmoothRoute(const AuthScreen()), (_) => false),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Поиск людей по нику...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF151F32),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: accent, child: const Icon(Icons.bolt, color: Colors.white)),
            title: const Text('Общий чат PulseChat', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Глобальный канал всех пользователей'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.push(context, createSmoothRoute(ChatRoomScreen(chatId: 'global_chat', chatTitle: 'Общий чат ⚡', currentUser: me, isGlobal: true))),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Пока никого нет. Позови друзей!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final target = filtered[i];
                      return ListTile(
                        leading: UserAvatar(
                          base64Str: target['avatarBase64'] ?? '',
                          name: target['username'] ?? '',
                          frameId: target['activeFrame'],
                        ),
                        title: Row(
                          children: [
                            Text(target['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (target['isCreator'] == true)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: const Text('👑 Создатель', style: TextStyle(fontSize: 11, color: Colors.amber)),
                              ),
                          ],
                        ),
                        subtitle: Text(target['bio'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          final chatId = _getChatId(widget.currentUserId, target['usernameLower']);
Navigator.push(context, createSmoothRoute(ChatRoomScreen(chatId: chatId, chatTitle: target['username'], currentUser: me, targetUser: target)));
},
);
},
),
),
],
),
);
}
}

class ShopScreen extends StatefulWidget {
  final String userId;
  const ShopScreen({super.key, required this.userId});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Map<String, dynamic>? _user;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await FirestoreRest.getDoc('users/${widget.userId}');
    if (!mounted) return;
    setState(() => _user = u);
  }

  Future<void> _buyOrEquip(ShopItem item) async {
    if (_user == null || _busy) return;
    final xp = (_user!['xp'] as int?) ?? 0;
    final ownedStr = (_user!['ownedItems'] as String?) ?? 'bg_default,frame_none';
    final owned = ownedStr.split(',').where((e) => e.isNotEmpty).toSet();

    if (owned.contains(item.id)) {
      setState(() => _busy = true);
      final updated = Map<String, dynamic>.from(_user!);
      if (item.type == 'bg') updated['activeBg'] = item.id;
      if (item.type == 'frame') updated['activeFrame'] = item.id;
      await FirestoreRest.setDoc('users/${widget.userId}', updated);
      await _load();
      setState(() => _busy = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Надето: ${item.name} ✨')));
      return;
    }

    if (xp < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не хватает XP! Нужно ${item.price} XP (у тебя $xp XP). Проведи ещё немного времени в сети ⚡'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _busy = true);
    owned.add(item.id);
    final updated = Map<String, dynamic>.from(_user!);
    updated['xp'] = xp - item.price;
    updated['ownedItems'] = owned.join(',');
    if (item.type == 'bg') updated['activeBg'] = item.id;
    if (item.type == 'frame') updated['activeFrame'] = item.id;

    await FirestoreRest.setDoc('users/${widget.userId}', updated);
    await _load();
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Куплено и надето: ${item.name} 🎉'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = _user!;
    final xp = (user['xp'] as int?) ?? 0;
    final owned = ((user['ownedItems'] as String?) ?? 'bg_default,frame_none').split(',').toSet();
    final activeBg = user['activeBg'] ?? 'bg_default';
    final activeFrame = user['activeFrame'] ?? 'frame_none';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин PulseChat'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('⚡ $xp XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileBanner(
            bgId: activeBg,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  UserAvatar(base64Str: user['avatarBase64'] ?? '', name: user['username'] ?? '', radius: 36, frameId: activeFrame),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['username'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Предпросмотр твоего стиля', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        const Text('+10 XP начисляются каждые 10 мин в сети', style: TextStyle(color: Colors.amber, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('🎨 Фоны профиля (Баннеры)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...ShopCatalog.backgrounds.map((item) => _buildItemCard(item, owned.contains(item.id), activeBg == item.id, user)),
          const SizedBox(height: 24),
          const Text('💫 Обводки аватарок (как в Discord)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...ShopCatalog.frames.map((item) => _buildItemCard(item, owned.contains(item.id), activeFrame == item.id, user)),
        ],
      ),
    );
  }

  Widget _buildItemCard(ShopItem item, bool isOwned, bool isEquipped, Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151F32),
        borderRadius: BorderRadius.circular(16),
        border: isEquipped ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Row(
        children: [
          if (item.type == 'bg')
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: item.colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: Colors.white),
            )
          else
            UserAvatar(base64Str: user['avatarBase64'] ?? '', name: user['username'] ?? '', radius: 22, frameId: item.id),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  isEquipped ? 'Надето сейчас' : (isOwned ? 'Куплено' : 'Цена: ${item.price} XP'),
                  style: TextStyle(color: isEquipped ? Colors.amber : Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isEquipped ? null : () => _buyOrEquip(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwned ? const Color(0xFF334155) : Colors.amber,
              foregroundColor: isOwned ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEquipped ? 'Активно' : (isOwned ? 'Надеть' : '${item.price} XP'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String chatTitle;
  final Map<String, dynamic> currentUser;
  final Map<String, dynamic>? targetUser;
  final bool isGlobal;
  const ChatRoomScreen({super.key, required this.chatId, required this.chatTitle, required this.currentUser, this.targetUser, this.isGlobal = false});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgController = TextEditingController();
  List<Map<String, dynamic>> _msgs = [];
  Timer? _timer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMsgs();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _loadMsgs());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMsgs() async {
    try {
      final list = await FirestoreRest.getCollection('chats/${widget.chatId}/messages');
      list.sort((a, b) => (b['ts'] ?? 0).compareTo(a['ts'] ?? 0));
      if (!mounted) return;
      setState(() => _msgs = list);
    } catch (_) {}
  }

  Future<void> _send({String imageBase64 = ''}) async {
    final text = _msgController.text.trim();
    if (text.isEmpty && imageBase64.isEmpty) return;
    if (_sending) return;
    _msgController.clear();
    setState(() => _sending = true);
    try {
      await FirestoreRest.addDoc('chats/${widget.chatId}/messages', {
        'senderId': widget.currentUser['usernameLower'],
        'senderName': widget.currentUser['username'],
        'isCreator': widget.currentUser['isCreator'] == true,
        'text': text,
        'imageBase64': imageBase64,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await _loadMsgs();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickAndSendPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 650, imageQuality: 65);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _send(imageBase64: base64Encode(bytes));
  }

  Future<void> _deleteMessage(String docId) async {
    await FirestoreRest.deleteDoc('chats/${widget.chatId}/messages/$docId');
    _loadMsgs();
  }

  void _showUserProfileModal(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ProfileBanner(
          bgId: user['activeBg'],
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(base64Str: user['avatarBase64'] ?? '', name: user['username'] ?? '', radius: 44, frameId: user['activeFrame']),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user['username'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (user['isCreator'] == true) ...[
                      const SizedBox(width: 6),
                      const Chip(label: Text('👑 Создатель', style: TextStyle(color: Colors.amber)), backgroundColor: Colors.black45),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(user['bio'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 12),
                Chip(label: Text('⚡ Опыт: ${user['xp'] ?? 0} XP', style: const TextStyle(color: Colors.amber)), backgroundColor: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final fontSize = PulseChatApp.of(context)?.fontSize ?? 16.0;
    final amICreator = widget.currentUser['isCreator'] == true;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: widget.targetUser != null ? () => _showUserProfileModal(widget.targetUser!) : null,
          child: Row(
            children: [
              if (widget.targetUser != null) ...[
                UserAvatar(
                  base64Str: widget.targetUser!['avatarBase64'] ?? '',
                  name: widget.targetUser!['username'] ?? '',
                  radius: 17,
                  frameId: widget.targetUser!['activeFrame'],
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.chatTitle, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17)),
                    if (widget.targetUser != null)
                      const Text('Нажми, чтобы открыть профиль', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(14),
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final data = _msgs[i];
                final isMe = data['senderId'] == widget.currentUser['usernameLower'];
                final canDelete = isMe || amICreator;
                final imgStr = (data['imageBase64'] as String?) ?? '';

                return TweenAnimationBuilder<double>(
                  key: ValueKey(data['_id'] ?? i),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, val, child) => Opacity(
                    opacity: val.clamp(0.0, 1.0),
                    child: Transform.translate(offset: Offset(0, 14 * (1 - val)), child: child),
                  ),
                  child: GestureDetector(
                    onLongPress: canDelete
                        ? () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Удалить сообщение?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                                  TextButton(
                                    onPressed: () {
                                      _deleteMessage(data['_id']);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        decoration: BoxDecoration(
                          gradient: isMe ? LinearGradient(colors: [accent, accent.withOpacity(0.82)]) : null,
                          color: isMe ? null : const Color(0xFF151F32),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe && widget.isGlobal)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('${data['senderName']} ${data['isCreator'] == true ? '👑' : ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ),
                            if (imgStr.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        backgroundColor: Colors.black,
                                        appBar: AppBar(backgroundColor: Colors.black),
                                        body: Center(child: InteractiveViewer(child: Image.memory(base64Decode(imgStr)))),
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(base64Decode(imgStr), fit: BoxFit.cover),
                                ),
                              ),
                            if ((data['text'] ?? '').toString().isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: imgStr.isNotEmpty ? 6 : 0, left: 4, right: 4),
                                child: Text(data['text'] ?? '', style: TextStyle(fontSize: fontSize, color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: const Color(0xFF151F32),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_library_rounded, color: accent, size: 28),
                    onPressed: _sending ? null : _pickAndSendPhoto,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Сообщение...',
                        filled: true,
                        fillColor: const Color(0xFF0B1120),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accent,
                    child: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () => _send()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String userId;
  const SettingsScreen({super.key, required this.userId});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bioController = TextEditingController();
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await FirestoreRest.getDoc('users/${widget.userId}');
    if (!mounted) return;
    setState(() {
      _user = u;
      _bioController.text = u?['bio'] ?? '';
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 250, imageQuality: 70);
    if (file == null || _user == null) return;
    final bytes = await file.readAsBytes();
    final updated = Map<String, dynamic>.from(_user!);
    updated['avatarBase64'] = base64Encode(bytes);
    await FirestoreRest.setDoc('users/${widget.userId}', updated);
    _loadUser();
  }

  Future<void> _saveBio() async {
    if (_user == null) return;
    final updated = Map<String, dynamic>.from(_user!);
    updated['bio'] = _bioController.text.trim();
    await FirestoreRest.setDoc('users/${widget.userId}', updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio сохранено!')));
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final appState = PulseChatApp.of(context)!;
    if (_user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = _user!;
    final xp = (user['xp'] as int?) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль и Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileBanner(
            bgId: user['activeBg'],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        base64Str: user['avatarBase64'] ?? '',
                        name: user['username'] ?? '',
                        radius: 48,
                        frameId: user['activeFrame'],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: appState.accentColor,
                          child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20), onPressed: _pickAvatar),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user['username'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (user['isCreator'] == true) ...[
                        const SizedBox(width: 6),
                        const Chip(label: Text('👑 Создатель', style: TextStyle(color: Colors.amber)), backgroundColor: Colors.black45),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, createSmoothRoute(ShopScreen(userId: widget.userId)));
                      _loadUser();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    icon: const Icon(Icons.storefront),
                    label: Text('Магазин стилей (⚡ $xp XP)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('О себе (Bio)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bioController,
                  maxLength: 70,
                  decoration: InputDecoration(
                    hintText: 'Напиши о себе...',
                    filled: true,
                    fillColor: const Color(0xFF151F32),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.check_circle, color: appState.accentColor, size: 36), onPressed: _saveBio),
            ],
          ),
          const Divider(height: 32),
          const Text('Цвет интерфейса', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _colorBtn(appState, const Color(0xFF6366F1)),
              _colorBtn(appState, const Color(0xFF0EA5E9)),
              _colorBtn(appState, const Color(0xFF10B981)),
              _colorBtn(appState, const Color(0xFFEC4899)),
              _colorBtn(appState, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 18),
          SwitchListTile(
            title: const Text('Темная тема'),
            value: appState.isDark,
            onChanged: (v) => appState.updateTheme(dark: v),
          ),
          ListTile(
            title: Text('Размер шрифта: ${appState.fontSize.toInt()}'),
            subtitle: Slider(min: 12, max: 24, value: appState.fontSize, onChanged: (v) => appState.updateTheme(size: v)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pushAndRemoveUntil(context, createSmoothRoute(const AuthScreen()), (_) => false),
          ),
        ],
      ),
    );
  }

  Widget _colorBtn(_PulseChatAppState appState, Color color) {
    final selected = appState.accentColor == color;
    return GestureDetector(
      onTap: () => appState.updateTheme(color: color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(selected ? 3 : 0),
        decoration: BoxDecoration(shape: BoxShape.circle, border: selected ? Border.all(color: Colors.white, width: 2.5) : null),
        child: CircleAvatar(backgroundColor: color, radius: 20, child: selected ? const Icon(Icons.check, color: Colors.white) : null),
      ),
    );
  }
}
