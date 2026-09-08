import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../FormComponents/SearchableDropdownWithInitial.dart';
import '../../FormComponents/AddableSearchDropdown.dart';
import '../../FormComponents/TextInput.dart';
import '../../FormComponents/FlexibleToggle.dart';
import 'new_customer_form_scope.dart';

class CustomerForm3 extends StatefulWidget {
  const CustomerForm3({super.key});

  @override
  State<CustomerForm3> createState() => _CustomerForm3State();
}

class _CustomerForm3State extends State<CustomerForm3> {
  final Blade = TextEditingController();
  final BladeSelectedBy = TextEditingController();
  final Creasing = TextEditingController();
  final CreasingSelectedBy = TextEditingController();
  final Unknown = TextEditingController();
  final CapsuleType = TextEditingController();

  List<String> ply = ["No", "Manual", "Auto"];
  List<String> jobs = ["No"];

  bool get isBladeSelected =>
      Blade.text.isNotEmpty && Blade.text.toLowerCase() != "no";
  bool get isCreasingSelected =>
      Creasing.text.isNotEmpty && Creasing.text.toLowerCase() != "no";
  String selectedByText() => "System";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 3"),
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
                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Blade",
                  items: ply,
                  initialValue: Blade.text.isEmpty ? "No" : Blade.text,
                  onChanged: (v) {
                    setState(() {
                      Blade.text = (v ?? "No").trim();
                      if (Blade.text.toLowerCase() == "no") {
                        BladeSelectedBy.clear();
                      } else {
                        BladeSelectedBy.text = selectedByText();
                      }
                    });
                  },
                ),

                if (isBladeSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Blade Selected By",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: BladeSelectedBy,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Will be filled automatically",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                SearchableDropdownWithInitial(
                  label: "Creasing",
                  items: ply,
                  initialValue: Creasing.text.isEmpty ? "No" : Creasing.text,
                  onChanged: (v) {
                    setState(() {
                      Creasing.text = (v ?? "No").trim();
                      if (Creasing.text.toLowerCase() == "no") {
                        CreasingSelectedBy.clear();
                      } else {
                        CreasingSelectedBy.text = selectedByText();
                      }
                    });
                  },
                ),

                if (isCreasingSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Creasing Selected By",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: CreasingSelectedBy,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Will be filled automatically",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Micro sarration Half cut 23.60",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: false,
                  onChanged: (val) {},
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Micro sarration Creasing 23.60",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: false,
                  onChanged: (val) {},
                ),

                const SizedBox(height: 30),

                TextInput(
                    label: "Unknown",
                    hint: "Unknown",
                    controller: Unknown),

                const SizedBox(height: 26),

                AddableSearchDropdown(
                  label: "Capsule",
                  items: jobs,
                  initialValue: "No",
                  onChanged: (v) => CapsuleType.text = v ?? "",
                  onAdd: (newJob) => jobs.add(newJob),
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
                          context.go('/customer-form-2'),
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
                        form.blade.text = Blade.text;
                        form.bladeSelectedBy.text =
                            BladeSelectedBy.text;
                        form.creasing.text = Creasing.text;
                        form.creasingSelectedBy.text =
                            CreasingSelectedBy.text;
                        form.unknown.text = Unknown.text;
                        form.capsuleType.text =
                            CapsuleType.text;
                        context.go('/customer-form-4');
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