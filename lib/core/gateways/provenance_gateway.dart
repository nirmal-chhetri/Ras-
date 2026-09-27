import 'package:url_launcher/url_launcher.dart';

/// Semantic Tool Gateway 3: Provenance & Decompression Gateway
/// Isolates browser redirection, atelier validation, and deep links.
abstract class IProvenanceGateway {
  bool isValidUrl(String url);
  Future<bool> canLaunchArtisanStore(String url);
  Future<bool> launchArtisanStore(String url);
}

class UrlLauncherProvenanceGateway implements IProvenanceGateway {
  @override
  bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
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
