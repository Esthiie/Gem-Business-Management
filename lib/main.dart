import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'screens/add_design_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/best_sellers_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/new_order_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/sale_detail_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup/setup_account_screen.dart';
import 'screens/setup/setup_done_screen.dart';
import 'screens/setup/setup_profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  // Step 2 (backend):
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const GemApp(),
    ),
  );
}

class GemApp extends StatelessWidget {
  const GemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gem Business Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: Routes.welcome,
      routes: {
        Routes.welcome: (_) => const WelcomeScreen(),
        Routes.setupAccount: (_) => const SetupAccountScreen(),
        Routes.setupProfile: (_) => const SetupProfileScreen(),
        Routes.setupDone: (_) => const SetupDoneScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.home: (_) => const MainShell(),
        Routes.sell: (_) => const SellScreen(),
        Routes.addDesign: (_) => const AddDesignScreen(),
        Routes.sales: (_) => const SalesScreen(),
        Routes.bestSellers: (_) => const BestSellersScreen(),
        Routes.newOrder: (_) => const NewOrderScreen(),
        Routes.addEvent: (_) => const AddEventScreen(),
        Routes.settings: (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.orderDetail) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => OrderDetailScreen(orderId: id),
          );
        }
        if (settings.name == Routes.saleDetail) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => SaleDetailScreen(saleId: id),
          );
        }
        return null;
      },
    );
  }
}
