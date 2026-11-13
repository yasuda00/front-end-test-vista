import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../models/service.dart';
import '../providers/company_provider.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: RefreshIndicator(
        onRefresh: () => context.read<CompanyProvider>().fetchCompanies(),
        color: const Color(0xFF4F46E5),
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverHeader(context),
            Consumer<CompanyProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.companies.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    ),
                  );
                }
                if (provider.errorMessage != null && provider.companies.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildError(provider.errorMessage!),
                  );
                }
                if (provider.companies.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final delay = Duration(
                          milliseconds: index < 6 ? index * 50 : 250,
                        );
                        return CompanyCard(company: provider.companies[index])
                            .animate(delay: delay)
                            .fadeIn(duration: 300.ms)
                            .slideY(
                              begin: 0.12,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            );
                      },
                      childCount: provider.companies.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF4F46E5),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double topPadding = MediaQuery.of(context).padding.top;
          final double currentHeight = constraints.biggest.height;
          final double minHeight = topPadding + kToolbarHeight;
          const double maxHeight = 160.0;
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
                // 1. EXPANDED HEADER: Title text only (no logo)
                if (expandedOpacity > 0.0)
                  Positioned(
                    left: 20,
                    bottom: 22,
                    child: Opacity(
                      opacity: expandedOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Vista Solutions',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<CompanyProvider>(
                            builder: (_, p, __) => Text(
                              '${p.companies.length} compan${p.companies.length == 1 ? 'y' : 'ies'} registered',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. PINNED / COLLAPSED BAR: Logo only (no title text)
                if (collapsedOpacity > 0.0)
                  Positioned(
                    left: 16,
                    top: topPadding,
                    height: kToolbarHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: collapsedOpacity,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'V',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4F46E5),
                                height: 1,
                              ),
                            ),
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
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateServiceScreen()),
          ),
          icon: const Icon(Icons.add_business_outlined, color: Colors.white),
          tooltip: 'Create Service',
        ),
        IconButton(
          onPressed: () => context.read<CompanyProvider>().fetchCompanies(),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateCompanyScreen()),
      ),
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Add Company',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ).animate().scale(delay: 300.ms, duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 52, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.read<CompanyProvider>().fetchCompanies(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Extracted Empty State (const constructor)
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_outlined,
                  size: 48, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            Text(
              'No companies yet',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add your first company to get started\nmanaging services.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9CA3AF), height: 1.5),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
    );
  }
}

// ─────────────────────────────────────────
// Company Card
// ─────────────────────────────────────────
class CompanyCard extends StatelessWidget {
  final Company company;
  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF5F3FF), Color(0xFFEEF2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.business_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.tag_rounded,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Text(
                              company.registrationNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _CountBadge(count: company.services.length),
                ],
              ),
            ),
            if (company.services.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SERVICES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...company.services.map((s) => ServiceTile(service: s)),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: Color(0xFFCBD5E1)),
                    SizedBox(width: 6),
                    Text(
                      'No services added yet',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: count > 0 ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: count > 0 ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Service Tile
// ─────────────────────────────────────────
class ServiceTile extends StatelessWidget {
  final Service service;
  const ServiceTile({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.design_services_rounded,
                size: 15, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                if (service.description != null && service.description!.isNotEmpty)
                  Text(
                    service.description!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'RM ${service.price.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
