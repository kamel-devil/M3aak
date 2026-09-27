import 'package:kk_thotix_m3aak/features/support/domain/models/support_ticket_body.dart';
import 'package:kk_thotix_m3aak/interface/repo_interface.dart';
import 'package:image_picker/image_picker.dart';

abstract class SupportTicketRepositoryInterface extends RepositoryInterface<SupportTicketBody>{

  Future<dynamic> createNewSupportTicket(SupportTicketBody supportTicketModel, List<XFile?> file);

  Future<dynamic> getSupportReplyList(String ticketID);

  Future<dynamic> sendReply(String ticketID, String message, List<XFile?> file);

  Future<dynamic> closeSupportTicket(String ticketID);

}