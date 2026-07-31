import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nukkad/core/constants/app_constants.dart';
import 'package:nukkad/features/ai/presentation/widgets/ai_feedback_card.dart';
import 'package:nukkad/features/listing/presentation/providers/create_listing_notifier.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: '₹1,500');
  final _imageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createFormState = ref.watch(createListingNotifierProvider);
    final notifier = ref.read(createListingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Post Neighborhood Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Form',
            onPressed: () {
              _titleController.clear();
              _descController.clear();
              _priceController.clear();
              _imageController.clear();
              notifier.resetForm();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Banner if present
              if (createFormState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          createFormState.errorMessage!,
                          style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Real-Time AI Listing Assistant Feedback Card
              AiFeedbackCard(feedback: createFormState.aiFeedback),

              const SizedBox(height: 24),

              // Category Selection
              const Text('Listing Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: createFormState.category,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF059669)),
                ),
                items: AppConstants.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                AppConstants.getCategoryIcon(cat),
                                size: 18,
                                color: AppConstants.getCategoryColor(cat),
                              ),
                              const SizedBox(width: 10),
                              Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) notifier.updateCategory(val);
                },
              ),

              const SizedBox(height: 18),

              // Title Field
              const Text('Listing Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                onChanged: notifier.updateTitle,
                decoration: const InputDecoration(
                  hintText: 'e.g. Wooden Study Desk with Ergonomic Chair',
                  prefixIcon: Icon(Icons.title_rounded, color: Color(0xFF059669)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),

              const SizedBox(height: 18),

              // Price / Intent Terms
              const Text('Price / Terms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'e.g. ₹2,500 / Free Lend / Willing to pay ₹300',
                  prefixIcon: Icon(Icons.sell_outlined, color: Color(0xFF059669)),
                ),
              ),

              const SizedBox(height: 18),

              // Product Image URL (Optional)
              const Text('Product Image URL (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text(
                'Paste an image URL or leave empty for auto category image.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  hintText: 'https://images.unsplash.com/photo-...',
                  prefixIcon: Icon(Icons.image_outlined, color: Color(0xFF059669)),
                ),
              ),

              const SizedBox(height: 18),

              // Description Field
              const Text('Description & Item Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                onChanged: notifier.updateDescription,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Explain item condition, usage period, reasons for listing, or specific requirements...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Description is required' : null,
              ),

              const SizedBox(height: 18),

              // Locality Dropdown
              const Text('Approximate Area', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text(
                'Note: Exact address is never collected or stored.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: createFormState.approximateArea,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF059669)),
                ),
                items: AppConstants.approximateAreas
                    .map((area) => DropdownMenuItem(
                          value: area,
                          child: Text(area),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) notifier.updateArea(val);
                },
              ),

              const SizedBox(height: 18),

              // Contact Preference
              const Text('Contact Preference', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: createFormState.contactPreference,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.contact_phone_outlined, color: Color(0xFF059669)),
                ),
                items: AppConstants.contactPreferences
                    .map((pref) => DropdownMenuItem(
                          value: pref,
                          child: Text(pref),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) notifier.updateContactPreference(val);
                },
              ),

              const SizedBox(height: 32),

              // Publish Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: createFormState.isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await notifier.submitListing();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listing published locally!'),
                                  backgroundColor: Color(0xFF059669),
                                ),
                              );
                              context.pop();
                            }
                          }
                        },
                  icon: createFormState.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.publish_rounded),
                  label: Text(
                    createFormState.isSubmitting ? 'Publishing...' : 'Publish Listing',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
