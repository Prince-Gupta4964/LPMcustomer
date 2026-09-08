import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewCustomerForm {
  // -------- FORM 1 --------
  final name = TextEditingController();
  final partyName = TextEditingController();
  final deliveryAt = TextEditingController();
  final orderBy = TextEditingController();
  final particularJobName = TextEditingController();

  // -------- FORM 2 --------
  final priority = TextEditingController();
  final remark = TextEditingController();
  final designingStatus = TextEditingController();
  final designedBy = TextEditingController();
  final plyType = TextEditingController();
  final plySelectedBy = TextEditingController();

  // -------- FORM 3 --------
  final blade = TextEditingController();
  final bladeSelectedBy = TextEditingController();
  final creasing = TextEditingController();
  final creasingSelectedBy = TextEditingController();
  final unknown = TextEditingController();
  final capsuleType = TextEditingController();

  // -------- FORM 4 --------
  final perforation = TextEditingController();
  final perforationSelectedBy = TextEditingController();
  final zigZagBlade = TextEditingController();
  final zigZagBladeSelectedBy = TextEditingController();
  final rubberType = TextEditingController();
  final rubberSelectedBy = TextEditingController();
  final holeType = TextEditingController();
  final holeSelectedBy = TextEditingController();
  final embossStatus = TextEditingController();
  final embossPcs = TextEditingController();

  // -------- FORM 5 --------
  final maleEmbossType = TextEditingController();
  final femaleEmbossType = TextEditingController();
  final x = TextEditingController();
  final y = TextEditingController();
  final x2 = TextEditingController();
  final y2 = TextEditingController();

  // -------- FORM 6 --------
  final strippingType = TextEditingController();
  final laserCuttingStatus = TextEditingController();
  final rubberFixingDone = TextEditingController();
  final whiteProfileRubber = TextEditingController();

  List<String> jobs = ["No", "Yes", "Laser", "Bending", "Cutting"];

  // ✅ RESET METHOD
  void reset() {
    // Form 1
    name.clear();
    partyName.clear();
    deliveryAt.clear();
    orderBy.clear();
    particularJobName.clear();

    // Form 2
    priority.clear();
    remark.clear();
    designingStatus.clear();
    designedBy.clear();
    plyType.clear();
    plySelectedBy.clear();

    // Form 3
    blade.clear();
    bladeSelectedBy.clear();
    creasing.clear();
    creasingSelectedBy.clear();
    unknown.clear();
    capsuleType.clear();

    // Form 4
    perforation.clear();
    perforationSelectedBy.clear();
    zigZagBlade.clear();
    zigZagBladeSelectedBy.clear();
    rubberType.clear();
    rubberSelectedBy.clear();
    holeType.clear();
    holeSelectedBy.clear();
    embossStatus.clear();
    embossPcs.clear();

    // Form 5
    maleEmbossType.clear();
    femaleEmbossType.clear();
    x.clear();
    y.clear();
    x2.clear();
    y2.clear();

    // Form 6
    strippingType.clear();
    laserCuttingStatus.clear();
    rubberFixingDone.clear();
    whiteProfileRubber.clear();
  }

  // -------- SUBMIT --------
  Future<void> submitForm() async {
    await FirebaseFirestore.instance.collection('customer_requests').add({
      "name": name.text,
      "partyName": partyName.text.trim(),
      "deliveryAt": deliveryAt.text,
      "orderBy": orderBy.text,
      "particularJobName": particularJobName.text,

      "priority": priority.text,
      "remark": remark.text,
      "designingStatus": designingStatus.text,
      "designedBy": designedBy.text,
      "plyType": plyType.text,
      "plySelectedBy": plySelectedBy.text,

      "blade": blade.text,
      "bladeSelectedBy": bladeSelectedBy.text,
      "creasing": creasing.text,
      "creasingSelectedBy": creasingSelectedBy.text,
      "unknown": unknown.text,
      "capsuleType": capsuleType.text,

      "perforation": perforation.text,
      "perforationSelectedBy": perforationSelectedBy.text,
      "zigZagBlade": zigZagBlade.text,
      "zigZagBladeSelectedBy": zigZagBladeSelectedBy.text,
      "rubberType": rubberType.text,
      "rubberSelectedBy": rubberSelectedBy.text,
      "holeType": holeType.text,
      "holeSelectedBy": holeSelectedBy.text,
      "embossStatus": embossStatus.text,
      "embossPcs": embossPcs.text,

      "maleEmbossType": maleEmbossType.text,
      "femaleEmbossType": femaleEmbossType.text,
      "x": x.text,
      "y": y.text,
      "x2": x2.text,
      "y2": y2.text,

      "strippingType": strippingType.text,
      "laserCuttingStatus": laserCuttingStatus.text,
      "rubberFixingDone": rubberFixingDone.text,
      "whiteProfileRubber": whiteProfileRubber.text,

      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}