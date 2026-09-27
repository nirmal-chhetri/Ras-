import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import '../../core/gateways/storage_gateway.dart';
import '../../core/gateways/provenance_gateway.dart';
import '../../core/pipelines/ingestion_pipeline.dart';
import 'specimen_detail_screen.dart';

class StudioDrawer extends StatefulWidget {
  final List<DesignSpecimen> pinnedSpecimens;
  final AetherTheme theme;
  final Function(String) onUnpin;
  final Function(DesignSpecimen) onAddCustom;
  final VoidCallback? onClearAll;
  final SpecimenIngestionPipeline? ingestionPipeline;

  const StudioDrawer({
    super.key,
    required this.pinnedSpecimens,
    required this.theme,
    required this.onUnpin,
    required this.onAddCustom,
    this.onClearAll,
    this.ingestionPipeline,
  });

  @override
  State<StudioDrawer> createState() => _StudioDrawerState();
}

class _StudioDrawerState extends State<StudioDrawer> {
  late final SpecimenIngestionPipeline _ingestionPipeline;

  @override
  void initState() {
    super.initState();
    _ingestionPipeline = widget.ingestionPipeline ??
        SpecimenIngestionPipeline(
          storageGateway: SharedPreferencesStorageGateway(),
          provenanceGateway: UrlLauncherProvenanceGateway(),
        );
  }

  void _showAddCustomDialog(BuildContext context) {
    final titleController = TextEditingController();
    final makerController = TextEditingController();
    final urlController = TextEditingController();
    final priceController = TextEditingController();
    String? validationError;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = widget.theme;
            return AlertDialog(
              backgroundColor: theme.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.borderHairline.withValues(alpha: 0.8),
                  width: 1.0,
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.add_link_rounded, size: 18, color: theme.accentGlow),
                  const SizedBox(width: 8),
                  Text(
                    'CLIP ARTISAN SPECIMEN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input artisan link and details. The Ingestion Pipeline will verify invariants and match atmosphere.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: theme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      style: TextStyle(color: theme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Image CDN or Artisan Web Link *',
                        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                        hintText: 'https://...',
                        hintStyle: TextStyle(color: theme.textSecondary.withValues(alpha: 0.5), fontSize: 11),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.accentGlow)),
                      ),
                    ),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: theme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Specimen Name *',
                        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.accentGlow)),
                      ),
                    ),
                    TextField(
                      controller: makerController,
                      style: TextStyle(color: theme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Artisan / Studio (e.g. Studio Arhoj)',
                        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.accentGlow)),
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: theme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Estimated Value (USD)',
                        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                        hintText: '150',
                        hintStyle: TextStyle(color: theme.textSecondary.withValues(alpha: 0.5), fontSize: 11),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.accentGlow)),
                      ),
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          validationError!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.redAccent,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text('CANCEL', style: TextStyle(color: theme.textSecondary, fontSize: 11)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.textPrimary,
                    foregroundColor: theme.bgPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final rawUrl = urlController.text.trim();
                    final rawTitle = titleController.text.trim();

                    if (rawTitle.isEmpty) {
                      setDialogState(() => validationError = 'Specimen Name is required.');
                      return;
                    }

                    // Ingest via Pipeline
                    final result = await _ingestionPipeline.ingest(
                      rawUrl: rawUrl.isEmpty
                          ? 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c'
                          : rawUrl,
                      title: rawTitle,
                      maker: makerController.text.trim(),
                      estimatedUsd: double.tryParse(priceController.text.trim()) ?? 150.0,
                    );

                    if (!result.isSuccess) {
                      setDialogState(() => validationError = result.errorMessage ?? 'Ingestion failed.');
                      return;
                    }

                    widget.onAddCustom(result.specimen!);
                    Navigator.of(dialogCtx).pop();
                  },
                  child: Text(
                    'INGEST SPECIMEN',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.bgSurface,
        title: Text(
          'CLEAR STUDIO CANVAS?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: widget.theme.textPrimary,
          ),
        ),
        content: Text(
          'This will remove all pinned specimens from your personal studio collection.',
          style: TextStyle(color: widget.theme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: TextStyle(color: widget.theme.textSecondary, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onClearAll?.call();
            },
            child: const Text('CLEAR ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final pinned = widget.pinnedSpecimens;
    final totalVal = pinned.fold<double>(0.0, (sum, item) => sum + item.estimatedUsd);
    final avgVal = pinned.isEmpty ? 0.0 : totalVal / pinned.length;

    return Scaffold(
      backgroundColor: theme.bgPrimary,
      appBar: AppBar(
        backgroundColor: theme.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PERSONAL STUDIO MOODBOARD',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          if (pinned.isNotEmpty && widget.onClearAll != null)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, size: 19, color: theme.textSecondary),
              tooltip: 'Clear Studio',
              onPressed: () => _confirmClearAll(context),
            ),
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, size: 20, color: theme.accentGlow),
            tooltip: 'Clip from Web',
            onPressed: () => _showAddCustomDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pinned.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_mosaic_outlined,
                      size: 48,
                      color: theme.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Studio is a Blank Canvas',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore the Sanctuary and pin specimens to compose your personal living or working space.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.textPrimary,
                        side: BorderSide(color: theme.borderHairline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: Icon(Icons.add, size: 14, color: theme.accentGlow),
                      label: Text(
                        'CLIP WEB SPECIMEN',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showAddCustomDialog(context),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Room Budget Telemetry Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.bgSurface,
                    border: Border(
                      bottom: BorderSide(color: theme.borderHairline.withValues(alpha: 0.6)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${pinned.length} SPECIMENS CURATED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AVG. \$${avgVal.toStringAsFixed(0)} / SPECIMEN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.0,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EST. SPACE INVESTMENT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${totalVal.toStringAsFixed(0)} USD',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.accentGlow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Curated Moodboard Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: pinned.length,
                    itemBuilder: (context, index) {
                      final item = pinned[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SpecimenDetailScreen(
                                specimen: item,
                                theme: theme,
                                onPinToggle: () => widget.onUnpin(item.id),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.bgSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.borderHairline.withValues(alpha: 0.8),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 600,
                              ),
                              // Bottom subtle metadata vignette
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.maker.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Unpin 'X' action
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  key: Key('unpin_${item.id}'),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onUnpin(item.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
}
