import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quantum_messenger41/state/app_state.dart';
import 'package:quantum_messenger41/ui/screens/discovery_screen.dart';
import 'package:quantum_messenger41/ui/screens/contacts_screen.dart';
import 'package:quantum_messenger41/ui/screens/chat_screen.dart';
import 'package:quantum_messenger41/ui/screens/policy_screen.dart';
import 'package:quantum_messenger41/ui/screens/profile_screen.dart';
import 'package:quantum_messenger41/ui/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141414),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  final appState = AppState();
  await appState.init();
  runApp(QuantumMessengerApp(appState: appState));
}

class QuantumMessengerApp extends StatelessWidget {
  final AppState appState;
  const QuantumMessengerApp({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Quantum Messenger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: disasterDark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: disasterOrange,
            brightness: Brightness.dark,
            primary: disasterOrange,
            secondary: disasterSurface,
            surface: disasterSurface,
          ),
          fontFamily: 'Space Grotesk',
          appBarTheme: const AppBarTheme(
            backgroundColor: disasterDark,
            elevation: 0,
            centerTitle: false,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: disasterSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DiscoveryScreen(),
    ContactsScreen(),
    ChatScreen(),
    PolicyScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).startCommunicationService(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: disasterSurface,
          border: Border(
            top: BorderSide(
              color: glassBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.explore_outlined, Icons.explore, 'Discover'),
                _buildNavItem(1, Icons.people_outline, Icons.people, 'Contacts'),
                _buildNavItem(2, Icons.chat_bubble_outline, Icons.chat_bubble, 'Chats'),
                _buildNavItem(3, Icons.security_outlined, Icons.security, 'Policy'),
                _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    disasterOrange.withOpacity(0.2),
                    disasterOrange.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: disasterOrange.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? disasterOrange : disasterTextMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? disasterOrange : disasterTextMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}