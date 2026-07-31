import 'package:flutter/material.dart';
import 'package:nukkad/features/ai/domain/models/ai_feedback.dart';

class AiFeedbackCard extends StatelessWidget {
  final AiFeedback feedback;

  const AiFeedbackCard({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = feedback.tierColor;

    return Semantics(
      label: 'AI Listing Assistant quality score: ${feedback.qualityScore} out of 100. Status: ${feedback.statusSummary}',
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Assistant Title & Quality Meter
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(feedback.tierIcon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Listing Assistant',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${feedback.qualityScore}/100',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.statusSummary,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: feedback.qualityScore / 100.0,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            const SizedBox(height: 12),

            // Suggestions List
            if (feedback.suggestions.isNotEmpty) ...[
              Text(
                'Suggestions to improve:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              ...feedback.suggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 18, color: color),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Highlights List
            if (feedback.highlights.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: feedback.highlights
                    .map(
                      (h) => Chip(
                        label: Text(h, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                        avatar: const Icon(Icons.check, size: 14, color: Colors.green),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
