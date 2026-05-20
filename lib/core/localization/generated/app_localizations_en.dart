// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HabitFlow';

  @override
  String get navToday => 'Today';

  @override
  String get navHabits => 'Habits';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navAi => 'AI';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonReplace => 'Replace';

  @override
  String get commonUnderstand => 'Got it';

  @override
  String get commonSending => 'Sending request…';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get aiSettingsModelSearchHint => 'Search models…';

  @override
  String get aiSettingsModelsEmpty => 'No models match';

  @override
  String get correlationsRefresh => 'Get correlations';

  @override
  String get correlationsRefreshAgain => 'Refresh';

  @override
  String get correlationsLoading => 'AI is crunching the data…';

  @override
  String get correlationsNoKey =>
      'Add an OpenRouter key in AI settings to get insights.';

  @override
  String correlationsNotEnoughData(int count) {
    return 'Need at least 7 logs in the last 30 days. Currently: $count.';
  }

  @override
  String get correlationsRateLimited =>
      'OpenRouter daily limit reached. Try again tomorrow.';

  @override
  String get correlationsGeneric => 'Couldn\'t fetch correlations. Try again.';

  @override
  String get correlationsEmpty =>
      'No strong correlations yet — keep logging habits.';

  @override
  String get correlationsDirectionUp => '↑ positive link';

  @override
  String get correlationsDirectionDown => '↓ inverse link';

  @override
  String get correlationsDirectionMixed => '↔ unclear';

  @override
  String get commonNext => 'Next';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonCreateHabit => 'Create habit';

  @override
  String get commonNewBadge => '✦ New';

  @override
  String get commonNameLabel => 'Name';

  @override
  String get commonCategoryLabel => 'Category';

  @override
  String get commonAdd => 'Add';

  @override
  String get langRu => '🇷🇺 RU';

  @override
  String get langEn => '🇬🇧 EN';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageEnglish => 'English';

  @override
  String get todayAddHabit => 'Add habit';

  @override
  String get todayGreetingMorning => 'Good morning';

  @override
  String get todayGreetingAfternoon => 'Good afternoon';

  @override
  String get todayGreetingEvening => 'Good evening';

  @override
  String todayHeaderStats(int done, int total, int streak) {
    return '$done of $total habits · Streak $streak days';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBegin => 'Begin';

  @override
  String get onboardingFinish => 'Done, let\'s go!';

  @override
  String get onboardingS1Sub => 'Habits. Journal. AI that understands.';

  @override
  String get onboardingS2Title => 'You are what you repeat';

  @override
  String get onboardingS2P1 =>
      'Every habit is a vote for the person you want to become. Small actions, repeated again and again, change your identity.';

  @override
  String get onboardingS2P2 =>
      'HabitFlow is built on behavioral science: not on willpower, but on a system that works even when motivation fades.';

  @override
  String get onboardingS2Quote =>
      '“Every action is a vote for the person you wish to become.”';

  @override
  String get onboardingS2Author => '— James Clear';

  @override
  String get onboardingS2LabelCenter => 'You';

  @override
  String get onboardingS2LabelHabits => 'Habits';

  @override
  String get onboardingS2LabelActions => 'Actions';

  @override
  String get onboardingS2LabelIdentity => 'Identity';

  @override
  String get onboardingS3Title => 'Start with one';

  @override
  String get onboardingS3Sub =>
      'Don\'t try to change everything. Pick one habit for this month.';

  @override
  String get onboardingS3Templates => 'From templates';

  @override
  String get onboardingS3TemplatesSub => 'Recommended';

  @override
  String get onboardingS3BadgeRecommended => '★ Recommended';

  @override
  String get onboardingS3Custom => 'Custom habit';

  @override
  String get onboardingS3CustomSub => 'Make your own';

  @override
  String get onboardingS4Title => 'Where to start?';

  @override
  String get onboardingS4Max => 'Maximum 3 habits';

  @override
  String onboardingS4Selected(int count) {
    return 'Selected: $count';
  }

  @override
  String get onboardingS4Btn => 'Create selected';

  @override
  String get onboardingS5Title => 'I\'ll remind you';

  @override
  String get onboardingS5Text =>
      'At the scheduled time the bot will send a Telegram message. You can mark it done right there — no need to open the app.';

  @override
  String get onboardingS5BotName => 'HabitFlow Bot';

  @override
  String get onboardingS5TgMsg => '🌅 Morning meditation — your habit time';

  @override
  String get onboardingS5DoneBtn => '✅ Done';

  @override
  String get onboardingS5SkipBtn => '⏭ Skipped';

  @override
  String get emptyTitleNoHabits => 'Your habits will live here';

  @override
  String get emptyDescNoHabits =>
      'Create your first one — to start\nyou only need one tiny habit';

  @override
  String get emptyTitleNoEntries => 'Journal is empty';

  @override
  String get emptyDescNoEntries =>
      'Write down how the day went —\nit takes a couple of minutes';

  @override
  String get emptyActionNoEntries => 'Write today';

  @override
  String get emptyTitleNoSummaries => 'Summaries not ready yet';

  @override
  String emptyDescNoSummaries(int count) {
    return 'The first summary appears after 30 journal entries. You have $count now.';
  }

  @override
  String get emptyActionNoSummaries => 'Write a reflection';

  @override
  String get emptyTitleNoKey => 'Connect OpenRouter';

  @override
  String get emptyDescNoKey =>
      'AI runs on your key. The free model is available without payment.';

  @override
  String get emptyTitleNoInternet => 'No connection';

  @override
  String get emptyDescNoInternet => 'Check your connection\nand try again';

  @override
  String get emptyTitleAiLimit => 'Free model limit';

  @override
  String get emptyDescAiLimit => 'You\'ve used all 200 requests for today.';

  @override
  String emptyAiLimitCountdown(int hours, int minutes) {
    return 'Limit resets in $hours h $minutes min';
  }

  @override
  String get emptyAiLimitUpgrade => 'Switch to a paid model';

  @override
  String get emptyTitleBadKey => 'Key doesn\'t work';

  @override
  String get emptyDescBadKey =>
      'Looks like the key is invalid or your balance is empty.';

  @override
  String get emptyActionBadKey => 'Replace key';

  @override
  String get emptyTitleAllDone => 'All habits done today';

  @override
  String get emptyNoKeyCta => 'Enter key';

  @override
  String get celebrationQuote1 =>
      'Small steps, every day — that\'s the whole secret.';

  @override
  String get celebrationQuote2 => 'You showed up. That\'s already a victory.';

  @override
  String get celebrationQuote3 => 'Consistency beats intensity every time.';

  @override
  String get quoteOfDayLabel => 'QUOTE OF THE DAY';

  @override
  String get habitsListTitle => 'Habits';

  @override
  String get habitsListSearchHint => 'Find a habit';

  @override
  String get habitsListSortLabel => 'Sort';

  @override
  String get habitsListSortByProgress => 'By progress';

  @override
  String get habitsListSortByName => 'By name';

  @override
  String get habitsListSortByCreated => 'By creation date';

  @override
  String get habitsListSortByStreak => 'By streak';

  @override
  String get habitsListFilterAll => 'All';

  @override
  String get habitsListFilterActive => 'Active';

  @override
  String get habitsListFilterArchive => 'Archive';

  @override
  String get habitsListEmpty => 'No habits found';

  @override
  String habitsListCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '$count habit',
    );
    return '$_temp0';
  }

  @override
  String get habitCardArchiveBadge => 'ARCHIVED';

  @override
  String habitCreateStepCounter(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get habitCreateSubmit => 'Create habit';

  @override
  String get habitCreateStep1Title => 'Which type?';

  @override
  String get habitCreateStep1Subtitle => 'This affects how you\'ll mark it.';

  @override
  String get habitTypeBinary => 'Binary';

  @override
  String get habitTypeBinaryDesc => 'Did / didn\'t do';

  @override
  String get habitTypeCountable => 'Countable';

  @override
  String get habitTypeCountableDesc => 'X times a day';

  @override
  String get habitTypeTimed => 'Timed';

  @override
  String get habitTypeTimedDesc => 'X minutes / hours';

  @override
  String get habitTypeAnti => 'Anti-habit';

  @override
  String get habitTypeAntiDesc => 'Don\'t do X';

  @override
  String get habitCreateStep2Title => 'Name and icon';

  @override
  String get habitCreateStep2Subtitle => 'What will the habit be called?';

  @override
  String get habitCreateStep2NameHint => 'E.g.: Morning meditation';

  @override
  String get habitCreateStep2IconLabel => 'Icon';

  @override
  String get habitCreateStep2EmojiTab => '😀 Emoji';

  @override
  String get habitCreateStep2PhotoTab => '📷 Photo';

  @override
  String get habitCreateStep2PhotoUpload => 'Upload photo';

  @override
  String get habitCreateStep2PhotoHint => 'PNG, JPG up to 5 MB';

  @override
  String get habitCreateStep2AccentColorLabel => 'Accent color';

  @override
  String get habitCategoryNew => '+ New';

  @override
  String get habitCreateStep3Title => 'Schedule';

  @override
  String get habitCreateStep3Subtitle => 'When and how often?';

  @override
  String get habitCreateStep3RepeatTypeLabel => 'Repeat type';

  @override
  String get habitCreateStep3FrequencyLabel => 'Frequency';

  @override
  String habitCreateStep3FrequencyValue(int value) {
    return '$value times a week';
  }

  @override
  String habitCreateStep3EveryNDays(int n) {
    return 'Every $n days';
  }

  @override
  String get habitCreateStep3SelectDays => 'PICK DAYS';

  @override
  String get habitCreateStep3GoalLabel => 'Daily goal';

  @override
  String get habitCreateStep3RemindersLabel => 'Reminders';

  @override
  String get habitCreateStep3AddReminder => 'Add time';

  @override
  String get habitCreateStep3RemindersHint =>
      'Multiple allowed — e.g., 3 times a day for water.';

  @override
  String get habitCreateStep3PeriodLabel => 'Period';

  @override
  String get habitCreateStep3StartDateLabel => 'Start date';

  @override
  String get habitCreateStep3Endless => 'Open-ended';

  @override
  String get habitCreateStep4Title => 'Reinforcement';

  @override
  String get habitCreateStep4Subtitle =>
      'Optional. These fields use proven techniques to make the habit actually stick. You can skip.';

  @override
  String get habitCreateStep4StackingTitle => 'Habit Stacking';

  @override
  String get habitCreateStep4StackingSubtitle =>
      'After which habit do you do the new one?';

  @override
  String get habitCreateStep4IntentionTitle => 'Implementation Intention';

  @override
  String get habitCreateStep4IntentionSubtitle =>
      'Where and when exactly do you do it?';

  @override
  String get habitCreateStep4IntentionWhenHint =>
      'When: e.g., after the shower';

  @override
  String get habitCreateStep4IntentionWhereHint =>
      'Where: e.g., on the bedroom mat';

  @override
  String get habitCreateStep4IdentityTitle => 'Identity';

  @override
  String get habitCreateStep4IdentitySubtitle =>
      'I\'m becoming a person who...';

  @override
  String get habitCreateStep4IdentityHint => 'E.g.: values their mental health';

  @override
  String get habitCreateStep4IdentityNote =>
      'This phrase will appear in reminders.';

  @override
  String get habitCreateStep4TwoMinTitle => '2-minute version';

  @override
  String get habitCreateStep4TwoMinSubtitle => 'Minimum for hard days';

  @override
  String get habitCreateStep4TwoMinHint =>
      'E.g.: 1 minute of breathing instead of meditation';

  @override
  String get habitCreateStep4RewardTitle => 'Reward';

  @override
  String get habitCreateStep4RewardSubtitle => 'What I get when I do it';

  @override
  String get habitCreateStep4RewardHint => 'E.g.: a good cup of coffee after';

  @override
  String get habitCreateStep4PreviewLabel => 'PREVIEW';

  @override
  String get habitCreateStep4PreviewName => 'Habit name';

  @override
  String get habitCreateStep4PreviewStreak => 'STREAK';

  @override
  String get habitCreateStep4PreviewToday => 'TODAY';

  @override
  String get habitCreateStep4ActionBinary => 'Mark as done';

  @override
  String get habitCreateStep4ActionAnti => 'Hold on';

  @override
  String get habitCreateStep4ActionOther => 'Log progress';

  @override
  String get habitCreateStep4Reset => 'Reset and refill';

  @override
  String get habitDetailStatistics => 'Statistics';

  @override
  String get habitDetailCurrentStreak => 'Current\nstreak';

  @override
  String get habitDetailBestStreak => 'Best\nstreak';

  @override
  String get habitDetailLast30Days => 'Last 30\ndays';

  @override
  String get habitDetailLast90Days => 'Last 90 days';

  @override
  String get habitDetailHeatmapDone => 'Done';

  @override
  String get habitDetailHeatmapPartial => 'Partial';

  @override
  String get habitDetailHeatmapMissed => 'Missed';

  @override
  String get habitDetailHeatmapSkip => 'Skip';

  @override
  String get habitDetailDynamics => 'Completion dynamics';

  @override
  String habitDetailChartWeeks(int count) {
    return '$count weeks';
  }

  @override
  String habitDetailChartAverage(int percent) {
    return 'Average: $percent%';
  }

  @override
  String habitDetailChartWeekShort(int n) {
    return 'W$n';
  }

  @override
  String get habitDetailBehavior => 'Behavioral settings';

  @override
  String get habitDetailBehaviorAfter => 'After';

  @override
  String get habitDetailBehaviorWhere => 'Where';

  @override
  String get habitDetailBehaviorIdentity => 'I';

  @override
  String get habitDetailBehaviorMin => 'Minimum';

  @override
  String get habitDetailBehaviorReward => 'Reward';

  @override
  String get habitMoreSheetTitle => 'Details';

  @override
  String get habitMoreSheetIdentity => 'Identity';

  @override
  String get habitMoreSheetReward => 'Reward';

  @override
  String get habitMoreSheetIntention => 'Intention';

  @override
  String get habitDetailHistory => 'Recent marks';

  @override
  String get habitDetailArchive => 'Archive';

  @override
  String get habitDetailAiChat => 'Open in AI chat';

  @override
  String get habitDetailHistoryEdit => 'Add details →';

  @override
  String habitCardStackAfter(String emoji, String name) {
    return 'After: $emoji $name';
  }

  @override
  String get habitCardLogSheetTitle => 'Mark as done';

  @override
  String get habitCardLogSheetFull => 'Fully';

  @override
  String get habitCardLogSheetFullSub => 'I did it as planned';

  @override
  String get habitCardLogSheetMin => 'Minimum version';

  @override
  String habitCardLogSheetMinSub(String version) {
    return '$version';
  }

  @override
  String get habitDetailArchivedToast => 'Habit archived';

  @override
  String get habitDetailDeletedToast => 'Habit deleted';

  @override
  String get habitDetailDeleteConfirmTitle => 'Delete habit?';

  @override
  String get habitDetailDeleteConfirmBody =>
      'All logs and history will be permanently removed. This cannot be undone.';

  @override
  String get habitHistoryStatusDone => 'Done';

  @override
  String get habitHistoryStatusMissed => 'Missed';

  @override
  String get habitTimerStart => '▶ Start';

  @override
  String get habitTimerPause => '⏸ Pause';

  @override
  String get habitAntiDays => 'DAYS';

  @override
  String get habitAntiMarkedToday => '✓ Marked today';

  @override
  String get habitAntiHeld => 'Held on';

  @override
  String get journalCardTitle => 'Write the day';

  @override
  String get journalCardSubtitle => '4 short questions or free text';

  @override
  String get journalCardEditLink => 'Add details →';

  @override
  String get journalListTitle => 'Journal';

  @override
  String get journalListFilterAll => 'All';

  @override
  String get journalListFilterMonth => 'This month';

  @override
  String get journalListFilterLowMood => 'Low mood';

  @override
  String get journalListFilterHighMood => 'High mood';

  @override
  String get journalListEntriesLabel => 'entries';

  @override
  String journalListStreak(int days) {
    return 'Journaling for $days days in a row 🔥';
  }

  @override
  String get journalFabLabel => 'Today';

  @override
  String get journalEditHeaderToday => 'Today';

  @override
  String journalEditHeaderDate(String date) {
    return '$date';
  }

  @override
  String get journalEditSave => 'Save';

  @override
  String get journalEditSaving => 'Saving…';

  @override
  String get journalEditLoadError => 'Failed to load entry';

  @override
  String get journalEditHabitsTitle => 'TODAY\'S HABITS';

  @override
  String get journalEditMoodLabel => 'Mood';

  @override
  String get journalEditEnergyLabel => 'Energy';

  @override
  String get journalEditEntryLabel => 'Entry';

  @override
  String get journalEditPlaceholder =>
      'What\'s important to write about today?';

  @override
  String journalEditCharCount(int count) {
    return '$count characters';
  }

  @override
  String get journalEditQuestionsShow => 'Show questions';

  @override
  String get journalEditQuestionsHide => 'Hide';

  @override
  String get journalEditQuestionPlaceholder => 'Write here...';

  @override
  String get journalEditChangeTemplate => 'Edit question template';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsWeekTab => 'Week';

  @override
  String get analyticsMonthTab => 'Month';

  @override
  String get analyticsSummaryLabel => 'COMPLETION';

  @override
  String analyticsTrend(int percent, String period) {
    return '↑ +$percent% vs last $period';
  }

  @override
  String analyticsSubtextPeriod(String label) {
    return 'Period: $label';
  }

  @override
  String get analyticsMetricCompleted => 'Done';

  @override
  String get analyticsMetricSkipped => 'Missed';

  @override
  String get analyticsMetricBestDay => 'Best day';

  @override
  String get analyticsMetricStreaks => 'Streaks ↑';

  @override
  String get analyticsMetricStreaksSubtext => 'habits growing';

  @override
  String get analyticsBarChartTitle => 'Completion by day';

  @override
  String get analyticsLegendLow => '< 40%';

  @override
  String get analyticsLegendMedium => '40–70%';

  @override
  String get analyticsLegendHigh => '> 70%';

  @override
  String get analyticsHeatmapTitle => 'Heatmap';

  @override
  String get analyticsHeatmapLess => 'Less';

  @override
  String get analyticsHeatmapMore => 'More';

  @override
  String get analyticsPieTitle => 'By category';

  @override
  String get analyticsMoodLineTitle => 'Mood and energy';

  @override
  String get analyticsMoodLine => 'Mood';

  @override
  String get analyticsEnergyLine => 'Energy';

  @override
  String get analyticsTopHabitsTitle => 'Top 3 habits';

  @override
  String get analyticsTopHabitsSubtitle => 'BY COMPLETION';

  @override
  String get analyticsAiCorrelationsTitle => 'AI correlations';

  @override
  String get analyticsAiCorrelationsMessage =>
      'Add an OpenRouter key to see personal correlations and insights about your habits.';

  @override
  String get analyticsSettings => 'Settings';

  @override
  String get weeklyReviewTitle => 'Weekly review';

  @override
  String get weeklyReviewSubtitle =>
      'A short Sunday checklist to close the week.';

  @override
  String get weeklyReviewItemStreak => 'Looked at streaks';

  @override
  String get weeklyReviewItemCorrelations => 'Looked at correlations';

  @override
  String get weeklyReviewItemGoals => 'Updated goals';

  @override
  String get aiScreenTitle => 'AI';

  @override
  String get aiChatTab => 'Chat';

  @override
  String get aiSummariesTab => 'Summaries';

  @override
  String get aiPromptsTab => 'Prompts';

  @override
  String get aiChatHistoryTitle => 'Chat history';

  @override
  String get aiChatNew => 'New chat';

  @override
  String get aiChatDisclaimerTitle => 'Your key, your data';

  @override
  String get aiChatDisclaimerText =>
      'Each message is an API call billed to your OpenRouter account. The free model is limited to 200 requests per day. Content is sent to OpenRouter and the model provider. Don\'t write anything you\'re not ready to share.';

  @override
  String get aiChatDisclaimerOk => 'Got it';

  @override
  String get aiChatInputPlaceholder => 'Ask anything...';

  @override
  String aiChatTokenCounter(String model, int used, int limit) {
    return '$model · $used/$limit';
  }

  @override
  String get aiChatRename => 'Rename';

  @override
  String get aiChatDelete => 'Delete';

  @override
  String get aiChatRenameTitle => 'New title';

  @override
  String get aiChatRenameHint => 'Chat title';

  @override
  String get aiChatDeleteConfirmTitle => 'Delete chat?';

  @override
  String get aiChatDeleteConfirmText =>
      'All messages will be removed. This cannot be undone.';

  @override
  String get aiChatRateLimitedTitle => 'Daily limit reached';

  @override
  String get aiChatRateLimitedText =>
      'You\'ve hit OpenRouter\'s daily limit (200 requests for the free model). Try again tomorrow or pick a paid model in AI settings.';

  @override
  String get aiChatNoKeyTitle => 'Add an OpenRouter key';

  @override
  String get aiChatNoKeyText =>
      'Open AI settings and paste your key — the chat needs it to send messages.';

  @override
  String get aiChatErrorGeneric =>
      'Something went wrong. Check your connection and try again.';

  @override
  String aiSummariesInfoBanner(int interval, int count, int remaining) {
    return 'A summary is generated automatically every $interval journal entries. You currently have $count — next one in $remaining.';
  }

  @override
  String get aiSummariesBadgeNew => 'New';

  @override
  String aiSummaryTitle(int from, int to) {
    return 'Summary $from–$to';
  }

  @override
  String get aiSummaryAsk => 'Ask about this summary';

  @override
  String get aiSummaryRegenerate => 'Regenerate';

  @override
  String get aiPromptsFilterAll => 'All';

  @override
  String get aiPromptsFilterAnalysis => 'Analysis';

  @override
  String get aiPromptsFilterEmotions => 'Emotions';

  @override
  String get aiPromptsFilterGrowth => 'Growth';

  @override
  String get aiPromptsFilterRelapse => 'Relapse';

  @override
  String get aiPromptsIntro =>
      'Ready-made AI prompts. Tap one to start a chat with it.';

  @override
  String aiPromptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prompts',
      one: '$count prompt',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionBasic => 'Basics';

  @override
  String get profileMenuJournal => 'Journal';

  @override
  String get profileMenuAccount => 'Account & language';

  @override
  String get profileSectionSettings => 'Settings';

  @override
  String get profileMenuAiSettings => 'AI & model';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuAppearance => 'Appearance';

  @override
  String get profileMenuReflectionTemplate => 'Reflection template';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileMenuDonate => 'Support the project';

  @override
  String get profileMenuAbout => 'About';

  @override
  String get profileMenuPrivacy => 'Privacy policy';

  @override
  String get profileMenuContact => 'Contact author';

  @override
  String get profileSectionDanger => 'DANGER ZONE';

  @override
  String get profileMenuDeleteAccount => 'Delete account';

  @override
  String get profileDeleteAccountTitle => 'Delete account?';

  @override
  String get profileDeleteAccountMessage =>
      'All habits, journal entries and AI history will be deleted permanently. This cannot be undone.';

  @override
  String get profileBadgeSupporter => '💎 Supporter';

  @override
  String get profileStatsDaysWithApp => 'days with\nthe app';

  @override
  String get profileStatsActiveHabits => 'active\nhabits';

  @override
  String get profileStatsStreak => 'days\nin a row';

  @override
  String get donateTitle => 'Support';

  @override
  String get donateHeroTitle => 'Thanks for being here';

  @override
  String get donateHeroMessage =>
      'HabitFlow will always be free. If the app helps you — support the project via Telegram Stars. It gives me time and energy to make it better.';

  @override
  String get donatePresetsLabel => 'Pick an amount';

  @override
  String get donateCustomInputLabel => 'Enter ⭐ count';

  @override
  String get donateCustomButton => 'Custom ⭐';

  @override
  String get donateBenefitsTitle => 'Supporter perks';

  @override
  String get donateBenefitBadge => '“Supporter” badge in profile';

  @override
  String get donateBenefitStyle => 'Extra AI style — Poet';

  @override
  String get donateBenefitColor => 'Custom UI accent color';

  @override
  String get donateBenefitThanks => 'Thanks on the About screen (optional)';

  @override
  String get donatePopularBadge => 'Popular';

  @override
  String donateCta(int stars) {
    return 'Support with $stars ⭐';
  }

  @override
  String get donateMobileNote =>
      'Telegram Desktop is ~30% better than mobile (Apple/Google fees).';

  @override
  String get donateHistoryLink => 'Donation history';

  @override
  String get donateThanksTitle => 'Thank you!';

  @override
  String get donateThanksMessage =>
      'You supported the project. It means a lot!';

  @override
  String get donateErrorTitle => 'Error';

  @override
  String get donateErrorMessage =>
      'Could not create the invoice. Please try again.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsTelegramBanner => 'Notifications via Telegram';

  @override
  String get notificationsTelegramDesc =>
      'Notifications come from @habitflow_bot. They are regular messages with buttons — no system push.';

  @override
  String get notificationsReflectionSection => 'Evening reflection';

  @override
  String get notificationsReflectionToggle => 'Remind to journal';

  @override
  String get notificationsReflectionHint =>
      'The bot will ask what mattered today';

  @override
  String get notificationsQuietHoursSection => 'Quiet hours';

  @override
  String get notificationsQuietToggle => 'Do not disturb';

  @override
  String get notificationsQuietFrom => 'From';

  @override
  String get notificationsQuietTo => 'To';

  @override
  String get notificationsQuietHint =>
      'No notifications during this window. Habits inside it are postponed.';

  @override
  String get notificationsSoundSection => 'Sound';

  @override
  String get notificationsSoundOn => 'With sound';

  @override
  String get notificationsSoundOnSubtitle => 'default';

  @override
  String get notificationsSoundOff => 'Silent';

  @override
  String get notificationsSoundOffSubtitle => 'via disable_notification';

  @override
  String get notificationsPreviewSection => 'Notification preview';

  @override
  String get notificationsPreviewHint =>
      'This is what a regular habit reminder looks like';

  @override
  String get notificationsPreviewBubble =>
      '🌅 Morning meditation — your time. Minimum is 1 minute.\nStreak: 14 days 🔥';

  @override
  String get notificationsPreviewDone => '✅ Done';

  @override
  String get notificationsPreviewSkip => '⏭ Skipped';

  @override
  String get notificationsPreviewMore => '💬 More';

  @override
  String get notificationsRareSection => 'Rare notifications';

  @override
  String get notificationsWeeklyTitle => 'Sunday weekly review';

  @override
  String get notificationsWeeklySubtitle => 'Every Sunday evening';

  @override
  String get notificationsAiSummaryTitle => 'AI summary ready';

  @override
  String get notificationsAiSummarySubtitle => 'After every 30 entries';

  @override
  String get notificationsRecoveryTitle => 'Recovery messages';

  @override
  String get notificationsRecoverySubtitle => 'If you missed yesterday';

  @override
  String get aiSettingsTitle => 'AI & model';

  @override
  String get aiSettingsApiKeySection => 'OpenRouter key';

  @override
  String get aiSettingsApiKeyLabel => 'API key';

  @override
  String get aiSettingsApiKeyLink => 'Where to get a key';

  @override
  String get aiSettingsHowItWorks => 'How it works';

  @override
  String get aiSettingsStatusUnchecked => 'Unchecked';

  @override
  String get aiSettingsStatusChecking => 'Checking...';

  @override
  String get aiSettingsStatusOk => 'Key works';

  @override
  String get aiSettingsStatusError => 'Authorization error';

  @override
  String get aiSettingsTestButton => 'Test request';

  @override
  String get aiSettingsModelSection => 'Model';

  @override
  String get aiSettingsAllModelsLink => 'All OpenRouter models';

  @override
  String get aiSettingsStyleSection => 'AI style';

  @override
  String get aiSettingsStyleSubtitle => 'Tone of conversation';

  @override
  String get aiBadgeFree => 'FREE';

  @override
  String get aiSettingsStyleExampleHeader =>
      'EXAMPLE REPLY · “I MISSED THE GYM THREE TIMES”';

  @override
  String get aiSettingsUsageSection => 'Usage';

  @override
  String get aiSettingsUsageToday => 'Today';

  @override
  String get aiSettingsUsageMonth => 'This month';

  @override
  String get aiSettingsUsageSpent => 'Spent';

  @override
  String get aiSettingsUsageNote =>
      'Paid models are billed to your OpenRouter account.';

  @override
  String get aiSettingsHowItem1Title => 'Your key — your data';

  @override
  String get aiSettingsHowItem1Text =>
      'The API key is stored only on your device and sent directly to OpenRouter. HabitFlow never sees the key or your messages.';

  @override
  String get aiSettingsHowItem2Title => 'OpenRouter — model router';

  @override
  String get aiSettingsHowItem2Text =>
      'It\'s a proxy that gives access to dozens of AI models via a single API. Free models don\'t require any balance.';

  @override
  String get aiSettingsHowItem3Title => 'Pay only for what you use';

  @override
  String get aiSettingsHowItem3Text =>
      'Paid models are billed from your OpenRouter balance. Free ones — with limits 20 RPM and 200 RPD — work right away.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceThemeSection => 'Theme';

  @override
  String get appearanceThemeLight => '☀️ Light';

  @override
  String get appearanceThemeDark => '🌙 Dark';

  @override
  String get appearanceThemeAuto => '⚙️ Auto';

  @override
  String get appearanceAccentSection => 'Accent';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentAmber => 'Amber';

  @override
  String get accentRed => 'Red';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentPink => 'Pink';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentGray => 'Gray';

  @override
  String get accountTitle => 'Account & language';

  @override
  String get accountTelegramSection => 'Telegram';

  @override
  String get accountLanguageSection => 'Interface language';

  @override
  String get accountFirstDaySection => 'First day of the week';

  @override
  String get accountFirstDayMonday => 'Monday';

  @override
  String get accountFirstDaySunday => 'Sunday';

  @override
  String get reflectionTemplateTitle => 'Reflection template';

  @override
  String get reflectionTemplateDesc =>
      'These questions appear in your journal when you toggle “Show questions”. You can edit, add and remove them.';

  @override
  String get reflectionTemplateQ1 => 'What was the highlight today?';

  @override
  String get reflectionTemplateQ2 => 'What are you grateful for?';

  @override
  String get reflectionTemplateQ3 => 'What would you do differently?';

  @override
  String get reflectionTemplateQ4 => 'What charged / drained you?';

  @override
  String get reflectionTemplateInputHint => 'Question…';

  @override
  String get reflectionTemplateAddButton => 'Add question';

  @override
  String get reflectionTemplateResetButton => 'Reset to template';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutWhatLabel => 'What it is';

  @override
  String get aboutWhatText =>
      'HabitFlow is a Telegram Mini App: habit tracker, reflection journal and AI analyst of personal data.';

  @override
  String get aboutPrinciplesLabel => 'Principles';

  @override
  String get aboutPrinciplesText =>
      'Telegram-native · BYO OpenRouter key · fully free with Telegram Stars donations · behavioral science in UX · RU + EN from day one.';

  @override
  String get aboutSpecLink => 'Specification';

  @override
  String get aboutSpecHint => 'SPEC.md in the repo';

  @override
  String get aboutChannelLink => 'Telegram channel';

  @override
  String get aboutSourceLink => 'Source code';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyAuthLabel => 'Authorization';

  @override
  String get privacyAuthText =>
      'HabitFlow uses Telegram initData to log in — we don\'t ask for email or password. The signed Telegram payload goes to the server, we validate it and issue a JWT. No third-party providers.';

  @override
  String get privacyStorageLabel => 'What is stored';

  @override
  String get privacyStorageText =>
      'Habits, completion marks, journal entries, AI chat history are stored in our Supabase Postgres. Data is tied to your telegram_user_id and only accessible to you via Row Level Security.';

  @override
  String get privacyKeyLabel => 'OpenRouter key';

  @override
  String get privacyKeyText =>
      'The OpenRouter API key is yours (BYO key). It\'s stored locally on your device and sent directly to OpenRouter. HabitFlow never sees the key or your AI messages.';

  @override
  String get privacyNotCollectLabel => 'What we DO NOT collect';

  @override
  String get privacyNotCollectText =>
      'We don\'t log initData, don\'t share data with third parties, don\'t show ads, don\'t use analytics on user actions in-app.';

  @override
  String get privacyDeletionLabel => 'Data deletion';

  @override
  String get privacyDeletionText =>
      'In the “Danger zone” section you can delete your account. All habits, journal and AI history are cascade-deleted from the DB. Recovery is not possible.';

  @override
  String get privacyContactLabel => 'Contact';

  @override
  String get privacyContactText =>
      'Privacy questions — write to the author via the “Contact author” section in profile.';

  @override
  String get contactTitle => 'Contact author';

  @override
  String get contactDesc =>
      'Write if you found a bug, have a feature idea or just want to chat. Usually I reply within a couple of days.';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelEmail => 'Email';

  @override
  String get contactChannelGithub => 'GitHub Issues';

  @override
  String contactCopiedToast(String value) {
    return 'Copied: $value';
  }

  @override
  String get splashOutsideTelegramTitle => 'Open in Telegram';

  @override
  String get splashOutsideTelegramDesc =>
      'HabitFlow is a Telegram Mini App. Open it through the bot or a t.me link inside Telegram.';

  @override
  String get splashAuthErrorTitle => 'Sign-in failed';

  @override
  String get splashAuthErrorDesc =>
      'Could not connect to the server. Check your connection and try again.';

  @override
  String get errorNetworkTitle => 'No internet';

  @override
  String get errorNetworkDesc => 'Check your connection and try again.';

  @override
  String get errorUnauthorizedTitle => 'Sign in required';

  @override
  String get errorUnauthorizedDesc =>
      'Your session has expired. Please re-open the app.';

  @override
  String get errorAiLimitTitle => 'Limit reached';

  @override
  String get errorAiLimitDesc =>
      'You\'ve used all requests. Wait or switch to a different model.';

  @override
  String get errorServerTitle => 'Server is unavailable';

  @override
  String get errorServerDesc =>
      'Something went wrong on the server side. Please try again.';

  @override
  String get errorValidationTitle => 'Check the fields';

  @override
  String get errorValidationDesc => 'Some fields are filled in incorrectly.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericDesc =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorRetry => 'Retry';

  @override
  String get errorRelogin => 'Re-open';

  @override
  String get errorWait => 'Wait';

  @override
  String get errorChangeModel => 'Change model';
}
