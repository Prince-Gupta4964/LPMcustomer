import 'package:flutter/material.dart';
import 'new_customer_form.dart';

class NewCustomerFormScope extends InheritedWidget {
  final NewCustomerForm form;

  const NewCustomerFormScope({
    super.key,
    required this.form,
    required Widget child,
  }) : super(child: child);

  static NewCustomerForm of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<NewCustomerFormScope>();
    assert(scope != null, 'NewCustomerFormScope not found');
    return scope!.form;
  }

  @override
  bool updateShouldNotify(_) => false;
}
