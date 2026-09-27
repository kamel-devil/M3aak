import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';



class CartHelper{



  double calculateVatTax(List<CartModel>? cartList) {
    double taxAmount = 0;
    if (cartList != null) {
      for (CartModel cart in cartList) {
        if(cart.isChecked ?? false) {
          taxAmount += cart.appliedTax ?? 0;
          taxAmount += cart.shippingCostTax ?? 0;
        }
      }
    }
    return taxAmount;
  }



}