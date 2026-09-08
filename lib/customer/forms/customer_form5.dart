import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../FormComponents/AddableSearchDropdown.dart';
import '../../FormComponents/NumberStepper.dart';
import 'new_customer_form_scope.dart';

class CustomerForm5 extends StatefulWidget {
  const CustomerForm5({super.key});

  @override
  State<CustomerForm5> createState() => _CustomerForm5State();
}

class _CustomerForm5State extends State<CustomerForm5> {
  final maleEmbossType = TextEditingController();
  final femaleEmbossType = TextEditingController();
  final x = TextEditingController();
  final y = TextEditingController();
  final x2 = TextEditingController();
  final y2 = TextEditingController();
  final List<String> embossTypes = ["No", "Standard", "Custom"];

  void calculateXY() {}
  void calculateXY2() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 5"),
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
                AddableSearchDropdown(
                  label: "Male Emboss",
                  items: embossTypes,
                  initialValue: "No",
                  onChanged: (v) => maleEmbossType.text = v ?? "",
                  onAdd: (v) => embossTypes.add(v),
                ),

                const SizedBox(height: 30),

                const Text("X",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                NumberStepper(
                  step: 0.01,
                  controller: x,
                  onChanged: (val) {
                    x.text = val.toString();
                    calculateXY();
                  },
                ),

                const SizedBox(height: 30),

                const Text("Y",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                NumberStepper(
                  step: 0.01,
                  controller: y,
                  onChanged: (val) {
                    y.text = val.toString();
                    calculateXY();
                  },
                ),

                const SizedBox(height: 30),

                AddableSearchDropdown(
                  label: "Female Emboss",
                  items: embossTypes,
                  initialValue: "No",
                  onChanged: (v) => femaleEmbossType.text = v ?? "",
                  onAdd: (v) => embossTypes.add(v),
                ),

                const SizedBox(height: 30),

                const Text("X2",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                NumberStepper(
                  step: 0.01,
                  controller: x2,
                  onChanged: (val) {
                    x2.text = val.toString();
                    calculateXY2();
                  },
                ),

                const SizedBox(height: 30),

                const Text("Y2",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                const SizedBox(height: 8),

                NumberStepper(
                  step: 0.01,
                  controller: y2,
                  onChanged: (val) {
                    y2.text = val.toString();
                    calculateXY2();
                  },
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          context.go('/customer-form-4'),
                      child: const Text("Previous",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final form =
                        NewCustomerFormScope.of(context);
                        form.maleEmbossType.text =
                            maleEmbossType.text;
                        form.femaleEmbossType.text =
                            femaleEmbossType.text;
                        form.x.text = x.text;
                        form.y.text = y.text;
                        form.x2.text = x2.text;
                        form.y2.text = y2.text;
                        context.go('/customer-form-6');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                      child: const Text("Next",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16)),
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