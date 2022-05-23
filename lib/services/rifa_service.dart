import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rifa_rifa/services/model/rifa_model.dart';

class RifaService {
  Future<num> getCount() => FirebaseFirestore.instance
      .collection('configs')
      .doc('config')
      .get()
      .then((value) => value.data()!['quantidade'] as num);

  Stream<List<RifaModel>> getRifas() =>
      FirebaseFirestore.instance.collection('rifas').snapshots().map((event) =>
          event.docs.map((e) => RifaModel.fromMap(e.data())).toList());
}
