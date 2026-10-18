class PrescriptionListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<PrescriptionModel> prescriptions = [];

  PrescriptionListModel({this.totalSize, this.limit, this.offset, List<PrescriptionModel>? prescriptions}) {
    this.prescriptions = prescriptions ?? [];
  }

  PrescriptionListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['prescriptions'] != null) {
      json['prescriptions'].forEach((v) => prescriptions.add(PrescriptionModel.fromJson(v)));
    }
  }
}

class PrescriptionModel {
  int? id;
  String? status;
  String? notes;
  String? adminNote;
  String? createdAt;
  List<String> imageUrls = [];

  PrescriptionModel({this.id, this.status, this.notes, this.adminNote, this.createdAt, List<String>? imageUrls}) {
    this.imageUrls = imageUrls ?? [];
  }

  PrescriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    notes = json['notes'];
    adminNote = json['admin_note'];
    createdAt = json['created_at'];
    if (json['images_full_url'] != null) {
      for (final image in json['images_full_url']) {
        final String? path = image is Map ? image['path'] : null;
        if (path != null && path.isNotEmpty) {
          imageUrls.add(path);
        }
      }
    }
  }

  bool get isPending => status == 'pending';
}
