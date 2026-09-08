import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/client_header_card.dart';
import '../widgets/order_status_card.dart';
import '../widgets/rating_card.dart';
import '../widgets/delivery_details_card.dart';
import '../widgets/price_details_card.dart';
import '../viewmodel/order_detail_viewmodel.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final lpm = extra?['lpm'] as String? ?? '';

    final viewModel = context.watch<OrderDetailViewModel>();

    // 👈 start listening to Firestore when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderDetailViewModel>().listenToJob(lpm);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Client Details'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 1024;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 900 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    ClientHeaderCard(),
                    const SizedBox(height: 16),
                    OrderStatusCard(
                      stepStatus: viewModel.getStepStatus(lpm),
                    ),
                    const SizedBox(height: 16),
                    RatingCard(lpm: lpm),
                    const SizedBox(height: 16),
                    const DeliveryDetailsCard(),
                    const SizedBox(height: 20),
                    const PriceDetailsCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}