import 'package:flutter/material.dart';

class HelpFeedbackPage extends StatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  State<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage> {
  final feedbackController = TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF171927),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF202777),
                    padding: EdgeInsets.symmetric(
                      vertical: compact ? 12 : 18,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).maybePop(),
                          color: Colors.white,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Help & Feedback',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 23 : 34,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 18 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frequently asked questions',
                            style: TextStyle(
                              fontSize: compact ? 20 : 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _FaqItem(
                            question:
                                'How do I add a customer and record a sale?',
                            answer: 'Use the green plus button on the dashboard. Enter a new customer or choose an existing one, add the price and due date, then save.',
                          ),
                          const _FaqItem(
                            question: 'How do I log a customer payment?',
                            answer: 'Open Customers, select the customer, and choose Log Payment. Select an unpaid invoice, enter the amount and method, then confirm to create a receipt.',
                          ),
                          const _FaqItem(
                            question: 'How can I send a receipt?',
                            answer: 'After confirming a payment, choose Send receipt via WhatsApp. WhatsApp opens with the receipt details ready to send.',
                          ),
                          const _FaqItem(
                            question: 'Where can I review customer history?',
                            answer: 'Open the Customers tab and select a customer to view their sales, payments, running balance, and ageing summary.',
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Send feedback',
                            style: TextStyle(
                              fontSize: compact ? 20 : 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            key: const Key('feedback-message'),
                            controller: feedbackController,
                            minLines: 4,
                            maxLines: 7,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Tell us what could be better',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: feedbackController,
                              builder: (context, value, _) =>
                                  ElevatedButton.icon(
                                    onPressed: value.text.trim().isEmpty
                                        ? null
                                        : _submitFeedback,
                                    icon: const Icon(Icons.send_outlined),
                                    label: const Text('Send feedback'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF202777),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitFeedback() {
    feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you. Your feedback was recorded.')),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(question),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(answer, style: const TextStyle(color: Color(0xFF555555))),
        ],
      ),
    );
  }
}
