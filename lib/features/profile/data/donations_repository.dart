import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/repository_error.dart';

/// Calls the `create_invoice` Edge Function and returns the Telegram invoice
/// URL that should be passed to [TelegramService.openInvoice].
///
/// Auth: the active Supabase session JWT is forwarded automatically by the
/// [SupabaseClient] functions client (Authorization: Bearer ...).
class DonationsRepository {
  const DonationsRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  /// Creates a Telegram Stars invoice for [stars] stars.
  ///
  /// Returns the `invoice_url` string on success.
  /// Throws a [RepositoryError] subtype on HTTP / parse failures.
  Future<String> createInvoice(int stars) async {
    try {
      final response = await _client.functions.invoke(
        'create_invoice',
        body: <String, dynamic>{
          'amount': stars,
          'label': '$stars Telegram Stars — HabitFlow support',
        },
      );

      final data = response.data;
      String? invoiceUrl;

      // Accept both `invoice_link` (current Edge Function payload) and the
      // legacy `invoice_url` key — earlier drafts of the function used the
      // latter and we don't want a stale deploy to break the flow.
      String? pick(Map<String, dynamic> m) =>
          (m['invoice_link'] ?? m['invoice_url']) as String?;

      if (data is Map<String, dynamic>) {
        invoiceUrl = pick(data);
      } else if (data is String) {
        // Edge Function may return a raw JSON string instead of a decoded map.
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          invoiceUrl = pick(decoded);
        }
      }

      if (invoiceUrl == null || invoiceUrl.isEmpty) {
        throw RepositoryError.unknown(
          'create_invoice returned no invoice link',
          message: 'stars=$stars data=$data',
        );
      }

      return invoiceUrl;
    } on FunctionException catch (e) {
      throw RepositoryError.network(
        cause: e,
        message: 'Edge Function create_invoice failed (status=${e.status}): '
            '${e.details}',
      );
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }
}
