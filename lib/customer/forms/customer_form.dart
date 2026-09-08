import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'new_customer_form_scope.dart';

class CustomerForm extends StatefulWidget {
  final String customerName;
  const CustomerForm({super.key, required this.customerName});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final jobName = TextEditingController();
  final machineName = TextEditingController();
  final plywoodSizeGriper = TextEditingController();
  final rubberOrWithout = TextEditingController();
  final cuttingRule = TextEditingController();
  final creasingRule = TextEditingController();
  final materialToPunch = TextEditingController();
  final flute = TextEditingController();
  final boardCompressedThickness = TextEditingController();
  final centerNotch = TextEditingController();
  final plywoodThickness = TextEditingController();
  final perforation = TextEditingController();
  final partinex = TextEditingController();
  final nicking = TextEditingController();
  final broaching = TextEditingController();
  final bladeWelding = TextEditingController();
  final strippingMaleFemale = TextEditingController();
  final sanwitchDie = TextEditingController();

  bool _submitting = false;
  bool _sendForQuotation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = NewCustomerFormScope.of(context);
    if (form.partyName.text.isEmpty) {
      form.partyName.text = widget.customerName;
    }
    if (form.deliveryAt.text.isEmpty) {
      _prefillDeliveryAddress(form);
    }
  }

  Future<void> _prefillDeliveryAddress(form) async {
    try {
      final session = SessionManager.getSession();
      if (session == null) return;
      final uid = session['uid'];
      if (uid == null || uid.toString().isEmpty) return;
      final doc = await FirebaseFirestore.instance.collection('customers').doc(uid).get();
      if (!mounted) return;
      if (doc.exists) {
        final address = doc.data()?['Address']?.toString() ?? '';
        if (address.isNotEmpty && form.deliveryAt.text.isEmpty) {
          setState(() => form.deliveryAt.text = address);
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
  }

  Future<void> _submit() async {
    final form = NewCustomerFormScope.of(context);
    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance.collection('demo_customer_form').add({
        'partyName': form.partyName.text,
        'deliveryAt': form.deliveryAt.text,
        'jobName': jobName.text,
        'machineName': machineName.text,
        'plywoodSizeGriper': plywoodSizeGriper.text,
        'rubberOrWithout': rubberOrWithout.text,
        'cuttingRule': cuttingRule.text,
        'creasingRule': creasingRule.text,
        'materialToPunch': materialToPunch.text,
        'flute': flute.text,
        'boardCompressedThickness': boardCompressedThickness.text,
        'centerNotch': centerNotch.text,
        'plywoodThickness': plywoodThickness.text,
        'perforation': perforation.text,
        'partinex': partinex.text,
        'nicking': nicking.text,
        'broaching': broaching.text,
        'bladeWelding': bladeWelding.text,
        'strippingMaleFemale': strippingMaleFemale.text,
        'sanwitchDie': sanwitchDie.text,
        'sendForQuotation': _sendForQuotation,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
      context.go('/dashboard');
    } catch (e) {
      debugPrint('Submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      jobName, machineName, plywoodSizeGriper, rubberOrWithout,
      cuttingRule, creasingRule, materialToPunch, flute,
      boardCompressedThickness, centerNotch, plywoodThickness,
      perforation, partinex, nicking, broaching, bladeWelding,
      strippingMaleFemale, sanwitchDie,
    ]) c.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController controller, {String hint = '', bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            hintText: hint.isEmpty ? label : hint,
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = NewCustomerFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 1"),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field("Party Name *", form.partyName, hint: "Party Name", enabled: false),
                _field("Delivery At", form.deliveryAt, hint: "Address"),
                _field("Job Name", jobName),
                _field("Machine Name", machineName),
                _field("Ply Wood Size & Griper", plywoodSizeGriper),
                _field("Rubber Or Without Rubber", rubberOrWithout),
                _field("Cutting Rule", cuttingRule),
                _field("Creasing Rule", creasingRule),
                _field("Material To Punch", materialToPunch),
                _field("Flute", flute),
                _field("Board Compressed Thickness", boardCompressedThickness),
                _field("Center Notch", centerNotch),
                _field("Ply Wood Thickness", plywoodThickness),
                _field("Perforation", perforation),
                _field("Partinex", partinex),
                _field("Nicking", nicking),
                _field("Broaching", broaching),
                _field("Blade Welding", bladeWelding),
                _field("Stripping Male & Female", strippingMaleFemale),
                _field("Sanwitch Die", sanwitchDie),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Send for Quotation",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Text(_sendForQuotation ? "Yes" : "No",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _sendForQuotation ? Colors.green : Colors.red)),
                          const SizedBox(width: 8),
                          Switch(
                            value: _sendForQuotation,
                            onChanged: (val) => setState(() => _sendForQuotation = val),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red.shade100,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 16, right: 16,
            child: SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: null,
                      child: Text("Previous",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                    ),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}