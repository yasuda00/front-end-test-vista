import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final provider = context.read<CompanyProvider>();
    if (provider.isCreating) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.createCompany(
      name: _nameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Company created successfully!'),
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
          content: Text(provider.errorMessage ?? 'Failed to create company.'),
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
            backgroundColor: const Color(0xFF4F46E5),
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
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                                  'New Company',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Register a new company to the system',
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
                                'New Company',
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Company Name Field
                    const _FieldLabel(
                      label: 'Company Name',
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Acme Corporation',
                        prefixIcon: Icon(
                          Icons.business_outlined,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Company name is required.'
                          : null,
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),

                    const SizedBox(height: 20),

                    // Registration Number Field
                    const _FieldLabel(
                      label: 'Registration Number',
                      icon: Icons.tag_rounded,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _registrationController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitForm(),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 202300123456',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Registration number is required.'
                          : null,
                    ).animate().fadeIn(delay: 180.ms).slideX(begin: -0.05),

                    const SizedBox(height: 36),

                    // Optimized: Only the submit button rebuilds when provider state changes
                    Consumer<CompanyProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: provider.isCreating ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              disabledBackgroundColor:
                                  const Color(0xFF4F46E5).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: provider.isCreating
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
                                        'Create Company',
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
                    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.1),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6366F1)),
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
