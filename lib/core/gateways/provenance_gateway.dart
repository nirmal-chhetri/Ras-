import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// FILE: lib/core/gateways/provenance_gateway.dart
/// ARCHITECTURE LAYER: Semantic Tool Gateway 3 — Provenance & Decompression (Phase 2)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// In alignment with the Slow-Commerce manifesto, Aether does NOT host transactional
/// checkout carts or aggressive 1-click purchases. Instead, users acquire pieces
/// directly from the maker through the Slow-Commerce Decompression Gate.
///
/// [IProvenanceGateway] abstracts URL validation, intent testing, and external
/// application/browser launching.
///
/// [UrlLauncherProvenanceGateway] provides the production implementation using
/// the `url_launcher` package with [LaunchMode.externalApplication].
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add atelier deep-linking or custom in-app custom tabs:
///   Implement a subclass of [IProvenanceGateway] or customize [LaunchMode].
/// ============================================================================

/// Contract defining URL verification and external artisan store launching.
abstract class IProvenanceGateway {
  /// Validates whether a raw string constitutes a valid, non-empty HTTP/HTTPS URL.
  bool isValidUrl(String url);

  /// Checks if the operating system or browser environment can launch the given URI.
  Future<bool> canLaunchArtisanStore(String url);

  /// Launches the artisan store URL in the user's default external browser.
  Future<bool> launchArtisanStore(String url);
}

/// Production implementation of [IProvenanceGateway] using Flutter's [url_launcher].
class UrlLauncherProvenanceGateway implements IProvenanceGateway {
  @override
  bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Future<bool> canLaunchArtisanStore(String url) async {
    if (!isValidUrl(url)) return false;
    return canLaunchUrl(Uri.parse(url.trim()));
  }

  @override
  Future<bool> launchArtisanStore(String url) async {
    if (!isValidUrl(url)) return false;
    final uri = Uri.parse(url.trim());
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
