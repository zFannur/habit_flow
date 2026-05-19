/// Bucketed mood score used by mood ↔ completion correlations.
///
/// Mood is recorded on a 1..10 scale in [JournalEntryModel]. The bands match
/// SPEC §6 (low ≤ 4, high ≥ 7).
enum MoodBand {
  low,
  mid,
  high,
  none;

  /// Buckets a raw mood value (1..10). `null` → [MoodBand.none].
  static MoodBand fromMood(int? mood) {
    if (mood == null) return MoodBand.none;
    if (mood <= 4) return MoodBand.low;
    if (mood >= 7) return MoodBand.high;
    return MoodBand.mid;
  }
}
