// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HabitFlow';

  @override
  String get navToday => 'Сегодня';

  @override
  String get navHabits => 'Привычки';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navAi => 'ИИ';

  @override
  String get navProfile => 'Профиль';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonReplace => 'Заменить';

  @override
  String get commonUnderstand => 'Понятно';

  @override
  String get commonSending => 'Отправляем запрос…';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonOpen => 'Открыть';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get aiSettingsModelSearchHint => 'Поиск модели…';

  @override
  String get aiSettingsModelsEmpty => 'Ничего не найдено';

  @override
  String get correlationsRefresh => 'Получить корреляции';

  @override
  String get correlationsRefreshAgain => 'Обновить';

  @override
  String get correlationsLoading => 'ИИ анализирует данные…';

  @override
  String get correlationsNoKey =>
      'Чтобы получить инсайты, добавь ключ OpenRouter в настройках ИИ.';

  @override
  String correlationsNotEnoughData(int count) {
    return 'Нужно минимум 7 отметок за последние 30 дней. Сейчас: $count.';
  }

  @override
  String get correlationsRateLimited =>
      'Лимит OpenRouter исчерпан. Попробуй завтра.';

  @override
  String get correlationsGeneric =>
      'Не удалось получить корреляции. Попробуй ещё раз.';

  @override
  String get correlationsEmpty =>
      'Сильных корреляций пока не нашлось — продолжай отмечать привычки.';

  @override
  String get correlationsDirectionUp => '↑ положительная связь';

  @override
  String get correlationsDirectionDown => '↓ обратная связь';

  @override
  String get correlationsDirectionMixed => '↔ неоднозначно';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonRetry => 'Попробовать снова';

  @override
  String get commonOpenSettings => 'Открыть настройки';

  @override
  String get commonCreateHabit => 'Создать привычку';

  @override
  String get commonNewBadge => '✦ Новая';

  @override
  String get commonNameLabel => 'Название';

  @override
  String get commonCategoryLabel => 'Категория';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get langRu => '🇷🇺 RU';

  @override
  String get langEn => '🇬🇧 EN';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get todayAddHabit => 'Добавить привычку';

  @override
  String get todayGreetingMorning => 'Доброе утро';

  @override
  String get todayGreetingAfternoon => 'Добрый день';

  @override
  String get todayGreetingEvening => 'Добрый вечер';

  @override
  String todayHeaderStats(int done, int total, int streak) {
    return '$done из $total привычек · Streak $streak дней';
  }

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingBegin => 'Начать';

  @override
  String get onboardingFinish => 'Готово, поехали!';

  @override
  String get onboardingS1Sub => 'Привычки. Дневник. ИИ, который понимает.';

  @override
  String get onboardingS2Title => 'Ты — то, что повторяешь';

  @override
  String get onboardingS2P1 =>
      'Каждая привычка — это голосование за тип человека, которым ты хочешь стать. Маленькие действия, повторённые снова и снова, меняют твою идентичность.';

  @override
  String get onboardingS2P2 =>
      'HabitFlow строится на науке о поведении: не на силе воли, а на системе, которая работает даже когда мотивация угасает.';

  @override
  String get onboardingS2Quote =>
      '«Каждое действие — голос за того, кем ты становишься.»';

  @override
  String get onboardingS2Author => '— Джеймс Клир';

  @override
  String get onboardingS2LabelCenter => 'Ты';

  @override
  String get onboardingS2LabelHabits => 'Привычки';

  @override
  String get onboardingS2LabelActions => 'Действия';

  @override
  String get onboardingS2LabelIdentity => 'Личность';

  @override
  String get onboardingS3Title => 'Начнём с одной';

  @override
  String get onboardingS3Sub =>
      'Не пытайся изменить всё сразу. Выбери одну привычку на этот месяц.';

  @override
  String get onboardingS3Templates => 'Из шаблонов';

  @override
  String get onboardingS3TemplatesSub => 'Рекомендовано';

  @override
  String get onboardingS3BadgeRecommended => '★ Рекомендуем';

  @override
  String get onboardingS3Custom => 'Своя привычка';

  @override
  String get onboardingS3CustomSub => 'Придумай сам';

  @override
  String get onboardingS4Title => 'С чего начать?';

  @override
  String get onboardingS4Max => 'Максимум 3 привычки';

  @override
  String onboardingS4Selected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get onboardingS4Btn => 'Создать выбранные';

  @override
  String get onboardingS5Title => 'Я буду напоминать';

  @override
  String get onboardingS5Text =>
      'В назначенное время бот пришлёт сообщение в Telegram. Ты сможешь отметить выполнение прямо там — без открытия приложения.';

  @override
  String get onboardingS5BotName => 'HabitFlow Bot';

  @override
  String get onboardingS5TgMsg =>
      '🌅 Утренняя медитация — время твоей привычки';

  @override
  String get onboardingS5DoneBtn => '✅ Сделано';

  @override
  String get onboardingS5SkipBtn => '⏭ Пропустил';

  @override
  String get emptyTitleNoHabits => 'Здесь будут твои привычки';

  @override
  String get emptyDescNoHabits =>
      'Создай первую — для начала\nдостаточно одной маленькой';

  @override
  String get emptyTitleNoEntries => 'Дневник пока пуст';

  @override
  String get emptyDescNoEntries =>
      'Запиши, как прошёл день —\nэто займёт пару минут';

  @override
  String get emptyActionNoEntries => 'Записать сегодня';

  @override
  String get emptyTitleNoSummaries => 'Сводки ещё не готовы';

  @override
  String emptyDescNoSummaries(int count) {
    return 'Первая сводка появится после 30 записей в дневнике. Сейчас у тебя $count.';
  }

  @override
  String get emptyActionNoSummaries => 'Записать рефлексию';

  @override
  String get emptyTitleNoKey => 'Подключи OpenRouter';

  @override
  String get emptyDescNoKey =>
      'ИИ работает на твоём ключе. Бесплатная модель доступна без оплаты.';

  @override
  String get emptyTitleNoInternet => 'Нет связи';

  @override
  String get emptyDescNoInternet => 'Проверь подключение\nи попробуй снова';

  @override
  String get emptyTitleAiLimit => 'Лимит бесплатной модели';

  @override
  String get emptyDescAiLimit => 'Ты использовал все 200 запросов на сегодня.';

  @override
  String emptyAiLimitCountdown(int hours, int minutes) {
    return 'Лимит обнулится через $hours ч $minutes мин';
  }

  @override
  String get emptyAiLimitUpgrade => 'Перейти на платную модель';

  @override
  String get emptyTitleBadKey => 'Ключ не работает';

  @override
  String get emptyDescBadKey =>
      'Похоже, ключ неверный или закончились средства на счёте.';

  @override
  String get emptyActionBadKey => 'Заменить ключ';

  @override
  String get emptyTitleAllDone => 'Все привычки сегодня';

  @override
  String get emptyNoKeyCta => 'Ввести ключ';

  @override
  String get celebrationQuote1 =>
      'Маленькие шаги каждый день — вот и весь секрет.';

  @override
  String get celebrationQuote2 => 'Ты пришёл. Это уже победа.';

  @override
  String get celebrationQuote3 => 'Последовательность важнее интенсивности.';

  @override
  String get quoteOfDayLabel => 'ЦИТАТА ДНЯ';

  @override
  String get habitsListTitle => 'Привычки';

  @override
  String get habitsListSearchHint => 'Найти привычку';

  @override
  String get habitsListSortLabel => 'Сортировка';

  @override
  String get habitsListSortByProgress => 'По прогрессу';

  @override
  String get habitsListSortByName => 'По названию';

  @override
  String get habitsListSortByCreated => 'По дате создания';

  @override
  String get habitsListSortByStreak => 'По стрику';

  @override
  String get habitsListFilterAll => 'Все';

  @override
  String get habitsListFilterActive => 'Активные';

  @override
  String get habitsListFilterArchive => 'Архив';

  @override
  String get habitsListEmpty => 'Привычки не найдены';

  @override
  String habitsListCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count привычек',
      few: '$count привычки',
      one: '$count привычка',
    );
    return '$_temp0';
  }

  @override
  String get habitCardArchiveBadge => 'АРХИВ';

  @override
  String habitCreateStepCounter(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get habitCreateSubmit => 'Создать привычку';

  @override
  String get habitEditSubmit => 'Редактировать привычку';

  @override
  String get habitCreateStep1Title => 'Какой тип?';

  @override
  String get habitCreateStep1Subtitle =>
      'Это влияет на то, как ты будешь её отмечать.';

  @override
  String get habitTypeBinary => 'Бинарная';

  @override
  String get habitTypeBinaryDesc => 'Сделал / не сделал';

  @override
  String get habitTypeCountable => 'Количественная';

  @override
  String get habitTypeCountableDesc => 'X раз в день';

  @override
  String get habitTypeTimed => 'По длительности';

  @override
  String get habitTypeTimedDesc => 'X минут / часов';

  @override
  String get habitTypeAnti => 'Анти-привычка';

  @override
  String get habitTypeAntiDesc => 'Не делать X';

  @override
  String get habitCreateStep2Title => 'Название и иконка';

  @override
  String get habitCreateStep2Subtitle => 'Как будет называться привычка?';

  @override
  String get habitCreateStep2NameHint => 'Например: Медитация утром';

  @override
  String get habitCreateStep2IconLabel => 'Иконка';

  @override
  String get habitCreateStep2EmojiTab => '😀 Эмодзи';

  @override
  String get habitCreateStep2PhotoTab => '📷 Фото';

  @override
  String get habitCreateStep2PhotoUpload => 'Загрузить фото';

  @override
  String get habitCreateStep2PhotoHint => 'PNG, JPG до 5 МБ';

  @override
  String get habitCreateStep2AccentColorLabel => 'Цвет акцента';

  @override
  String get habitCategoryNew => '+ Новая';

  @override
  String get habitCreateStep3Title => 'Расписание';

  @override
  String get habitCreateStep3Subtitle => 'Когда и как часто?';

  @override
  String get habitCreateStep3RepeatTypeLabel => 'Тип повтора';

  @override
  String get habitCreateStep3FrequencyLabel => 'Частота';

  @override
  String habitCreateStep3FrequencyValue(int value) {
    return '$value раза в неделю';
  }

  @override
  String habitCreateStep3EveryNDays(int n) {
    return 'Каждые $n дней';
  }

  @override
  String get habitCreateStep3SelectDays => 'ВЫБЕРИТЕ ДНИ';

  @override
  String get habitCreateStep3GoalLabel => 'Цель на день';

  @override
  String get habitCreateStep3RemindersLabel => 'Напоминания';

  @override
  String get habitCreateStep3AddReminder => 'Добавить время';

  @override
  String get habitCreateStep3RemindersHint =>
      'Можно несколько — например, 3 раза в день для воды.';

  @override
  String get habitCreateStep3PeriodLabel => 'Период';

  @override
  String get habitCreateStep3StartDateLabel => 'Дата начала';

  @override
  String get habitCreateStep3Endless => 'Бессрочно';

  @override
  String get habitCreateStep4Title => 'Усиление';

  @override
  String get habitCreateStep4Subtitle =>
      'Опционально. Эти поля используют проверенные техники, чтобы привычка реально прижилась. Можно пропустить.';

  @override
  String get habitCreateStep4StackingTitle => 'Habit Stacking';

  @override
  String get habitCreateStep4StackingSubtitle =>
      'После какой привычки делать новую?';

  @override
  String get habitCreateStep4IntentionTitle => 'Implementation Intention';

  @override
  String get habitCreateStep4IntentionSubtitle =>
      'Где и когда именно ты это делаешь?';

  @override
  String get habitCreateStep4IntentionWhenHint => 'Когда: например, после душа';

  @override
  String get habitCreateStep4IntentionWhereHint =>
      'Где: например, на коврике в спальне';

  @override
  String get habitCreateStep4IdentityTitle => 'Identity';

  @override
  String get habitCreateStep4IdentitySubtitle =>
      'Я становлюсь человеком, который...';

  @override
  String get habitCreateStep4IdentityHint =>
      'Например: ценит своё психическое здоровье';

  @override
  String get habitCreateStep4IdentityNote =>
      'Эта фраза будет появляться в напоминаниях.';

  @override
  String get habitCreateStep4TwoMinTitle => '2-минутная версия';

  @override
  String get habitCreateStep4TwoMinSubtitle => 'Минимум для трудных дней';

  @override
  String get habitCreateStep4TwoMinHint =>
      'Например: 1 минута дыхания вместо медитации';

  @override
  String get habitCreateStep4RewardTitle => 'Награда';

  @override
  String get habitCreateStep4RewardSubtitle => 'Что я получаю, когда выполняю';

  @override
  String get habitCreateStep4RewardHint =>
      'Например: чашка хорошего кофе после';

  @override
  String get habitCreateStep4PreviewLabel => 'ПРЕДПРОСМОТР';

  @override
  String get habitCreateStep4PreviewName => 'Название привычки';

  @override
  String get habitCreateStep4PreviewStreak => 'СТРИК';

  @override
  String get habitCreateStep4PreviewToday => 'СЕГОДНЯ';

  @override
  String get habitCreateStep4ActionBinary => 'Отметить как выполнено';

  @override
  String get habitCreateStep4ActionAnti => 'Держаться';

  @override
  String get habitCreateStep4ActionOther => 'Зафиксировать прогресс';

  @override
  String get habitCreateStep4Reset => 'Сбросить и заполнить заново';

  @override
  String get habitDetailStatistics => 'Статистика';

  @override
  String get habitDetailCurrentStreak => 'Текущий\nstreak';

  @override
  String get habitDetailBestStreak => 'Лучший\nstreak';

  @override
  String get habitDetailLast30Days => 'За 30\nдней';

  @override
  String get habitDetailLast90Days => 'Последние 90 дней';

  @override
  String get habitDetailHeatmapDone => 'Выполнено';

  @override
  String get habitDetailHeatmapPartial => 'Частично';

  @override
  String get habitDetailHeatmapMissed => 'Пропущено';

  @override
  String get habitDetailHeatmapSkip => 'Skip';

  @override
  String get habitDetailDynamics => 'Динамика выполнения';

  @override
  String habitDetailChartWeeks(int count) {
    return '$count недель';
  }

  @override
  String habitDetailChartAverage(int percent) {
    return 'Средний: $percent%';
  }

  @override
  String habitDetailChartWeekShort(int n) {
    return 'Н$n';
  }

  @override
  String get habitDetailBehavior => 'Поведенческие настройки';

  @override
  String get habitDetailBehaviorAfter => 'После';

  @override
  String get habitDetailBehaviorWhere => 'Где';

  @override
  String get habitDetailBehaviorIdentity => 'Я';

  @override
  String get habitDetailBehaviorMin => 'Минимум';

  @override
  String get habitDetailBehaviorReward => 'Награда';

  @override
  String get habitMoreSheetTitle => 'Подробнее';

  @override
  String get habitMoreSheetIdentity => 'Идентичность';

  @override
  String get habitMoreSheetReward => 'Награда';

  @override
  String get habitMoreSheetIntention => 'Намерение';

  @override
  String get habitDetailHistory => 'Последние отметки';

  @override
  String get habitDetailArchive => 'Архивировать';

  @override
  String get habitDetailAiChat => 'Открыть в чате с ИИ';

  @override
  String get habitDetailHistoryEdit => 'Дополнить →';

  @override
  String habitCardStackAfter(String emoji, String name) {
    return 'После: $emoji $name';
  }

  @override
  String get habitCardLogSheetTitle => 'Отметить выполнение';

  @override
  String get habitCardLogSheetFull => 'Полностью';

  @override
  String get habitCardLogSheetFullSub => 'Сделал как задумывал';

  @override
  String get habitCardLogSheetMin => 'Минимальный вариант';

  @override
  String habitCardLogSheetMinSub(String version) {
    return '$version';
  }

  @override
  String get habitDetailArchivedToast => 'Привычка архивирована';

  @override
  String get habitDetailDeletedToast => 'Привычка удалена';

  @override
  String get habitDetailDeleteConfirmTitle => 'Удалить привычку?';

  @override
  String get habitDetailDeleteConfirmBody =>
      'Все отметки и история будут удалены навсегда. Восстановление невозможно.';

  @override
  String get habitHistoryStatusDone => 'Сделано';

  @override
  String get habitHistoryStatusMissed => 'Пропущено';

  @override
  String get habitTimerStart => '▶ Старт';

  @override
  String get habitTimerPause => '⏸ Пауза';

  @override
  String get habitAntiDays => 'ДНЕЙ';

  @override
  String get habitAntiMarkedToday => '✓ Отмечено сегодня';

  @override
  String get habitAntiHeld => 'Удержался';

  @override
  String get journalCardTitle => 'Запиши день';

  @override
  String get journalCardSubtitle => '4 коротких вопроса или свободный текст';

  @override
  String get journalCardEditLink => 'Дополнить →';

  @override
  String get journalListTitle => 'Дневник';

  @override
  String get journalListFilterAll => 'Все';

  @override
  String get journalListFilterMonth => 'Этот месяц';

  @override
  String get journalListFilterLowMood => 'С низким настроением';

  @override
  String get journalListFilterHighMood => 'С высоким настроением';

  @override
  String get journalListEntriesLabel => 'записей';

  @override
  String journalListStreak(int days) {
    return 'Ведёшь дневник $days дней подряд 🔥';
  }

  @override
  String get journalFabLabel => 'Сегодня';

  @override
  String get journalEditHeaderToday => 'Сегодня';

  @override
  String journalEditHeaderDate(String date) {
    return '$date';
  }

  @override
  String get journalEditSave => 'Сохранить';

  @override
  String get journalEditSaving => 'Сохранение…';

  @override
  String get journalEditLoadError => 'Не удалось загрузить запись';

  @override
  String get journalEditHabitsTitle => 'ПРИВЫЧКИ СЕГОДНЯ';

  @override
  String get journalEditMoodLabel => 'Настроение';

  @override
  String get journalEditEnergyLabel => 'Энергия';

  @override
  String get journalEditEntryLabel => 'Запись';

  @override
  String get journalEditPlaceholder => 'Что важно записать о сегодняшнем дне?';

  @override
  String journalEditCharCount(int count) {
    return '$count символов';
  }

  @override
  String get journalEditQuestionsShow => 'Показать вопросы';

  @override
  String get journalEditQuestionsHide => 'Скрыть';

  @override
  String get journalEditQuestionPlaceholder => 'Напишите здесь...';

  @override
  String get journalEditChangeTemplate => 'Изменить шаблон вопросов';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsWeekTab => 'Неделя';

  @override
  String get analyticsMonthTab => 'Месяц';

  @override
  String get analyticsSummaryLabel => 'ВЫПОЛНЕНИЕ';

  @override
  String analyticsTrend(int percent, String period) {
    return '↑ +$percent% к прошлой $period';
  }

  @override
  String analyticsSubtextPeriod(String label) {
    return 'За период: $label';
  }

  @override
  String get analyticsMetricCompleted => 'Выполнено';

  @override
  String get analyticsMetricSkipped => 'Пропущено';

  @override
  String get analyticsMetricBestDay => 'Лучший день';

  @override
  String get analyticsMetricStreaks => 'Стрики ↑';

  @override
  String get analyticsMetricStreaksSubtext => 'привычки растут';

  @override
  String get analyticsBarChartTitle => 'Выполнение по дням';

  @override
  String get analyticsLegendLow => '< 40%';

  @override
  String get analyticsLegendMedium => '40–70%';

  @override
  String get analyticsLegendHigh => '> 70%';

  @override
  String get analyticsHeatmapTitle => 'Тепловая карта';

  @override
  String get analyticsHeatmapLess => 'Меньше';

  @override
  String get analyticsHeatmapMore => 'Больше';

  @override
  String get analyticsPieTitle => 'По категориям';

  @override
  String get analyticsMoodLineTitle => 'Настроение и энергия';

  @override
  String get analyticsMoodLine => 'Настроение';

  @override
  String get analyticsEnergyLine => 'Энергия';

  @override
  String get analyticsTopHabitsTitle => 'Топ-3 привычки';

  @override
  String get analyticsTopHabitsSubtitle => 'ПО ВЫПОЛНЕНИЮ';

  @override
  String get analyticsAiCorrelationsTitle => 'ИИ-корреляции';

  @override
  String get analyticsAiCorrelationsMessage =>
      'Введи ключ OpenRouter, чтобы видеть персональные корреляции и инсайты по твоим привычкам.';

  @override
  String get analyticsSettings => 'Настройки';

  @override
  String get weeklyReviewTitle => 'Обзор недели';

  @override
  String get weeklyReviewSubtitle =>
      'Короткий воскресный чеклист, чтобы закрыть неделю.';

  @override
  String get weeklyReviewItemStreak => 'Посмотрел стрики';

  @override
  String get weeklyReviewItemCorrelations => 'Посмотрел корреляции';

  @override
  String get weeklyReviewItemGoals => 'Обновил цели';

  @override
  String get aiScreenTitle => 'ИИ';

  @override
  String get aiChatTab => 'Чат';

  @override
  String get aiChatTitle => 'ИИ';

  @override
  String get aiChatSuggestion1 => 'Проанализируй мою неделю';

  @override
  String get aiChatSuggestion2 => 'Где у меня самые слабые места?';

  @override
  String get aiChatSuggestion3 => 'Предложи новую привычку';

  @override
  String get aiChatSuggestion4 => 'Почему я срываюсь?';

  @override
  String get aiChatSuggestion5 => 'Как улучшить утренний ритуал?';

  @override
  String get aiSummariesTab => 'Сводки';

  @override
  String get aiPromptsTab => 'Промпты';

  @override
  String get aiChatHistoryTitle => 'История чатов';

  @override
  String get aiChatNew => 'Новый чат';

  @override
  String get aiChatDisclaimerTitle => 'Твой ключ, твои данные';

  @override
  String get aiChatDisclaimerText =>
      'Каждое сообщение — это вызов API на твой счёт OpenRouter. Бесплатная модель имеет лимит 200 запросов в день. Содержимое уходит в OpenRouter и провайдера модели. Не пиши то, что не готов поделиться.';

  @override
  String get aiChatDisclaimerOk => 'Понял';

  @override
  String get aiChatInputPlaceholder => 'Спроси что-нибудь...';

  @override
  String aiChatTokenCounter(String model, int used, int limit) {
    return '$model · $used/$limit';
  }

  @override
  String get aiChatRename => 'Переименовать';

  @override
  String get aiChatDelete => 'Удалить';

  @override
  String get aiChatRenameTitle => 'Новое название';

  @override
  String get aiChatRenameHint => 'Название чата';

  @override
  String get aiChatDeleteConfirmTitle => 'Удалить чат?';

  @override
  String get aiChatDeleteConfirmText =>
      'Все сообщения будут удалены. Это нельзя отменить.';

  @override
  String get aiChatRateLimitedTitle => 'Лимит на сегодня исчерпан';

  @override
  String get aiChatRateLimitedText =>
      'Сработал дневной лимит OpenRouter (200 запросов на бесплатной модели). Попробуй завтра или выбери платную модель в настройках ИИ.';

  @override
  String get aiChatNoKeyTitle => 'Добавь ключ OpenRouter';

  @override
  String get aiChatNoKeyText =>
      'Открой настройки ИИ и вставь ключ — без него чат не сможет отправить сообщение.';

  @override
  String get aiChatErrorGeneric =>
      'Что-то пошло не так. Проверь соединение и попробуй ещё раз.';

  @override
  String get aiStyleCoachName => 'Коуч';

  @override
  String get aiStyleCoachDesc =>
      'Профессиональный, без сюсюканья. По умолчанию.';

  @override
  String get aiStyleCoachPreview =>
      'Три пропуска подряд — это уже паттерн. Что именно мешает: время, мотивация или обстоятельства? Давай разберём и скорректируем план.';

  @override
  String get aiStyleSergeantName => 'Сержант';

  @override
  String get aiStyleSergeantDesc =>
      'Прямой, без оправданий. Жёсткий, но честный.';

  @override
  String get aiStyleSergeantPreview =>
      'Три раза. Без исключений. Это не обстоятельства — это выбор. Либо ты делаешь это сегодня, либо признаёшь, что это не приоритет.';

  @override
  String get aiStyleBuddyName => 'Друг';

  @override
  String get aiStyleBuddyDesc =>
      'Тёплый, неформальный, с юмором. Поддерживает.';

  @override
  String get aiStyleBuddyPreview =>
      'Эй, всё норм! Жизнь случается 😅 Три пропуска — не катастрофа. Ты уже здесь и думаешь об этом, а это уже победа. Завтра?';

  @override
  String get aiStyleSageName => 'Мудрец';

  @override
  String get aiStyleSageDesc => 'Стоическая мудрость, цитаты, метафоры.';

  @override
  String get aiStyleSagePreview =>
      '«Не падение определяет нас, а то, как мы встаём». Три пропуска — лишь рябь на воде. Привычка — это не серия, а намерение. Что говорит тебе это молчание?';

  @override
  String get aiStylePoetName => 'Поэт';

  @override
  String get aiStylePoetDesc => 'Метафоры и образы. Только для поддержавших.';

  @override
  String get aiStylePoetPreview =>
      'Три пустых вечера, как незаполненные строфы. Тело помнит ритм, даже когда разум забыл. Что остановило движение?';

  @override
  String aiSummariesInfoBanner(int interval, int count, int remaining) {
    return 'Сводка генерируется автоматически каждые $interval дневника. У тебя сейчас $count — следующая через $remaining.';
  }

  @override
  String get aiSummariesBadgeNew => 'Новая';

  @override
  String aiSummaryTitle(int from, int to) {
    return 'Сводка $from–$to';
  }

  @override
  String get aiSummaryAsk => 'Спросить про сводку';

  @override
  String get aiSummaryRegenerate => 'Перегенерировать';

  @override
  String get aiSummaryChatPrompt => 'Разбери эту сводку подробнее';

  @override
  String get aiSummaryRegenerateConfirmTitle => 'Пересобрать сводку?';

  @override
  String get aiSummaryRegenerateConfirmText =>
      'Текущая сводка будет заменена новой.';

  @override
  String get aiPromptDeleteConfirmTitle => 'Удалить промпт?';

  @override
  String get aiPromptDeleteConfirmText =>
      'Этот пользовательский промпт будет удален навсегда. Это действие нельзя отменить.';

  @override
  String get aiPromptCreateTitle => 'Новый промпт';

  @override
  String get aiPromptCreateEmoji => 'Эмодзи';

  @override
  String get aiPromptCreateTitleLabel => 'Название';

  @override
  String get aiPromptCreateDescLabel => 'Описание / Вопрос';

  @override
  String get aiPromptCreateCategoryLabel => 'Категория';

  @override
  String get aiPromptSystem1Title => 'Анализ паттернов';

  @override
  String get aiPromptSystem1Desc =>
      'Проанализируй мои привычки и записи в дневнике за последнее время. Найди скрытые закономерности: в какие дни или периоды я наиболее продуктивен, а когда продуктивность падает, и как это связано с моим настроением.';

  @override
  String get aiPromptSystem2Title => 'Слепые пятна';

  @override
  String get aiPromptSystem2Desc =>
      'Найди в моих данных то, что я сам не замечаю. Какие привычки я незаметно саботирую? Какие эмоции чаще всего предшествуют пропускам? Покажи неочевидные взаимосвязи.';

  @override
  String get aiPromptSystem3Title => 'Прогноз срыва';

  @override
  String get aiPromptSystem3Desc =>
      'Оценить стабильность выполнения моих привычек за последнюю неделю. Выдели те из них, которые находятся под наибольшей угрозой срыва, объясни почему и предложи простую стратегию их спасения.';

  @override
  String get aiPromptSystem4Title => 'Новые привычки';

  @override
  String get aiPromptSystem4Desc =>
      'Изучи мой текущий образ жизни по записям и привычкам. Какую одну новую микро-привычку мне стоит внедрить следующей, чтобы она органично вписалась в мой график и усилила текущие результаты?';

  @override
  String get aiPromptSystem5Title => 'Эмоциональная карта';

  @override
  String get aiPromptSystem5Desc =>
      'Проведи контент-анализ моих дневниковых записей за неделю. Какое преобладающее эмоциональное состояние у меня было? Какие триггеры вызывали радость, а какие — тревогу или спад энергии?';

  @override
  String get aiPromptSystem6Title => 'Анализ корреляций';

  @override
  String get aiPromptSystem6Desc =>
      'Сопоставь выполнение моих ключевых привычек с моим настроением и уровнем энергии из дневника. Как физические привычки (сон, спорт, питание) напрямую влияют на мой эмоциональный фон?';

  @override
  String get aiPromptSystem7Title => 'Динамика роста';

  @override
  String get aiPromptSystem7Desc =>
      'Сравни мои текущие показатели и рефлексию с прошлыми периодами. В чём мой главный прогресс? Как изменилось моё отношение к трудностям и какие полезные ментальные сдвиги произошли?';

  @override
  String get aiPromptSystem8Title => 'Оптимизация фокуса';

  @override
  String get aiPromptSystem8Desc =>
      'Проанализируй привычки, которые я выполняю хуже всего или постоянно откладываю. Стоит ли мне их упростить, временно убрать или заменить на что-то более актуальное прямо сейчас?';

  @override
  String get aiPromptSystem9Title => 'Тайм-дизайн дня';

  @override
  String get aiPromptSystem9Desc =>
      'Посмотри на мои привычки и хронометраж в дневнике. Как мне лучше сгруппировать дела и привычки по времени суток (утро/день/вечер) с учётом моих пиков энергии, чтобы тратить меньше силы воли?';

  @override
  String get aiPromptSystem10Title => 'Проверка ценностей';

  @override
  String get aiPromptSystem10Desc =>
      'Прочитай мои цели и рефлексию. Совпадают ли мои ежедневные действия с тем, кем я хочу быть? Где кроется самый большой разрыв между моими идеалами и реальными делами, и как его сократить?';

  @override
  String get aiPromptSystem11Title => 'Анализ серий';

  @override
  String get aiPromptSystem11Desc =>
      'Посмотри на серии выполненных привычек (стрики). Помогают ли они мне расти или превратились в рутину «ради галочки»? Как мне перестроить систему мотивации, чтобы фокус был на качестве, а не на цифрах?';

  @override
  String get aiPromptSystem12Title => 'Карта триггеров';

  @override
  String get aiPromptSystem12Desc =>
      'Проанализируй все дни, когда я срывался или пропускал привычки. Какие внешние события, люди или внутренние состояния (усталость, стресс) послужили триггерами? Создай план защиты от этих триггеров.';

  @override
  String get aiPromptSystem13Title => 'Проектирование ритуалов';

  @override
  String get aiPromptSystem13Desc =>
      'Выдели 2-3 привычки, которые я делаю стабильнее всего. Как я могу использовать их в качестве «якорей», чтобы прикрепить к ним новые, более сложные привычки и создать устойчивый утренний или вечерний ритуал?';

  @override
  String get aiPromptSystem14Title => 'Письмо поддержки';

  @override
  String get aiPromptSystem14Desc =>
      'На основе моей рефлексии за неделю напиши мне тёплое, поддерживающее письмо от лица заботливого и мудрого друга. Отметь мои старания, мягко подсвети успехи и помоги справиться с самокритикой.';

  @override
  String get aiPromptsFilterAll => 'Все';

  @override
  String get aiPromptsFilterAnalysis => 'Анализ';

  @override
  String get aiPromptsFilterEmotions => 'Эмоции';

  @override
  String get aiPromptsFilterGrowth => 'Рост';

  @override
  String get aiPromptsFilterRelapse => 'Срывы';

  @override
  String get aiPromptsIntro =>
      'Готовые вопросы для ИИ. Тапни — откроется чат с этим вопросом.';

  @override
  String aiPromptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count промптов',
      few: '$count промпта',
      one: '$count промпт',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionBasic => 'Основное';

  @override
  String get profileMenuJournal => 'Дневник';

  @override
  String get profileMenuAccount => 'Аккаунт и язык';

  @override
  String get profileSectionSettings => 'Настройки';

  @override
  String get profileMenuAiSettings => 'ИИ и модель';

  @override
  String get profileMenuNotifications => 'Уведомления';

  @override
  String get profileMenuAppearance => 'Внешний вид';

  @override
  String get profileMenuReflectionTemplate => 'Шаблон рефлексии';

  @override
  String get profileSectionSupport => 'Поддержка';

  @override
  String get profileMenuDonate => 'Поддержать проект';

  @override
  String get profileMenuAbout => 'О приложении';

  @override
  String get profileMenuPrivacy => 'Политика приватности';

  @override
  String get profileMenuContact => 'Связаться с автором';

  @override
  String get profileSectionDanger => 'ОПАСНАЯ ЗОНА';

  @override
  String get profileMenuDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteAccountMessage =>
      'Все привычки, дневник и история ИИ будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get profileBadgeSupporter => '💎 Поддержал проект';

  @override
  String get profileStatsDaysWithApp => 'дней с\nприложением';

  @override
  String get profileStatsActiveHabits => 'активных\nпривычек';

  @override
  String get profileStatsStreak => 'дней\nподряд';

  @override
  String get donateTitle => 'Поддержать';

  @override
  String get donateHeroTitle => 'Спасибо, что есть';

  @override
  String get donateHeroMessage =>
      'HabitFlow всегда будет бесплатным. Если приложение тебе помогает — поддержи проект через Telegram Stars. Это даёт мне время и силы делать его лучше.';

  @override
  String get donatePresetsLabel => 'Выбери сумму';

  @override
  String get donateCustomInputLabel => 'Введи кол-во ⭐';

  @override
  String get donateCustomButton => 'Своя ⭐';

  @override
  String get donateBenefitsTitle => 'Бонусы поддержавшим';

  @override
  String get donateBenefitBadge => 'Бейдж «Поддержал проект» в профиле';

  @override
  String get donateBenefitStyle => 'Дополнительный стиль ИИ — Поэт';

  @override
  String get donateBenefitColor => 'Кастомный акцентный цвет интерфейса';

  @override
  String get donateBenefitThanks => 'Спасибо в About-экране (опционально)';

  @override
  String get donatePopularBadge => 'Популярное';

  @override
  String donateCta(int stars) {
    return 'Поддержать на $stars ⭐';
  }

  @override
  String get donateMobileNote =>
      'Через Telegram Desktop ~30% выгоднее, чем через мобильный (Apple/Google комиссия)';

  @override
  String get donateHistoryLink => 'История донатов';

  @override
  String get donateThanksTitle => 'Спасибо!';

  @override
  String get donateThanksMessage => 'Ты поддержал проект. Это очень важно!';

  @override
  String get donateErrorTitle => 'Ошибка';

  @override
  String get donateErrorMessage =>
      'Не удалось создать инвойс. Попробуй ещё раз.';

  @override
  String get donateNotAvailableTitle =>
      'Оплата недоступна в мобильном приложении';

  @override
  String get donateNotAvailableMessage =>
      'Пожалуйста, откройте Habit Flow непосредственно в Telegram (как Mini App), чтобы поддержать проект.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsTelegramBanner => 'Уведомления через Telegram';

  @override
  String get notificationsTelegramDesc =>
      'Уведомления приходят от @habitflow_bot. Это обычные сообщения с кнопками — никаких системных push.';

  @override
  String get notificationsReflectionSection => 'Вечерняя рефлексия';

  @override
  String get notificationsReflectionToggle => 'Напоминать вести дневник';

  @override
  String get notificationsReflectionHint =>
      'Бот спросит, что было важно за день';

  @override
  String get notificationsQuietHoursSection => 'Тихие часы';

  @override
  String get notificationsQuietToggle => 'Не беспокоить';

  @override
  String get notificationsQuietFrom => 'С';

  @override
  String get notificationsQuietTo => 'До';

  @override
  String get notificationsQuietHint =>
      'В это время уведомления не приходят. Привычки, попадающие в окно, переносятся.';

  @override
  String get notificationsSoundSection => 'Звук';

  @override
  String get notificationsSoundOn => 'Со звуком';

  @override
  String get notificationsSoundOnSubtitle => 'по умолчанию';

  @override
  String get notificationsSoundOff => 'Без звука';

  @override
  String get notificationsSoundOffSubtitle => 'через disable_notification';

  @override
  String get notificationsPreviewSection => 'Превью уведомления';

  @override
  String get notificationsPreviewHint =>
      'Так выглядит обычное напоминание о привычке';

  @override
  String get notificationsPreviewBubble =>
      '🌅 Утренняя медитация — твоё время. Минимум — 1 минута.\nStreak: 14 дней 🔥';

  @override
  String get notificationsPreviewDone => '✅ Сделано';

  @override
  String get notificationsPreviewSkip => '⏭ Пропустил';

  @override
  String get notificationsPreviewMore => '💬 Подробнее';

  @override
  String get notificationsRareSection => 'Редкие уведомления';

  @override
  String get notificationsWeeklyTitle => 'Воскресный обзор недели';

  @override
  String get notificationsWeeklySubtitle => 'Каждое воскресенье вечером';

  @override
  String get notificationsAiSummaryTitle => 'Готова ИИ-сводка';

  @override
  String get notificationsAiSummarySubtitle => 'После каждых 30 записей';

  @override
  String get notificationsRecoveryTitle => 'Recovery-сообщения';

  @override
  String get notificationsRecoverySubtitle => 'Если пропустил вчера';

  @override
  String get aiSettingsTitle => 'ИИ и модель';

  @override
  String get aiSettingsApiKeySection => 'Ключ OpenRouter';

  @override
  String get aiSettingsApiKeyLabel => 'API ключ';

  @override
  String get aiSettingsApiKeyLink => 'Где взять ключ';

  @override
  String get aiSettingsHowItWorks => 'Как это работает';

  @override
  String get aiSettingsStatusUnchecked => 'Не проверен';

  @override
  String get aiSettingsStatusChecking => 'Проверяем...';

  @override
  String get aiSettingsStatusOk => 'Ключ работает';

  @override
  String get aiSettingsStatusError => 'Ошибка авторизации';

  @override
  String get aiSettingsTestButton => 'Тестовый запрос';

  @override
  String get aiSettingsModelSection => 'Модель';

  @override
  String get aiSettingsAllModelsLink => 'Все модели OpenRouter';

  @override
  String get aiSettingsStyleSection => 'Стиль ИИ';

  @override
  String get aiSettingsStyleSubtitle => 'Тон собеседника';

  @override
  String get aiBadgeFree => 'БЕСПЛАТНО';

  @override
  String get aiSettingsStyleExampleHeader =>
      'ПРИМЕР ОТВЕТА · «Я ПРОПУСТИЛ СПОРТ УЖЕ ТРИ РАЗА»';

  @override
  String get aiSettingsUsageSection => 'Использование';

  @override
  String get aiSettingsUsageToday => 'Сегодня';

  @override
  String get aiSettingsUsageMonth => 'За месяц';

  @override
  String get aiSettingsUsageSpent => 'Потрачено';

  @override
  String get aiSettingsUsageNote =>
      'Платные модели — на твоём счёте OpenRouter.';

  @override
  String get aiSettingsHowItem1Title => 'Твой ключ — твои данные';

  @override
  String get aiSettingsHowItem1Text =>
      'Ключ API хранится только на твоём устройстве и отправляется напрямую в OpenRouter. HabitFlow не видит ни ключ, ни переписку.';

  @override
  String get aiSettingsHowItem2Title => 'OpenRouter — маршрутизатор моделей';

  @override
  String get aiSettingsHowItem2Text =>
      'Это прокси, который даёт доступ к десяткам AI-моделей через единый API. Бесплатные модели не требуют пополнения счёта.';

  @override
  String get aiSettingsHowItem3Title => 'Оплата только за то, что используешь';

  @override
  String get aiSettingsHowItem3Text =>
      'Платные модели списываются с баланса OpenRouter. Бесплатные — с лимитами 20 RPM и 200 RPD — доступны сразу.';

  @override
  String get appearanceTitle => 'Внешний вид';

  @override
  String get appearanceThemeSection => 'Тема';

  @override
  String get appearanceThemeLight => '☀️ Светлая';

  @override
  String get appearanceThemeDark => '🌙 Тёмная';

  @override
  String get appearanceThemeAuto => '⚙️ Авто';

  @override
  String get appearanceAccentSection => 'Акцент';

  @override
  String get accentBlue => 'Синий';

  @override
  String get accentGreen => 'Зелёный';

  @override
  String get accentAmber => 'Амбер';

  @override
  String get accentRed => 'Красный';

  @override
  String get accentViolet => 'Фиолет.';

  @override
  String get accentPink => 'Розовый';

  @override
  String get accentTeal => 'Бирюза';

  @override
  String get accentGray => 'Серый';

  @override
  String get accountTitle => 'Аккаунт и язык';

  @override
  String get accountTelegramSection => 'Telegram';

  @override
  String get accountLanguageSection => 'Язык интерфейса';

  @override
  String get accountFirstDaySection => 'Первый день недели';

  @override
  String get accountFirstDayMonday => 'Понедельник';

  @override
  String get accountFirstDaySunday => 'Воскресенье';

  @override
  String get reflectionTemplateTitle => 'Шаблон рефлексии';

  @override
  String get reflectionTemplateDesc =>
      'Эти вопросы появятся в дневнике, когда ты включишь раздел «Показать вопросы». Можешь править, добавлять и удалять.';

  @override
  String get reflectionTemplateQ1 => 'Что было главным сегодня?';

  @override
  String get reflectionTemplateQ2 => 'За что ты благодарен?';

  @override
  String get reflectionTemplateQ3 => 'Что бы сделал по-другому?';

  @override
  String get reflectionTemplateQ4 => 'Что зарядило / опустошило?';

  @override
  String get reflectionTemplateInputHint => 'Вопрос…';

  @override
  String get reflectionTemplateAddButton => 'Добавить вопрос';

  @override
  String get reflectionTemplateResetButton => 'Сбросить к шаблону';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutWhatLabel => 'Что это';

  @override
  String get aboutWhatText =>
      'HabitFlow — Telegram Mini App: трекер привычек, дневник рефлексии и ИИ-аналитик личных данных.';

  @override
  String get aboutPrinciplesLabel => 'Принципы';

  @override
  String get aboutPrinciplesText =>
      'Telegram-нативность · BYO-ключ OpenRouter · полная бесплатность с донатами через Stars · поведенческая наука в UX · RU + EN с первого дня.';

  @override
  String get aboutSpecLink => 'Спецификация';

  @override
  String get aboutSpecHint => 'SPEC.md в репозитории';

  @override
  String get aboutChannelLink => 'Telegram-канал';

  @override
  String get aboutSourceLink => 'Исходники';

  @override
  String get privacyTitle => 'Политика приватности';

  @override
  String get privacyAuthLabel => 'Авторизация';

  @override
  String get privacyAuthText =>
      'HabitFlow использует Telegram initData для входа — мы не запрашиваем email или пароль. На сервер уходит подписанная Telegram строка, мы её проверяем и выпускаем JWT. Никаких сторонних провайдеров.';

  @override
  String get privacyStorageLabel => 'Что хранится';

  @override
  String get privacyStorageText =>
      'Привычки, отметки выполнения, записи дневника, история ИИ-чата — у нас в Supabase Postgres. Данные привязаны к твоему telegram_user_id и доступны только тебе через Row Level Security.';

  @override
  String get privacyKeyLabel => 'OpenRouter ключ';

  @override
  String get privacyKeyText =>
      'API-ключ OpenRouter — твой собственный (BYO key). Он хранится локально на твоём устройстве и отправляется напрямую в OpenRouter. HabitFlow не видит ни ключ, ни переписку с ИИ.';

  @override
  String get privacyNotCollectLabel => 'Что мы НЕ собираем';

  @override
  String get privacyNotCollectText =>
      'Не логируем initData, не передаём данные третьим лицам, не показываем рекламу, не используем аналитику пользовательских действий внутри приложения.';

  @override
  String get privacyDeletionLabel => 'Удаление данных';

  @override
  String get privacyDeletionText =>
      'В разделе «Опасная зона» можно удалить аккаунт. Все привычки, дневник и история ИИ удаляются каскадно из БД. Восстановление невозможно.';

  @override
  String get privacyContactLabel => 'Контакт';

  @override
  String get privacyContactText =>
      'Вопросы по приватности — пиши автору через раздел «Связаться с автором» в профиле.';

  @override
  String get contactTitle => 'Связаться с автором';

  @override
  String get contactDesc =>
      'Напиши, если нашёл баг, есть идея фичи или просто хочется поделиться. Отвечаю обычно в течение пары дней.';

  @override
  String get contactChannelTelegram => 'Telegram';

  @override
  String get contactChannelEmail => 'Email';

  @override
  String get contactChannelGithub => 'GitHub Issues';

  @override
  String contactCopiedToast(String value) {
    return 'Скопировано: $value';
  }

  @override
  String get splashOutsideTelegramTitle => 'Открой в Telegram';

  @override
  String get splashOutsideTelegramDesc =>
      'HabitFlow — это Telegram Mini App. Открой его через бота или ссылку t.me внутри Telegram.';

  @override
  String get splashAuthErrorTitle => 'Ошибка входа';

  @override
  String get splashAuthErrorDesc =>
      'Не удалось подключиться к серверу. Проверь соединение и попробуй снова.';

  @override
  String get errorNetworkTitle => 'Нет интернета';

  @override
  String get errorNetworkDesc => 'Проверь соединение и попробуй снова.';

  @override
  String get errorUnauthorizedTitle => 'Нужно войти заново';

  @override
  String get errorUnauthorizedDesc =>
      'Сессия устарела. Открой приложение заново.';

  @override
  String get errorAiLimitTitle => 'Лимит исчерпан';

  @override
  String get errorAiLimitDesc =>
      'Все запросы использованы. Подожди или поменяй модель.';

  @override
  String get errorServerTitle => 'Сервер недоступен';

  @override
  String get errorServerDesc =>
      'Что-то пошло не так на стороне сервера. Попробуй ещё раз.';

  @override
  String get errorValidationTitle => 'Проверь поля';

  @override
  String get errorValidationDesc => 'Некоторые поля заполнены неверно.';

  @override
  String get errorGenericTitle => 'Что-то пошло не так';

  @override
  String get errorGenericDesc =>
      'Произошла непредвиденная ошибка. Попробуй ещё раз.';

  @override
  String get errorRetry => 'Повторить';

  @override
  String get errorRelogin => 'Перезайти';

  @override
  String get errorWait => 'Подождать';

  @override
  String get errorChangeModel => 'Поменять модель';

  @override
  String get deviceLinkTitle => 'Привязка устройства';

  @override
  String get deviceLinkBtn => 'Войти через Telegram';

  @override
  String get deviceLinkInstructions =>
      '1. Нажмите кнопку ниже, чтобы открыть нашего Telegram-бота.\n2. Нажмите кнопку \'Запустить\' (Start) для подтверждения привязки.\n3. Не закрывайте этот экран, привязка произойдет автоматически.';

  @override
  String get deviceLinkOpenBotBtn => 'Открыть Telegram-бота';

  @override
  String get deviceLinkWaiting => 'Ожидание подтверждения...';

  @override
  String get deviceLinkSuccess =>
      'Устройство успешно привязано! Перенаправление...';

  @override
  String deviceLinkFailed(String reason) {
    return 'Не удалось привязать устройство: $reason';
  }

  @override
  String get deviceLinkReasonExpired =>
      'Срок действия ссылки истек. Пожалуйста, попробуйте снова.';

  @override
  String get deviceLinkReasonConsumed =>
      'Эта ссылка уже была использована. Пожалуйста, попробуйте снова.';

  @override
  String get deviceLinkReasonNetwork =>
      'Ошибка сети. Проверьте подключение к интернету.';

  @override
  String get deviceLinkReasonUnknown =>
      'Произошла неизвестная ошибка. Пожалуйста, попробуйте снова.';

  @override
  String get habitCatHealth => 'Здоровье';

  @override
  String get habitCatSport => 'Спорт';

  @override
  String get habitCatStudy => 'Учёба';

  @override
  String get habitCatWork => 'Работа';

  @override
  String get habitCatRelationships => 'Отношения';

  @override
  String get habitCatFinance => 'Финансы';

  @override
  String get habitCatHobby => 'Хобби';

  @override
  String get habitCatMental => 'Ментальное';

  @override
  String get habitCatNew => '+ Новая';

  @override
  String get habitRepeatDaily => 'Каждый день';

  @override
  String get habitRepeatWeekdays => 'По дням недели';

  @override
  String get habitRepeatNPerWeek => 'X раз в неделю';

  @override
  String get habitRepeatEveryN => 'Каждые N дней';

  @override
  String get habitRepeatMonthly => 'По датам месяца';

  @override
  String get habitWeekMon => 'Пн';

  @override
  String get habitWeekTue => 'Вт';

  @override
  String get habitWeekWed => 'Ср';

  @override
  String get habitWeekThu => 'Чт';

  @override
  String get habitWeekFri => 'Пт';

  @override
  String get habitWeekSat => 'Сб';

  @override
  String get habitWeekSun => 'Вс';

  @override
  String get habitGoalUnitTimes => 'раз';

  @override
  String get habitStackingNoHabits => '— Сначала создай другую привычку —';
}
