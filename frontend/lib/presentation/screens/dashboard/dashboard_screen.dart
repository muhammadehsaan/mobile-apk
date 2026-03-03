import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:frontend/src/providers/auth_provider.dart';
import 'package:frontend/src/providers/dashboard_provider.dart';
import 'package:frontend/src/theme/app_theme.dart';
import 'package:frontend/presentation/widgets/dashboard/dashboard_content.dart';
import 'package:frontend/presentation/widgets/globals/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const double _minZoom = 0.8;
  static const double _maxZoom = 2.5;

  final TransformationController _zoomController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.setInstance();
        dashboardProvider.initialize();

        final authProvider = context.read<AuthProvider>();
        authProvider.addListener(_handleAuthStateChange);
      }
    });
  }

  void _handleAuthStateChange() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.state == AuthState.unauthenticated) {
      context.read<DashboardProvider>().stopPolling();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Widget _buildZoomableContent({required Widget child}) {
    return InteractiveViewer(
      transformationController: _zoomController,
      minScale: _minZoom,
      maxScale: _maxZoom,
      panEnabled: _currentScale > 1.01,
      scaleEnabled: true,
      boundaryMargin: const EdgeInsets.all(100),
      onInteractionUpdate: (_) {
        final scale = _zoomController.value.getMaxScaleOnAxis();
        final clamped = scale.clamp(_minZoom, _maxZoom).toDouble();
        if ((clamped - _currentScale).abs() > 0.01 && mounted) {
          setState(() {
            _currentScale = clamped;
          });
        }
      },
      child: SizedBox.expand(child: child),
    );
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_handleAuthStateChange);
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (isMobile) {
          return Scaffold(
            backgroundColor: AppTheme.creamWhite,
            appBar: AppBar(
              backgroundColor: AppTheme.primaryMaroon,
              foregroundColor: Colors.white,
              title: Text(
                dashboardProvider.currentPageTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            drawer: Drawer(
              width: 78.w,
              child: SafeArea(
                child: PremiumSidebar(
                  isExpanded: true,
                  selectedIndex: dashboardProvider.selectedMenuIndex,
                  onMenuSelected: (index) {
                    dashboardProvider.selectMenu(index);
                    Navigator.of(context).maybePop();
                  },
                  onToggle: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            body: _buildZoomableContent(
              child: DashboardContent(
                selectedIndex: dashboardProvider.selectedMenuIndex,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.creamWhite,
          body: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: dashboardProvider.isSidebarExpanded ? 28.w : 8.w,
                child: PremiumSidebar(
                  isExpanded: dashboardProvider.isSidebarExpanded,
                  selectedIndex: dashboardProvider.selectedMenuIndex,
                  onMenuSelected: (index) {
                    dashboardProvider.selectMenu(index);
                  },
                  onToggle: () {
                    dashboardProvider.toggleSidebar();
                  },
                ),
              ),
              Expanded(
                child: _buildZoomableContent(
                  child: DashboardContent(
                    selectedIndex: dashboardProvider.selectedMenuIndex,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
