import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scout = ref.watch(currentScoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance card
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Available Credits', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${scout?.walletBalance ?? 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Buy Credits', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _CreditPack(credits: 10, price: '₹999', popular: false),
            _CreditPack(credits: 25, price: '₹2,249', popular: true),
            _CreditPack(credits: 50, price: '₹3,999', popular: false),
            const SizedBox(height: 24),
            Text('How Credits Work', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Upload a profile → Earn 3 credits'),
                    SizedBox(height: 4),
                    Text('• Unlock a profile → Spend 1 credit'),
                    SizedBox(height: 4),
                    Text('• Fake report penalty → -5 credits'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditPack extends StatelessWidget {
  final int credits;
  final String price;
  final bool popular;

  const _CreditPack({required this.credits, required this.price, required this.popular});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: popular
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2))
          : null,
      child: ListTile(
        leading: CircleAvatar(child: Text('$credits')),
        title: Text('$credits Credits'),
        subtitle: popular ? const Text('Most Popular', style: TextStyle(color: Colors.green)) : null,
        trailing: ElevatedButton(onPressed: () {/* TODO: Razorpay */}, child: Text(price)),
      ),
    );
  }
}
