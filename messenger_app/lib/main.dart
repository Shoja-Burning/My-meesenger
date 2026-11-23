import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyATrQBfZCFcy_pI5vn0BjLh703pF6yKZvo",
  authDomain: "://firebaseapp.com",
  projectId: "pulsechat-cc983",
  storageBucket: "pulsechat-cc983.firebasestorage.app",
  messagingSenderId: "295516593180",
  appId: "1:295516593180:web:4d4464b0d6128eb72653d9",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  runApp(const PulseChatApp());
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
    return MaterialApp(
      title: 'PulseChat',
      debugShowCheckedModeBanner: false,
      theme: _isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              primaryColor: _accentColor,
              appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), elevation: 0),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF1F5F9),
              primaryColor: _accentColor,
              appBarTheme: AppBarTheme(backgroundColor: _accentColor, elevation: 0),
            ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nickController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final nick = _nickController.text.trim();
    final pass = _passController.text.trim();
    if (nick.length < 3 || nick.length > 18) {
      setState(() => _error = 'Ник от 3 до 18 символов!');
      return;
    }
    if (pass.length < 4) {
      setState(() => _error = 'Пароль минимум 4 символа!');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final usersRef = FirebaseFirestore.instance.collection('users');
    final nickLower = nick.toLowerCase();
    try {
      final doc = await usersRef.doc(nickLower).get();
      if (_isLogin) {
        if (!doc.exists) {
          setState(() => _error = 'Ник не найден');
        } else if (doc.data()!['password'] != pass) {
          setState(() => _error = 'Неверный пароль!');
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(currentUserId: nickLower)));
        }
      } else {
        if (doc.exists) {
          setState(() => _error = 'Ник уже занят!');
        } else {
          final allUsers = await usersRef.limit(1).get();
          final isCreator = allUsers.docs.isEmpty;
          await usersRef.doc(nickLower).set({
            'username': nick,
            'usernameLower': nickLower,
            'password': pass,
            'bio': isCreator ? 'Создатель PulseChat 👑' : 'Привет! Я в PulseChat.',
            'avatarBase64': '',
            'isCreator': isCreator,
            'showOnline': true,
          });
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(currentUserId: nickLower)));
        }
      }
    } catch (e) {
      setState(() => _error = 'Ошибка: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Icon(Icons.bolt, size: 80, color: accent),
                const Text('PulseChat', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_isLogin ? 'Вход' : 'Регистрация (1-й юзер = Создатель 👑)', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _nickController,
                  maxLength: 18,
                  decoration: InputDecoration(
                    labelText: 'Ник (3-18 букв)',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLogin ? 'Войти' : 'Создать аккаунт', style: const TextStyle(color: Colors.white)),
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
    );
  }
}class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  String _getChatId(String u1, String u2) {
    final list = [u1, u2]..sort();
    return '${list[0]}_${list[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final me = userSnap.data!.data() as Map<String, dynamic>;

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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(userId: widget.currentUserId))),
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: const Color(0xFF1E293B),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: accent),
                  currentAccountPicture: UserAvatar(base64Str: me['avatarBase64'] ?? '', name: me['username']),
                  accountName: Row(
                    children: [
                      Text(me['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: 'global_chat', chatTitle: 'Общий чат ⚡', currentUser: me, isGlobal: true)));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Мой профиль и настройки'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(userId: widget.currentUserId)));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Выйти', style: TextStyle(color: Colors.redAccent)),
                  onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false),
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
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: accent, child: const Icon(Icons.bolt, color: Colors.white)),
                title: const Text('Общий чат PulseChat', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Глобальный канал всех пользователей'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: 'global_chat', chatTitle: 'Общий чат ⚡', currentUser: me, isGlobal: true))),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snap.data!.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      if (data['usernameLower'] == widget.currentUserId) return false;
                      if (_searchQuery.isEmpty) return true;
                      return (data['usernameLower'] as String).contains(_searchQuery);
                    }).toList();

                    if (docs.isEmpty) return const Center(child: Text('Пока никого нет. Позови друзей!', style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final target = docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: UserAvatar(base64Str: target['avatarBase64'] ?? '', name: target['username']),
                          title: Row(
                            children: [
                              Text(target['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, chatTitle: target['username'], currentUser: me, targetUser: target)));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'senderId': widget.currentUser['usernameLower'],
      'senderName': widget.currentUser['username'],
      'isCreator': widget.currentUser['isCreator'] == true,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteMessage(String docId) async {
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final accent = PulseChatApp.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final fontSize = PulseChatApp.of(context)?.fontSize ?? 16.0;
    final amICreator = widget.currentUser['isCreator'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(widget.chatTitle)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snap.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(14),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final doc = msgs[i];
                    final data = doc.data() as Map<String, dynamic>;
final isMe = data['senderId'] == widget.currentUser['usernameLower'];
final canDelete = isMe || amICreator;
return GestureDetector(
onLongPress: canDelete ? () {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Удалить сообщение?'),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
TextButton(onPressed: () { _deleteMessage(doc.id); Navigator.pop(ctx); }, child: const Text('Удалить', style: TextStyle(color: Colors.redAccent))),
],
),
);
} : null,
child: Align(
alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.symmetric(vertical: 4),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
decoration: BoxDecoration(
color: isMe ? accent : const Color(0xFF1E293B),
borderRadius: BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
if (!isMe && widget.isGlobal)
Text('${data['senderName']} ${data['isCreator'] == true ? '👑' : ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
Text(data['text'] ?? '', style: TextStyle(fontSize: fontSize, color: Colors.white)),
],
),
),
),
);
},
);
},
),
),
Container(
padding: const EdgeInsets.all(10),
color: const Color(0xFF1E293B),
child: Row(
children: [
Expanded(
child: TextField(
controller: _msgController,
onSubmitted: (_) => _send(),
decoration: InputDecoration(
hintText: 'Сообщение... (удерживай чтобы удалить)',
filled: true,
fillColor: const Color(0xFF0F172A),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
),
),
),
const SizedBox(width: 8),
CircleAvatar(backgroundColor: accent, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _send)),
],
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
  bool _loaded = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 250, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'avatarBase64': base64Encode(bytes),
    });
  }

  Future<void> _saveBio() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'bio': _bioController.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio сохранено!')));
  }

  @override
  Widget build(BuildContext context) {
    final appState = PulseChatApp.of(context)!;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final user = snap.data!.data() as Map<String, dynamic>;
        if (!_loaded) {
          _bioController.text = user['bio'] ?? '';
          _loaded = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Настройки и Профиль')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    UserAvatar(base64Str: user['avatarBase64'] ?? '', name: user['username'], radius: 50),
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
                    Text(user['username'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.check_circle, color: appState.accentColor, size: 36), onPressed: _saveBio),
                ],
              ),
              const Divider(height: 32),
              const Text('Цвет оформления', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Темная тема'),
                value: appState.isDark,
                onChanged: (v) => appState.updateTheme(dark: v),
              ),
              ListTile(
                title: Text('Размер шрифта: ${appState.fontSize.toInt()}'),
                subtitle: Slider(min: 12, max: 24, value: appState.fontSize, onChanged: (v) => appState.updateTheme(size: v)),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Показывать статус «В сети»'),
                value: user['showOnline'] ?? true,
                onChanged: (v) => FirebaseFirestore.instance.collection('users').doc(widget.userId).update({'showOnline': v}),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorBtn(_PulseChatAppState appState, Color color) {
    return GestureDetector(
      onTap: () => appState.updateTheme(color: color),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: appState.accentColor == color ? const Icon(Icons.check, color: Colors.white) : null,
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
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: radius * 0.8, color: Colors.white)),
    );
  }
}