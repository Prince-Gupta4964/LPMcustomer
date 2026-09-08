import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../FormComponents/AddableSearchDropdown.dart';
import '../../FormComponents/TextInput.dart';
import '../../FormComponents/FlexibleToggle.dart';
import 'new_customer_form_scope.dart';

class CustomerForm4 extends StatefulWidget {
  const CustomerForm4({super.key});

  @override
  State<CustomerForm4> createState() => _CustomerForm4State();
}

class _CustomerForm4State extends State<CustomerForm4> {
  final List<String> jobs = ["No", "Yes"];

  String _selectedByText(BuildContext context) {
    final d = DateTime.now();
    return "Company on ${d.day}/${d.month}/${d.year} at ${TimeOfDay.now().format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    final form = NewCustomerFormScope.of(context);
    final isPerforationSelected =
        form.perforation.text.trim().toLowerCase() != "no";
    final isZigZagBladeSelected =
        form.zigZagBlade.text.trim().toLowerCase() != "no";
    final isRubberSelected =
        form.rubberType.text.trim().toLowerCase() != "no";
    final isHoleSelected =
        form.holeType.text.trim().toLowerCase() != "no";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 4"),
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
                  label: "Perforation",
                  items: jobs,
                  initialValue: "No",
                  onChanged: (v) {
                    setState(() => form.perforation.text = v ?? "No");
                    if (form.perforation.text.toLowerCase() == "no") {
                      form.perforationSelectedBy.clear();
                    } else {
                      form.perforationSelectedBy.text =
                          _selectedByText(context);
                    }
                  },
                  onAdd: (v) => jobs.add(v),
                ),

                if (isPerforationSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Perforation Done By",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: form.perforationSelectedBy,
                    enabled: false,
                    decoration: const InputDecoration(
                        hintText: "Will be filled automatically",
                        border: OutlineInputBorder()),
                  ),
                ],

                const SizedBox(height: 26),

                AddableSearchDropdown(
                  label: "Zig Zag Blade",
                  items: jobs,
                  initialValue: "No",
                  onChanged: (v) {
                    setState(() => form.zigZagBlade.text = v ?? "No");
                    if (form.zigZagBlade.text.toLowerCase() ==
                        "no") {
                      form.zigZagBladeSelectedBy.clear();
                    } else {
                      form.zigZagBladeSelectedBy.text =
                          _selectedByText(context);
                    }
                  },
                  onAdd: (v) => jobs.add(v),
                ),

                if (isZigZagBladeSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Zig Zag Blade Selected By",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: form.zigZagBladeSelectedBy,
                    enabled: false,
                    decoration: const InputDecoration(
                        hintText: "Will be filled automatically",
                        border: OutlineInputBorder()),
                  ),
                ],

                const SizedBox(height: 26),

                AddableSearchDropdown(
                  label: "Rubber",
                  items: jobs,
                  initialValue: "No",
                  onChanged: (v) {
                    setState(() => form.rubberType.text = v ?? "No");
                    if (form.rubberType.text.toLowerCase() ==
                        "no") {
                      form.rubberSelectedBy.clear();
                    } else {
                      form.rubberSelectedBy.text =
                          _selectedByText(context);
                    }
                  },
                  onAdd: (v) => jobs.add(v),
                ),

                if (isRubberSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Rubber Selected By",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: form.rubberSelectedBy,
                    enabled: false,
                    decoration: const InputDecoration(
                        hintText: "Will be filled automatically",
                        border: OutlineInputBorder()),
                  ),
                ],

                const SizedBox(height: 26),

                AddableSearchDropdown(
                  label: "Hole",
                  items: jobs,
                  initialValue: "No",
                  onChanged: (v) {
                    setState(() => form.holeType.text = v ?? "No");
                    if (form.holeType.text.toLowerCase() ==
                        "no") {
                      form.holeSelectedBy.clear();
                    } else {
                      form.holeSelectedBy.text =
                          _selectedByText(context);
                    }
                  },
                  onAdd: (v) => jobs.add(v),
                ),

                if (isHoleSelected) ...[
                  const SizedBox(height: 20),
                  const Text("Hole Selected By",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: form.holeSelectedBy,
                    enabled: false,
                    decoration: const InputDecoration(
                        hintText: "Will be filled automatically",
                        border: OutlineInputBorder()),
                  ),
                ],

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Emboss",
                  inactiveText: "No",
                  activeText: "Yes",
                  onChanged: (v) =>
                  form.embossStatus.text = v ? "Yes" : "No",
                ),

                const SizedBox(height: 26),

                TextInput(
                    label: "Emboss Pcs",
                    hint: "No of Pcs",
                    controller: form.embossPcs),
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
                          context.go('/customer-form-3'),
                      child: const Text("Previous",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          context.go('/customer-form-5'),
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