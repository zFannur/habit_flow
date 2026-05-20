import 'package:url_launcher/url_launcher.dart';
import '../../core/config/env.dart';
import 'telegram_service.dart';

// Mobile/Desktop implementation of TelegramService methods that interface with the system.

void openInvoiceWeb(
  String invoiceUrl,
  void Function(TgInvoiceStatus status) onStatus,
) {
  onStatus(TgInvoiceStatus.failed);
}

void openLinkWeb(String url) {
  final uri = Uri.parse(url);
  launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
}

String getInitDataWeb() => '';

Future<void> openBotDeepLinkPlatform(String token) async {
  final botUsername = Env.botUsername;
  final url = 'https://t.me/$botUsername?start=link_$token';
  
  // Try launching tg:// scheme first for native client transition
  final nativeUri = Uri.parse('tg://resolve?domain=$botUsername&start=link_$token');
  if (await canLaunchUrl(nativeUri)) {
    await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
  } else {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Telegram link: $url');
    }
  }
}
