import 'package:kk_thotix_m3aak/features/deal/domain/repositories/flash_deal_repository_interface.dart';
import 'package:kk_thotix_m3aak/features/deal/domain/services/flash_deal_service_interface.dart';

class FlashDealService implements FlashDealServiceInterface{
  FlashDealRepositoryInterface flashDealRepositoryInterface;

  FlashDealService({required this.flashDealRepositoryInterface});

  @override
  Future get(String productID) async {
    return await flashDealRepositoryInterface.get(productID);
  }

  @override
  Future getFlashDeal() async{
    return await flashDealRepositoryInterface.getFlashDeal();
  }
}