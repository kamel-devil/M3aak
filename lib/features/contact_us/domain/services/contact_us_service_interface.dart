import 'package:kk_thotix_m3aak/features/contact_us/domain/models/contact_us_body.dart';

abstract class ContactUsServiceInterface{

  Future<dynamic> add(ContactUsBody contactUsBody);
}