import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/plan_model.dart';
import '../../data/sources/database_helper.dart';
import '../widgets/add_plan_sheet.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/plan_card.dart';
import 'plan_detail_screen.dart';
import 'calendar_screen.dart';
import 'range_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _username = '';
  List<PlanModel> _allPlans = [];
  List<PlanModel> _filteredPlans = [];
  String _searchQuery = '';
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    refreshPlans();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _username = prefs.getString('username') ?? 'Kullanıcı');
    }
  }

  Future<void> refreshPlans() async {
    final plans = await DatabaseHelper.instance.getMainPlans();
    if (mounted) {
      setState(() {
        _allPlans = plans;
        _applyFilters();
      });
    }
  }

  bool _isPlanForToday(PlanModel plan, DateTime today, String todayStr) {
    if (plan.isRange == 0) return plan.date == todayStr;
    try {
      final start = DateFormat('dd/MM/yyyy').parse(plan.date);
      final end = DateFormat('dd/MM/yyyy').parse(plan.endDate!);
      return (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
          (today.isBefore(end) || today.isAtSameMomentAs(end));
    } catch (e) {
      return false;
    }
  }

  void _applyFilters() {
    setState(() {
      final todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final today = DateFormat('dd/MM/yyyy').parse(todayStr);

      _filteredPlans = _allPlans.where((plan) {
        final matchesSearch = plan.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesCategory =
            _selectedFilter == 0 ||
            (_selectedFilter == 1 && _isPlanForToday(plan, today, todayStr)) ||
            (_selectedFilter == 2 && plan.isRange == 1) ||
            (_selectedFilter == 3 && plan.isRange == 0);
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _showAddPlanSheet({PlanModel? planToEdit}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (context) =>
          AddPlanSheet(existingPlan: planToEdit, onPlanAdded: refreshPlans),
    );
  }

  void _showEditRangePlanSheet(PlanModel plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final titleController = TextEditingController(text: plan.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: AppSizes.pLarge,
          right: AppSizes.pLarge,
          top: AppSizes.pLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aralık Planını Düzenle',
              style: TextStyle(
                color: textM,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSizes.hBoxHigh,
            TextField(
              controller: titleController,
              style: TextStyle(color: textM),
              decoration: InputDecoration(
                labelText: 'Plan Başlığı',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.glassBorder
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.rMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppSizes.rMedium),
                ),
              ),
            ),
            AppSizes.hBoxHigh,
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await DatabaseHelper.instance.updatePlan(
                  PlanModel(
                    id: plan.id,
                    title: titleController.text.trim(),
                    date: plan.date,
                    endDate: plan.endDate,
                    isRange: 1,
                    parentId: plan.parentId,
                  ),
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                refreshPlans();
                UIHelpers.showCustomSnackBar(ctx, 'Aralık planı güncellendi.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.pMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rMedium),
                ),
              ),
              child: const Text(
                'Güncelle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            AppSizes.hBoxHigh,
          ],
        ),
      ),
    );
  }

  void _showRangeTitleDialog(DateTimeRange picked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
        title: Text('Aralık Planına İsim Ver', style: TextStyle(color: textM)),
        content: TextField(
          controller: titleController,
          style: TextStyle(color: textM),
          decoration: InputDecoration(
            hintText: 'Örn: Final Haftası Kampı',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: isDark ? AppColors.background : Colors.white,
            ),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              final newPlan = PlanModel(
                title: titleController.text.trim(),
                date: DateFormat('dd/MM/yyyy').format(picked.start),
                endDate: DateFormat('dd/MM/yyyy').format(picked.end),
                isRange: 1,
              );
              final id = await DatabaseHelper.instance.insertPlan(newPlan);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RangePlannerScreen(
                      rangePlan: PlanModel(
                        id: id,
                        title: newPlan.title,
                        date: newPlan.date,
                        endDate: newPlan.endDate,
                        isRange: 1,
                      ),
                    ),
                  ),
                ).then((_) => refreshPlans());
              }
            },
            child: const Text(
              'Oluştur',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanTypeOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final textS = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.rLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.pLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Plan Türü Seçin',
              style: TextStyle(
                color: textM,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSizes.hBoxHigh,
            ListTile(
              leading: const Icon(
                LucideIcons.calendarPlus,
                color: AppColors.primary,
              ),
              title: Text(
                'Günlük Plan Ekle',
                style: TextStyle(color: textM, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Belirli bir gün için tek bir plan oluşturun.',
                style: TextStyle(color: textS),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddPlanSheet();
              },
            ),
            const Divider(color: AppColors.glassBorder),
            ListTile(
              leading: const Icon(
                LucideIcons.calendarRange,
                color: AppColors.aiHighlight,
              ),
              title: Text(
                'Aralık Planlama (Haftalık/Aylık)',
                style: TextStyle(color: textM, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Tarih aralığı seçip toplu planlar oluşturun.',
                style: TextStyle(color: textS),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDateRangePicker(
                  context: context,
                  locale: const Locale('tr', 'TR'),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null && mounted) _showRangeTitleDialog(picked);
              },
            ),
            AppSizes.hBoxHigh,
          ],
        ),
      ),
    );
  }

  void _deletePlan(PlanModel plan) async {
    await DatabaseHelper.instance.deletePlan(plan.id!);
    refreshPlans();
    if (mounted) {
      UIHelpers.showCustomSnackBar(
        context,
        '"${plan.title}" silindi.',
        isError: true,
      );
    }
  }

  void _handlePlanTap(PlanModel plan) {
    if (plan.isRange == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RangePlannerScreen(rangePlan: plan)),
      ).then((_) => refreshPlans());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlanDetailScreen(plan: plan)),
      ).then((_) => refreshPlans());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textM = isDark ? AppColors.textMain : AppColors.textMainLight;
    final bg = isDark ? AppColors.background : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0.0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSizes.pLarge,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba $_username',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nest Plan',
              style: TextStyle(
                color: textM,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.pLarge),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(AppSizes.rMedium),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: IconButton(
                icon: const Icon(
                  LucideIcons.calendarDays,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                ).then((_) => refreshPlans()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pLarge,
              vertical: AppSizes.pSmall,
            ),
            child: TextField(
              style: TextStyle(color: textM),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Planlarda ara...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: isDark ? AppColors.surface : AppColors.surfaceLight,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rLarge),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rLarge),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.glassBorder
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.rLarge),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pLarge,
              vertical: AppSizes.pSmall,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'Tümü',
                    index: 0,
                    selectedIndex: _selectedFilter,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 0;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: AppSizes.pSmall),
                  FilterChipWidget(
                    label: 'Bugün',
                    index: 1,
                    selectedIndex: _selectedFilter,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 1;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: AppSizes.pSmall),
                  FilterChipWidget(
                    label: 'Aralık',
                    index: 2,
                    selectedIndex: _selectedFilter,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 2;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: AppSizes.pSmall),
                  FilterChipWidget(
                    label: 'Günlük',
                    index: 3,
                    selectedIndex: _selectedFilter,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 3;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.pMedium),
          Expanded(
            child: _filteredPlans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.layers,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        AppSizes.hBoxNormal,
                        const Text(
                          'Henüz plan yok.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSizes.hBoxLow,
                        const Text(
                          'İlk planını oluşturmak için + ikonuna tıkla.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pLarge,
                      vertical: AppSizes.pMedium,
                    ),
                    itemCount: _filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _filteredPlans[index];
                      return PlanCard(
                        plan: plan,
                        onTap: () => _handlePlanTap(plan),
                        onEdit: () => plan.isRange == 1
                            ? _showEditRangePlanSheet(plan)
                            : _showAddPlanSheet(planToEdit: plan),
                        onDelete: () => _deletePlan(plan),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPlanTypeOptions,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
