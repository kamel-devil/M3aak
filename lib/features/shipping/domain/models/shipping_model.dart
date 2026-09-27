import 'package:kk_thotix_m3aak/features/shipping/domain/models/shipping_method_model.dart';

class ShippingModel{
  int? shippingIndex;
  String? groupId;
  List<ShippingMethodModel>? shippingMethodList;

  ShippingModel(this.shippingIndex, this.groupId, this.shippingMethodList);
}