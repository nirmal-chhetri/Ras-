import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import 'specimen_detail_screen.dart';

class StudioDrawer extends StatelessWidget {
  final List<DesignSpecimen> pinnedSpecimens;
  final AetherTheme theme;
  final Function(String) onUnpin;
  final Function(DesignSpecimen) onAddCustom;

  const StudioDrawer({
    super.key,
    required this.pinnedSpecimens,
    required this.theme,
    required this.onUnpin,
    required this.onAddCustom,
  });

  void _showAddCustomDialog(BuildContext context) {
    final titleController = TextEditingController();
    final makerController = TextEditingController();
    final urlController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: theme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.borderHairline),
          ),
          title: Text(
            'CLIP CUSTOM SPECIMEN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: theme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Specimen Name',
                    labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                  ),
                ),
                TextField(
                  controller: makerController,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Artisan / Maker',
                    labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                  ),
                ),
                TextField(
                  controller: urlController,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Image CDN / Web Link',
                    labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Estimated Value (USD)',
                    labelStyle: TextStyle(color: theme.textSecondary, fontSize: 12),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.borderHairline)),
                  ),
                ),
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
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newSpecimen = DesignSpecimen(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    maker: makerController.text.isEmpty ? 'Independent Artisan' : makerController.text,
                    studioLocation: 'Custom Curation',
                    estimatedUsd: double.tryParse(priceController.text) ?? 120.0,
                    atmosphereTag: 'custom',
                    imageUrl: urlController.text.isEmpty
                        ? 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=700&q=80'
                        : urlController.text,
                    aspectRatio: 1.0,
                    materialStory: 'Locally curated piece added directly to private studio collection.',
                    provenanceUrl: 'https://unsplash.com',
                    materials: ['Custom Craft'],
                    isUserPinned: true,
                  );
                  onAddCustom(newSpecimen);
                  Navigator.of(dialogCtx).pop();
                }
              },
              child: const Text('ADD SPECIMEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalVal = pinnedSpecimens.fold<double>(
      0.0,
      (sum, item) => sum + item.estimatedUsd,
    );

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
          'STUDIO COLLECTION',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: theme.accentGlow),
            tooltip: 'Clip from Web',
            onPressed: () => _showAddCustomDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pinnedSpecimens.isEmpty
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
                        fontSize: 20,
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
                      Text(
                        '${pinnedSpecimens.length} SPECIMENS CURATED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: theme.textSecondary,
                        ),
                      ),
                      Text(
                        'EST. \$${totalVal.toStringAsFixed(0)} USD',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.accentGlow,
                        ),
                      ),
                    ],
                  ),
                ),

                // Curated Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: pinnedSpecimens.length,
                    itemBuilder: (context, index) {
                      final item = pinnedSpecimens[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SpecimenDetailScreen(
                                specimen: item,
                                theme: theme,
                                onPinToggle: () => onUnpin(item.id),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.bgSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.borderHairline),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 500,
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    onUnpin(item.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
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
