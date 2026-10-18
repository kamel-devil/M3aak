import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kk_thotix_m3aak/data/local/cache_response.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/google_login_controller.dart';
import 'package:kk_thotix_m3aak/features/banner/controllers/banner_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/compare/controllers/compare_controller.dart';
import 'package:kk_thotix_m3aak/features/contact_us/controllers/contact_us_controller.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/featured_deal_controller.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/flash_deal_controller.dart';
import 'package:kk_thotix_m3aak/features/location/controllers/location_controller.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:kk_thotix_m3aak/features/notification/controllers/notification_controller.dart';
import 'package:kk_thotix_m3aak/features/onboarding/controllers/onboarding_controller.dart';
import 'package:kk_thotix_m3aak/features/order/controllers/order_controller.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/seller_product_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/controllers/product_details_controller.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/refund/controllers/refund_controller.dart';
import 'package:kk_thotix_m3aak/features/reorder/controllers/re_order_controller.dart';
import 'package:kk_thotix_m3aak/features/restock/controllers/restock_controller.dart';
import 'package:kk_thotix_m3aak/features/prescription/controllers/prescription_controller.dart';
import 'package:kk_thotix_m3aak/features/review/controllers/review_controller.dart';
import 'package:kk_thotix_m3aak/features/shipping/controllers/shipping_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/support/controllers/support_ticket_controller.dart';
import 'package:kk_thotix_m3aak/features/wallet/controllers/wallet_controller.dart';
import 'package:kk_thotix_m3aak/features/wishlist/controllers/wishlist_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/push_notification/models/notification_body.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/brand/controllers/brand_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/category/controllers/category_controller.dart';
import 'package:kk_thotix_m3aak/features/chat/controllers/chat_controller.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';
import 'package:kk_thotix_m3aak/features/shop/controllers/shop_controller.dart';
import 'package:kk_thotix_m3aak/push_notification/notification_helper.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/theme/dark_theme.dart';
import 'package:kk_thotix_m3aak/theme/light_theme.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'di_container.dart' as di;
import 'firebase_options.dart';
import 'helper/custom_delegate.dart';
import 'localization/app_localization.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final database = AppDatabase();


// TEMP (local testing, debug builds only): reach the local Herd site from the Android emulator.
// The emulator can't resolve the host machine's .test domain, so connections to it go to the host
// (10.0.2.2) while TLS SNI / Host stay '6vally-v15.6.test' (Herd vhost + tenant lookup), and Herd's
// self-signed certificate is accepted for that host only.
// Remove together with the local baseUrl in AppConstants.
const String _localDevHost = '6vally-v15.6.test';

class _LocalDevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => host == _localDevHost)
      ..connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
        final bool isHttps = uri.scheme == 'https';
        if (uri.host != _localDevHost) {
          return isHttps
              ? await SecureSocket.startConnect(uri.host, uri.port, context: context)
              : await Socket.startConnect(uri.host, uri.port);
        }
        final ConnectionTask<Socket> task = await Socket.startConnect('10.0.2.2', uri.port);
        final Future<Socket> socket = task.socket.then<Socket>((Socket raw) => isHttps
            ? SecureSocket.secure(raw, host: _localDevHost, onBadCertificate: (_) => true)
            : raw);
        return ConnectionTask.fromSocket(socket, task.cancel);
      };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    HttpOverrides.global = _LocalDevHttpOverrides();
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  } catch (e) {
    debugPrint('FlutterDownloader init error: $e');
  }

  try {
    await di.init();
  } catch (e) {
    debugPrint('DI init error: $e');
  }

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  NotificationBody? body;
  try {
    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }catch(_) {}


  // await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  // FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => di.sl<CategoryController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
      ChangeNotifierProvider(create: (context) => di.sl<FlashDealController>()),
      ChangeNotifierProvider(create: (context) => di.sl<FeaturedDealController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BrandController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BannerController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OnBoardingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SearchProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WishListController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SupportTicketController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<GoogleSignInController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddressController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CompareController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CheckoutController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LoyaltyPointController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ContactUsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ReOrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ReviewController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SellerProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RestockController>()),
      ChangeNotifierProvider(create: (context) => di.sl<PrescriptionController>()),
    ],
    child: MyApp(body: body),
  ));
}

class MyApp extends StatelessWidget {
  final NotificationBody? body;
  const MyApp({super.key, required this.body});


  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp.router(
          routerConfig: RouterHelper.goRoutes,
          title: AppConstants.appName,
        //   navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: themeController.darkTheme ? dark : light(
            primaryColor: themeController.selectedPrimaryColor,
            secondaryColor: themeController.selectedPrimaryColor,
          ),
          locale: Provider.of<LocalizationController>(context).locale,
          localizationsDelegates: [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FallbackLocalizationDelegate()
          ],
          builder:(context,child) {
            return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), child: SafeArea(top: false, child: child!));
          },
          supportedLocales: locals,
          // home: SplashScreen(body: body,),
        );
      }
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}