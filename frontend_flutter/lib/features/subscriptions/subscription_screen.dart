import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Future<Map<String, dynamic>> plans;

  @override
  void initState() {
    super.initState();
    plans = ApiService().getPlans();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: plans,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = List<Map<String, dynamic>>.from(snapshot.data!['plans'] as List);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Subscription Plans', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ...items.map((plan) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['name'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(plan['price'] == 0 ? 'Free' : '\$${plan["price"]}'),
                      const SizedBox(height: 10),
                      ...List<String>.from(plan['features'] as List).map((feature) => Text('• $feature')),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () {}, child: const Text('Select Plan')),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
