import 'dart:io';
import 'package:kk_thotix_m3aak/features/product_details/domain/repositories/product_details_repository_interface.dart';
import 'package:kk_thotix_m3aak/features/product_details/domain/services/product_details_service_interface.dart';

class ProductDetailsService implements ProductDetailsServiceInterface{
  ProductDetailsRepositoryInterface productDetailsRepositoryInterface;

  ProductDetailsService({required this.productDetailsRepositoryInterface});

  @override
  Future get(String productID) async{
    return await productDetailsRepositoryInterface.get(productID);
  }

  @override
  Future getCount(String productID) async{
    return await productDetailsRepositoryInterface.getCount(productID);
  }

  @override
  Future getSharableLink(String productID) async{
    return await productDetailsRepositoryInterface.getSharableLink(productID);
  }

  @override
  Future<HttpClientResponse> previewDownload(String url) async{
    return await productDetailsRepositoryInterface.previewDownload(url);
  }

}