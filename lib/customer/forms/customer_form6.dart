import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../FormComponents/AddableSearchDropdown.dart';
import '../../FormComponents/FlexibleToggle.dart';
import 'new_customer_form_scope.dart';

class CustomerForm6 extends StatefulWidget {
  const CustomerForm6({super.key});

  @override
  State<CustomerForm6> createState() => _CustomerForm6State();
}

class _CustomerForm6State extends State<CustomerForm6> {
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final form = NewCustomerFormScope.of(context);
    bool laserDone =
        form.laserCuttingStatus.text.trim().toLowerCase() == "done";
    bool rubberFixingDone =
        form.rubberFixingDone.text.trim().toLowerCase() == "yes";
    bool whiteProfileRubber =
        form.whiteProfileRubber.text.trim().toLowerCase() == "yes";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 6"),
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
                  label: "Stripping",
                  items: form.jobs,
                  initialValue: form.strippingType.text.isEmpty
                      ? "No"
                      : form.strippingType.text,
                  onChanged: (v) => setState(
                          () => form.strippingType.text = v ?? "No"),
                  onAdd: (v) => form.jobs.add(v),
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "Rubber Fixing Done",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: rubberFixingDone,
                  onChanged: (v) => setState(() =>
                  form.rubberFixingDone.text =
                  v ? "Yes" : "No"),
                ),

                const SizedBox(height: 30),

                FlexibleToggle(
                  label: "White Profile Rubber",
                  inactiveText: "No",
                  activeText: "Yes",
                  initialValue: whiteProfileRubber,
                  onChanged: (v) => setState(() =>
                  form.whiteProfileRubber.text =
                  v ? "Yes" : "No"),
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
                          context.go('/customer-form-5'),
                      child: const Text("Previous",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                          setState(
                                  () => isSubmitting = true);
                          try {
                            await form.submitForm();
                            form.reset();
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                  context)
                                  .showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Customer data submitted successfully")),
                              );
                              context.go('/dashboard');
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(
                                context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Error submitting form: $e")),
                            );
                          } finally {
                            setState(() =>
                            isSubmitting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFF8D94B),
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ))
                            : const Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700),
                        ),
                      ),
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