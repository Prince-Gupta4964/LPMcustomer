import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../FormComponents/TextInput.dart';
import '../../FormComponents/AddableSearchDropdown.dart';
import '../../FormComponents/PrioritySelector.dart';
import '../../FormComponents/FlexibleToggle.dart';
import '../../FormComponents/FileUploadBox.dart';
import 'new_customer_form_scope.dart';

class CustomerForm2 extends StatefulWidget {
  const CustomerForm2({super.key});

  @override
  State<CustomerForm2> createState() => _CustomerForm2State();
}

class _CustomerForm2State extends State<CustomerForm2> {
  final _formKey = GlobalKey<FormState>();
  bool isDesigningDone = false;
  bool isPlySelected = false;
  List<String> ply = ["No", "Single", "Double"];
  File? drawingFile;
  File? rubberReportFile;
  File? punchReportFile;

  String _now(BuildContext context) {
    final d = DateTime.now();
    return "Company on ${d.day}/${d.month}/${d.year} at ${TimeOfDay.now().format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    final form = NewCustomerFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer 2"),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Priority",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  PrioritySelector(onChanged: (v) => form.priority.text = v ?? ""),
                  const SizedBox(height: 30),

                  TextInput(label: "Remark", hint: "Remark", controller: form.remark),
                  const SizedBox(height: 30),

                  const Text("Drawing Attachment",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  FileUploadBox(onFileSelected: (file) => drawingFile = File(file.path!)),
                  const SizedBox(height: 30),

                  if (isDesigningDone) ...[
                    const Text("Rubber Report",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    FileUploadBox(onFileSelected: (file) => rubberReportFile = File(file.path!)),
                    const SizedBox(height: 30),
                  ],

                  const Text("Punch Report",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  FileUploadBox(onFileSelected: (file) => punchReportFile = File(file.path!)),
                  const SizedBox(height: 30),

                  AddableSearchDropdown(
                    label: "Ply",
                    items: ply,
                    initialValue: "No",
                    onChanged: (v) {
                      setState(() => form.plyType.text = v ?? "");
                      final selected = (v ?? "").toLowerCase();
                      isPlySelected = selected != "no";
                      if (!isPlySelected) {
                        form.plySelectedBy.clear();
                      } else {
                        form.plySelectedBy.text = _now(context);
                      }
                    },
                    onAdd: (v) => ply.add(v),
                  ),

                  if (isPlySelected) ...[
                    const SizedBox(height: 30),
                    const Text("Ply Selected By",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: form.plySelectedBy,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "Will be filled automatically",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ],
              ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/customer-form'),
                      child: const Text("Previous",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/customer-form-3'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Next",
                          style:
                          TextStyle(color: Colors.white, fontSize: 16)),
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