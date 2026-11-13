import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../providers/company_provider.dart';
import '../providers/service_provider.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  int? _selectedCompanyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CompanyProvider>();
      if (provider.companies.isEmpty && !provider.isLoading) {
        provider.fetchCompanies();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final serviceProvider = context.read<ServiceProvider>();
    if (serviceProvider.isCreating) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompanyId == null) return;

    final parsedPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final success = await serviceProvider.createService(
      companyId: _selectedCompanyId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: parsedPrice,
    );

    if (!mounted) return;

    if (success) {
      await context.read<CompanyProvider>().fetchCompanies();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Service created successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serviceProvider.errorMessage ?? 'Failed to create service.',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF7C3AED),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double topPadding = MediaQuery.of(context).padding.top;
                final double currentHeight = constraints.biggest.height;
                final double minHeight = topPadding + kToolbarHeight;
                const double maxHeight = 140.0;
                final double delta = maxHeight - minHeight;
                final double expandRatio = delta > 0
                    ? ((currentHeight - minHeight) / delta).clamp(0.0, 1.0)
                    : 0.0;

                final double expandedOpacity =
                    ((expandRatio - 0.35) / 0.65).clamp(0.0, 1.0);
                final double collapsedOpacity =
                    (1.0 - (expandRatio / 0.35)).clamp(0.0, 1.0);

                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Expanded: Title & Subtitle
                      if (expandedOpacity > 0.0)
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: Opacity(
                            opacity: expandedOpacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'New Service',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Add a service to an existing company',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Collapsed: Title in toolbar next to back button
                      if (collapsedOpacity > 0.0)
                        Positioned(
                          left: 60,
                          top: topPadding,
                          height: kToolbarHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Opacity(
                              opacity: collapsedOpacity,
                              child: Text(
                                'New Service',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<CompanyProvider>(
              builder: (context, companyProvider, _) {
                if (companyProvider.isLoading && companyProvider.companies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    ),
                  );
                }

                if (companyProvider.errorMessage != null &&
                    companyProvider.companies.isEmpty) {
                  return _buildError(companyProvider);
                }

                if (companyProvider.companies.isEmpty) {
                  return _buildNoCompanies();
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Company Dropdown
                        const _FieldLabel(
                          label: 'Company',
                          icon: Icons.business_rounded,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedCompanyId,
                          decoration: const InputDecoration(
                            hintText: 'Select a company',
                            prefixIcon: Icon(
                              Icons.business_outlined,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          items: companyProvider.companies
                              .map((Company c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCompanyId = v),
                          validator: (v) =>
                              v == null ? 'Please select a company.' : null,
                        ).animate().fadeIn(delay: 80.ms).slideX(begin: -0.05),

                        const SizedBox(height: 20),

                        // Service Name
                        const _FieldLabel(
                          label: 'Service Name',
                          icon: Icons.design_services_rounded,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Web Development',
                            prefixIcon: Icon(
                              Icons.design_services_outlined,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Service name is required.'
                              : null,
                        ).animate().fadeIn(delay: 140.ms).slideX(begin: -0.05),

                        const SizedBox(height: 20),

                        // Description
                        const _FieldLabel(
                          label: 'Description (optional)',
                          icon: Icons.notes_rounded,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Brief description of the service...',
                            alignLabelWithHint: true,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

                        const SizedBox(height: 20),

                        // Price
                        const _FieldLabel(
                          label: 'Price (RM)',
                          icon: Icons.attach_money_rounded,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitForm(),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            prefixText: 'RM  ',
                            prefixStyle: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Price is required.';
                            }
                            final price = double.tryParse(v.trim());
                            if (price == null || !price.isFinite) {
                              return 'Enter a valid number.';
                            }
                            if (price < 0) {
                              return 'Price cannot be negative.';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 260.ms).slideX(begin: -0.05),

                        const SizedBox(height: 36),

                        // Optimized: Only the submit button listens to ServiceProvider state
                        Consumer<ServiceProvider>(
                          builder: (context, serviceProvider, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: serviceProvider.isCreating
                                    ? null
                                    : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  disabledBackgroundColor:
                                      const Color(0xFF7C3AED).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: serviceProvider.isCreating
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Service',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.1),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(CompanyProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: provider.fetchCompanies,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCompanies() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Text(
          'Please create a company first\nbefore adding a service.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9CA3AF), height: 1.6),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6366F1)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
