import 'telegram_service.dart';

// Non-web stubs — TelegramService gates everything behind `kIsWeb`, so these
// only need to satisfy the conditional import.
void openInvoiceWeb(
  String invoiceUrl,
  void Function(TgInvoiceStatus status) onStatus,
) {
  onStatus(TgInvoiceStatus.failed);
}

void openLinkWeb(String url) {}

String getInitDataWeb() => '';
