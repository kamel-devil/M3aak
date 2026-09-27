
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/business_pages_model.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:provider/provider.dart';

class HtmlPagesHelper{

  final splashController = Provider.of<SplashController>(Get.context!, listen: false);

  BusinessPageModel? hasPrivacyPolicy = Provider.of<SplashController>(Get.context!, listen: false)
      .businessPages!.firstWhere((page) => page.slug == 'privacy-policy');

}