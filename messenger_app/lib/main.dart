import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String projectId = 'pulsechat-cc903';
const String baseUrl = 'https://googleapis.com';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseChatApp());
}

Route createSmoothRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.08, 0.0), end: Offset.zero).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
            child: child,
          ),
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
      builder: (context, child) {
        return AnimatedTheme(
          data: themeData,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          child: child!,
        );
      },
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
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nick = _nickController.text.trim();
    final pass = _passController.text.trim();
    if (nick.length < 3 || nick.length > 18) {
      setState(() => _error = 'Ник должен быть от 3 до 18 символов');
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
          setState(() => _error = 'Этот ник уже занят');
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
          });
          if (!mounted) return;
          Navigator.pushReplacement(context, createSmoothRoute(HomeScreen(currentUserId: nickLower)));
        }
      }
    } catch (e) {
      setState(() => _error = 'Ошибка связи с сервером: проверь интернет');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    final slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(fadeAnim);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
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
            child: FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: slideAnim,
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
                      const SizedBox(height: 18),
                      const Text('PulseChat', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim), child: child)),
                        child: Text(
                          _isLogin ? 'Добро пожаловать обратно' : 'Регистрация (1-й юзер = Создатель 👑)',
                          key: ValueKey(_isLogin),
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _error != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            elevation: 6,
                            shadowColor: accent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text(_isLogin ? 'Войти' : 'Создать аккаунт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                        child: Text(_isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
EOFcat << 'EOF' >> /workspaces/My-meesenger/messenger_app/lib/main.dart

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
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nick = _nickController.text.trim();
    final pass = _passController.text.trim();
    if (nick.length < 3 || nick.length > 18) {
      setState(() => _error = 'Ник должен быть от 3 до 18 символов');
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
          setState(() => _error = 'Этот ник уже занят');
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
          });
          if (!mounted) return;
          Navigator.pushReplacement(context, createSmoothRoute(HomeScreen(currentUserId: nickLower)));
        }
      }
    } catch (e) {
      setState(() => _error = 'Ошибка связи с сервером: проверь интернет');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    final slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(fadeAnim);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
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
            child: FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: slideAnim,
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
                      const SizedBox(height: 18),
                      const Text('PulseChat', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim), child: child)),
                        child: Text(
                          _isLogin ? 'Добро пожаловать обратно' : 'Регистрация (1-й юзер = Создатель 👑)',
                          key: ValueKey(_isLogin),
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _error != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            elevation: 6,
                            shadowColor: accent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text(_isLogin ? 'Войти' : 'Создать аккаунт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                        child: Text(_isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти'),
                      ),
                    ],
                  ),
                ),
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    if (_me == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: 14),
              const Text('Загружаем чаты...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    final me = _me!;

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
            SizedBox(width: 8),
            Text('PulseChat', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
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
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]),
              ),
              currentAccountPicture: Hero(
                tag: 'my_avatar',
                child: UserAvatar(base64Str: me['avatarBase64'] ?? '', name: me['username'] ?? ''),
              ),
              accountName: Row(
                children: [
                  Text(me['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (me['isCreator'] == true) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.verified, color: Colors.amber, size: 18)),
                ],
              ),
              accountEmail: Text(me['bio'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 280 + (i * 50).clamp(0, 400)),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) => Opacity(
                          opacity: val,
                          child: Transform.translate(offset: Offset(0, 14 * (1 - val)), child: child),
                        ),
                        child: ListTile(
                          leading: Hero(
                            tag: 'avatar_${target['usernameLower']}',
                            child: UserAvatar(base64Str: target['avatarBase64'] ?? '', name: target['username'] ?? ''),
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
                        ),
                      );
                    },
                  ),
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

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sending) return;
    _msgController.clear();
    setState(() => _sending = true);
    try {
      await FirestoreRest.addDoc('chats/${widget.chatId}/messages', {
        'senderId': widget.currentUser['usernameLower'],
        'senderName': widget.currentUser['username'],
        'isCreator': widget.currentUser['isCreator'] == true,
        'text': text,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await _loadMsgs();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessage(String docId) async {
    await FirestoreRest.deleteDoc('chats/${widget.chatId}/messages/$docId');
    _loadMsgs();
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final fontSize = PulseChatApp.of(context)?.fontSize ?? 16.0;
    final amICreator = widget.currentUser['isCreator'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.targetUser != null) ...[
              Hero(
                tag: 'avatar_${widget.targetUser!['usernameLower']}',
                child: UserAvatar(base64Str: widget.targetUser!['avatarBase64'] ?? '', name: widget.targetUser!['username'] ?? '', radius: 18),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(widget.chatTitle, overflow: TextOverflow.ellipsis)),
          ],
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

                return TweenAnimationBuilder<double>(
                  key: ValueKey(data['_id'] ?? i),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  builder: (context, val, child) => Opacity(
                    opacity: val.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(isMe ? 18 * (1 - val) : -18 * (1 - val), 10 * (1 - val)),
                      child: Transform.scale(scale: 0.94 + (0.06 * val), child: child),
                    ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe && widget.isGlobal)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('${data['senderName']} ${data['isCreator'] == true ? '👑' : ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ),
                            Text(data['text'] ?? '', style: TextStyle(fontSize: fontSize, color: Colors.white)),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF151F32),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Сообщение...',
                        filled: true,
                        fillColor: const Color(0xFF0B1120),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedScale(
                    scale: _sending ? 0.85 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: CircleAvatar(
                      radius: 23,
                      backgroundColor: accent,
                      child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: _send),
                    ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки и Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                Hero(
                  tag: 'my_avatar',
                  child: UserAvatar(base64Str: user['avatarBase64'] ?? '', name: user['username'] ?? '', radius: 52),
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
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user['username'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                if (user['isCreator'] == true) ...[
                  const SizedBox(width: 6),
                  const Chip(label: Text('👑 Создатель', style: TextStyle(color: Colors.amber)), backgroundColor: Colors.black26),
                ]
              ],
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
          const Text('Цвет оформления', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
        ),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: selected ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String base64Str;
  final String name;
  final double radius;
  const UserAvatar({super.key, required this.base64Str, required this.name, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    if (base64Str.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(base64Str);
        return CircleAvatar(radius: radius, backgroundImage: MemoryImage(bytes));
      } catch (_) {}
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF334155),
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: radius * 0.85, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
