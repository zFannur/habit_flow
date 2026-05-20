import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get navToday;

  /// No description provided for @navHabits.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get navHabits;

  /// No description provided for @navAnalytics.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get navAnalytics;

  /// No description provided for @navAi.
  ///
  /// In ru, this message translates to:
  /// **'ИИ'**
  String get navAi;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get commonReplace;

  /// No description provided for @commonUnderstand.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get commonUnderstand;

  /// No description provided for @commonSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем запрос…'**
  String get commonSending;

  /// No description provided for @commonEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get commonEdit;

  /// No description provided for @commonOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get commonOpen;

  /// No description provided for @commonClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get commonSearch;

  /// No description provided for @aiSettingsModelSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск модели…'**
  String get aiSettingsModelSearchHint;

  /// No description provided for @aiSettingsModelsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get aiSettingsModelsEmpty;

  /// No description provided for @correlationsRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Получить корреляции'**
  String get correlationsRefresh;

  /// No description provided for @correlationsRefreshAgain.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get correlationsRefreshAgain;

  /// No description provided for @correlationsLoading.
  ///
  /// In ru, this message translates to:
  /// **'ИИ анализирует данные…'**
  String get correlationsLoading;

  /// No description provided for @correlationsNoKey.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы получить инсайты, добавь ключ OpenRouter в настройках ИИ.'**
  String get correlationsNoKey;

  /// No description provided for @correlationsNotEnoughData.
  ///
  /// In ru, this message translates to:
  /// **'Нужно минимум 7 отметок за последние 30 дней. Сейчас: {count}.'**
  String correlationsNotEnoughData(int count);

  /// No description provided for @correlationsRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Лимит OpenRouter исчерпан. Попробуй завтра.'**
  String get correlationsRateLimited;

  /// No description provided for @correlationsGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить корреляции. Попробуй ещё раз.'**
  String get correlationsGeneric;

  /// No description provided for @correlationsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сильных корреляций пока не нашлось — продолжай отмечать привычки.'**
  String get correlationsEmpty;

  /// No description provided for @correlationsDirectionUp.
  ///
  /// In ru, this message translates to:
  /// **'↑ положительная связь'**
  String get correlationsDirectionUp;

  /// No description provided for @correlationsDirectionDown.
  ///
  /// In ru, this message translates to:
  /// **'↓ обратная связь'**
  String get correlationsDirectionDown;

  /// No description provided for @correlationsDirectionMixed.
  ///
  /// In ru, this message translates to:
  /// **'↔ неоднозначно'**
  String get correlationsDirectionMixed;

  /// No description provided for @commonNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get commonNext;

  /// No description provided for @commonRetry.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get commonRetry;

  /// No description provided for @commonOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get commonOpenSettings;

  /// No description provided for @commonCreateHabit.
  ///
  /// In ru, this message translates to:
  /// **'Создать привычку'**
  String get commonCreateHabit;

  /// No description provided for @commonNewBadge.
  ///
  /// In ru, this message translates to:
  /// **'✦ Новая'**
  String get commonNewBadge;

  /// No description provided for @commonNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get commonNameLabel;

  /// No description provided for @commonCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get commonCategoryLabel;

  /// No description provided for @commonAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get commonAdd;

  /// No description provided for @langRu.
  ///
  /// In ru, this message translates to:
  /// **'🇷🇺 RU'**
  String get langRu;

  /// No description provided for @langEn.
  ///
  /// In ru, this message translates to:
  /// **'🇬🇧 EN'**
  String get langEn;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @todayAddHabit.
  ///
  /// In ru, this message translates to:
  /// **'Добавить привычку'**
  String get todayAddHabit;

  /// No description provided for @todayGreetingMorning.
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро'**
  String get todayGreetingMorning;

  /// No description provided for @todayGreetingAfternoon.
  ///
  /// In ru, this message translates to:
  /// **'Добрый день'**
  String get todayGreetingAfternoon;

  /// No description provided for @todayGreetingEvening.
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер'**
  String get todayGreetingEvening;

  /// No description provided for @todayHeaderStats.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total} привычек · Streak {streak} дней'**
  String todayHeaderStats(int done, int total, int streak);

  /// No description provided for @onboardingSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get onboardingSkip;

  /// No description provided for @onboardingBegin.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingBegin;

  /// No description provided for @onboardingFinish.
  ///
  /// In ru, this message translates to:
  /// **'Готово, поехали!'**
  String get onboardingFinish;

  /// No description provided for @onboardingS1Sub.
  ///
  /// In ru, this message translates to:
  /// **'Привычки. Дневник. ИИ, который понимает.'**
  String get onboardingS1Sub;

  /// No description provided for @onboardingS2Title.
  ///
  /// In ru, this message translates to:
  /// **'Ты — то, что повторяешь'**
  String get onboardingS2Title;

  /// No description provided for @onboardingS2P1.
  ///
  /// In ru, this message translates to:
  /// **'Каждая привычка — это голосование за тип человека, которым ты хочешь стать. Маленькие действия, повторённые снова и снова, меняют твою идентичность.'**
  String get onboardingS2P1;

  /// No description provided for @onboardingS2P2.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow строится на науке о поведении: не на силе воли, а на системе, которая работает даже когда мотивация угасает.'**
  String get onboardingS2P2;

  /// No description provided for @onboardingS2Quote.
  ///
  /// In ru, this message translates to:
  /// **'«Каждое действие — голос за того, кем ты становишься.»'**
  String get onboardingS2Quote;

  /// No description provided for @onboardingS2Author.
  ///
  /// In ru, this message translates to:
  /// **'— Джеймс Клир'**
  String get onboardingS2Author;

  /// No description provided for @onboardingS2LabelCenter.
  ///
  /// In ru, this message translates to:
  /// **'Ты'**
  String get onboardingS2LabelCenter;

  /// No description provided for @onboardingS2LabelHabits.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get onboardingS2LabelHabits;

  /// No description provided for @onboardingS2LabelActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get onboardingS2LabelActions;

  /// No description provided for @onboardingS2LabelIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Личность'**
  String get onboardingS2LabelIdentity;

  /// No description provided for @onboardingS3Title.
  ///
  /// In ru, this message translates to:
  /// **'Начнём с одной'**
  String get onboardingS3Title;

  /// No description provided for @onboardingS3Sub.
  ///
  /// In ru, this message translates to:
  /// **'Не пытайся изменить всё сразу. Выбери одну привычку на этот месяц.'**
  String get onboardingS3Sub;

  /// No description provided for @onboardingS3Templates.
  ///
  /// In ru, this message translates to:
  /// **'Из шаблонов'**
  String get onboardingS3Templates;

  /// No description provided for @onboardingS3TemplatesSub.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендовано'**
  String get onboardingS3TemplatesSub;

  /// No description provided for @onboardingS3BadgeRecommended.
  ///
  /// In ru, this message translates to:
  /// **'★ Рекомендуем'**
  String get onboardingS3BadgeRecommended;

  /// No description provided for @onboardingS3Custom.
  ///
  /// In ru, this message translates to:
  /// **'Своя привычка'**
  String get onboardingS3Custom;

  /// No description provided for @onboardingS3CustomSub.
  ///
  /// In ru, this message translates to:
  /// **'Придумай сам'**
  String get onboardingS3CustomSub;

  /// No description provided for @onboardingS4Title.
  ///
  /// In ru, this message translates to:
  /// **'С чего начать?'**
  String get onboardingS4Title;

  /// No description provided for @onboardingS4Max.
  ///
  /// In ru, this message translates to:
  /// **'Максимум 3 привычки'**
  String get onboardingS4Max;

  /// No description provided for @onboardingS4Selected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String onboardingS4Selected(int count);

  /// No description provided for @onboardingS4Btn.
  ///
  /// In ru, this message translates to:
  /// **'Создать выбранные'**
  String get onboardingS4Btn;

  /// No description provided for @onboardingS5Title.
  ///
  /// In ru, this message translates to:
  /// **'Я буду напоминать'**
  String get onboardingS5Title;

  /// No description provided for @onboardingS5Text.
  ///
  /// In ru, this message translates to:
  /// **'В назначенное время бот пришлёт сообщение в Telegram. Ты сможешь отметить выполнение прямо там — без открытия приложения.'**
  String get onboardingS5Text;

  /// No description provided for @onboardingS5BotName.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow Bot'**
  String get onboardingS5BotName;

  /// No description provided for @onboardingS5TgMsg.
  ///
  /// In ru, this message translates to:
  /// **'🌅 Утренняя медитация — время твоей привычки'**
  String get onboardingS5TgMsg;

  /// No description provided for @onboardingS5DoneBtn.
  ///
  /// In ru, this message translates to:
  /// **'✅ Сделано'**
  String get onboardingS5DoneBtn;

  /// No description provided for @onboardingS5SkipBtn.
  ///
  /// In ru, this message translates to:
  /// **'⏭ Пропустил'**
  String get onboardingS5SkipBtn;

  /// No description provided for @emptyTitleNoHabits.
  ///
  /// In ru, this message translates to:
  /// **'Здесь будут твои привычки'**
  String get emptyTitleNoHabits;

  /// No description provided for @emptyDescNoHabits.
  ///
  /// In ru, this message translates to:
  /// **'Создай первую — для начала\nдостаточно одной маленькой'**
  String get emptyDescNoHabits;

  /// No description provided for @emptyTitleNoEntries.
  ///
  /// In ru, this message translates to:
  /// **'Дневник пока пуст'**
  String get emptyTitleNoEntries;

  /// No description provided for @emptyDescNoEntries.
  ///
  /// In ru, this message translates to:
  /// **'Запиши, как прошёл день —\nэто займёт пару минут'**
  String get emptyDescNoEntries;

  /// No description provided for @emptyActionNoEntries.
  ///
  /// In ru, this message translates to:
  /// **'Записать сегодня'**
  String get emptyActionNoEntries;

  /// No description provided for @emptyTitleNoSummaries.
  ///
  /// In ru, this message translates to:
  /// **'Сводки ещё не готовы'**
  String get emptyTitleNoSummaries;

  /// No description provided for @emptyDescNoSummaries.
  ///
  /// In ru, this message translates to:
  /// **'Первая сводка появится после 30 записей в дневнике. Сейчас у тебя {count}.'**
  String emptyDescNoSummaries(int count);

  /// No description provided for @emptyActionNoSummaries.
  ///
  /// In ru, this message translates to:
  /// **'Записать рефлексию'**
  String get emptyActionNoSummaries;

  /// No description provided for @emptyTitleNoKey.
  ///
  /// In ru, this message translates to:
  /// **'Подключи OpenRouter'**
  String get emptyTitleNoKey;

  /// No description provided for @emptyDescNoKey.
  ///
  /// In ru, this message translates to:
  /// **'ИИ работает на твоём ключе. Бесплатная модель доступна без оплаты.'**
  String get emptyDescNoKey;

  /// No description provided for @emptyTitleNoInternet.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи'**
  String get emptyTitleNoInternet;

  /// No description provided for @emptyDescNoInternet.
  ///
  /// In ru, this message translates to:
  /// **'Проверь подключение\nи попробуй снова'**
  String get emptyDescNoInternet;

  /// No description provided for @emptyTitleAiLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит бесплатной модели'**
  String get emptyTitleAiLimit;

  /// No description provided for @emptyDescAiLimit.
  ///
  /// In ru, this message translates to:
  /// **'Ты использовал все 200 запросов на сегодня.'**
  String get emptyDescAiLimit;

  /// No description provided for @emptyAiLimitCountdown.
  ///
  /// In ru, this message translates to:
  /// **'Лимит обнулится через {hours} ч {minutes} мин'**
  String emptyAiLimitCountdown(int hours, int minutes);

  /// No description provided for @emptyAiLimitUpgrade.
  ///
  /// In ru, this message translates to:
  /// **'Перейти на платную модель'**
  String get emptyAiLimitUpgrade;

  /// No description provided for @emptyTitleBadKey.
  ///
  /// In ru, this message translates to:
  /// **'Ключ не работает'**
  String get emptyTitleBadKey;

  /// No description provided for @emptyDescBadKey.
  ///
  /// In ru, this message translates to:
  /// **'Похоже, ключ неверный или закончились средства на счёте.'**
  String get emptyDescBadKey;

  /// No description provided for @emptyActionBadKey.
  ///
  /// In ru, this message translates to:
  /// **'Заменить ключ'**
  String get emptyActionBadKey;

  /// No description provided for @emptyTitleAllDone.
  ///
  /// In ru, this message translates to:
  /// **'Все привычки сегодня'**
  String get emptyTitleAllDone;

  /// No description provided for @emptyNoKeyCta.
  ///
  /// In ru, this message translates to:
  /// **'Ввести ключ'**
  String get emptyNoKeyCta;

  /// No description provided for @celebrationQuote1.
  ///
  /// In ru, this message translates to:
  /// **'Маленькие шаги каждый день — вот и весь секрет.'**
  String get celebrationQuote1;

  /// No description provided for @celebrationQuote2.
  ///
  /// In ru, this message translates to:
  /// **'Ты пришёл. Это уже победа.'**
  String get celebrationQuote2;

  /// No description provided for @celebrationQuote3.
  ///
  /// In ru, this message translates to:
  /// **'Последовательность важнее интенсивности.'**
  String get celebrationQuote3;

  /// No description provided for @quoteOfDayLabel.
  ///
  /// In ru, this message translates to:
  /// **'ЦИТАТА ДНЯ'**
  String get quoteOfDayLabel;

  /// No description provided for @habitsListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get habitsListTitle;

  /// No description provided for @habitsListSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Найти привычку'**
  String get habitsListSearchHint;

  /// No description provided for @habitsListSortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get habitsListSortLabel;

  /// No description provided for @habitsListSortByProgress.
  ///
  /// In ru, this message translates to:
  /// **'По прогрессу'**
  String get habitsListSortByProgress;

  /// No description provided for @habitsListSortByName.
  ///
  /// In ru, this message translates to:
  /// **'По названию'**
  String get habitsListSortByName;

  /// No description provided for @habitsListSortByCreated.
  ///
  /// In ru, this message translates to:
  /// **'По дате создания'**
  String get habitsListSortByCreated;

  /// No description provided for @habitsListSortByStreak.
  ///
  /// In ru, this message translates to:
  /// **'По стрику'**
  String get habitsListSortByStreak;

  /// No description provided for @habitsListFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get habitsListFilterAll;

  /// No description provided for @habitsListFilterActive.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get habitsListFilterActive;

  /// No description provided for @habitsListFilterArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get habitsListFilterArchive;

  /// No description provided for @habitsListEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Привычки не найдены'**
  String get habitsListEmpty;

  /// No description provided for @habitsListCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} привычка} few{{count} привычки} other{{count} привычек}}'**
  String habitsListCount(int count);

  /// No description provided for @habitCardArchiveBadge.
  ///
  /// In ru, this message translates to:
  /// **'АРХИВ'**
  String get habitCardArchiveBadge;

  /// No description provided for @habitCreateStepCounter.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {step} из {total}'**
  String habitCreateStepCounter(int step, int total);

  /// No description provided for @habitCreateSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Создать привычку'**
  String get habitCreateSubmit;

  /// No description provided for @habitEditSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать привычку'**
  String get habitEditSubmit;

  /// No description provided for @habitCreateStep1Title.
  ///
  /// In ru, this message translates to:
  /// **'Какой тип?'**
  String get habitCreateStep1Title;

  /// No description provided for @habitCreateStep1Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Это влияет на то, как ты будешь её отмечать.'**
  String get habitCreateStep1Subtitle;

  /// No description provided for @habitTypeBinary.
  ///
  /// In ru, this message translates to:
  /// **'Бинарная'**
  String get habitTypeBinary;

  /// No description provided for @habitTypeBinaryDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сделал / не сделал'**
  String get habitTypeBinaryDesc;

  /// No description provided for @habitTypeCountable.
  ///
  /// In ru, this message translates to:
  /// **'Количественная'**
  String get habitTypeCountable;

  /// No description provided for @habitTypeCountableDesc.
  ///
  /// In ru, this message translates to:
  /// **'X раз в день'**
  String get habitTypeCountableDesc;

  /// No description provided for @habitTypeTimed.
  ///
  /// In ru, this message translates to:
  /// **'По длительности'**
  String get habitTypeTimed;

  /// No description provided for @habitTypeTimedDesc.
  ///
  /// In ru, this message translates to:
  /// **'X минут / часов'**
  String get habitTypeTimedDesc;

  /// No description provided for @habitTypeAnti.
  ///
  /// In ru, this message translates to:
  /// **'Анти-привычка'**
  String get habitTypeAnti;

  /// No description provided for @habitTypeAntiDesc.
  ///
  /// In ru, this message translates to:
  /// **'Не делать X'**
  String get habitTypeAntiDesc;

  /// No description provided for @habitCreateStep2Title.
  ///
  /// In ru, this message translates to:
  /// **'Название и иконка'**
  String get habitCreateStep2Title;

  /// No description provided for @habitCreateStep2Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Как будет называться привычка?'**
  String get habitCreateStep2Subtitle;

  /// No description provided for @habitCreateStep2NameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Медитация утром'**
  String get habitCreateStep2NameHint;

  /// No description provided for @habitCreateStep2IconLabel.
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get habitCreateStep2IconLabel;

  /// No description provided for @habitCreateStep2EmojiTab.
  ///
  /// In ru, this message translates to:
  /// **'😀 Эмодзи'**
  String get habitCreateStep2EmojiTab;

  /// No description provided for @habitCreateStep2PhotoTab.
  ///
  /// In ru, this message translates to:
  /// **'📷 Фото'**
  String get habitCreateStep2PhotoTab;

  /// No description provided for @habitCreateStep2PhotoUpload.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить фото'**
  String get habitCreateStep2PhotoUpload;

  /// No description provided for @habitCreateStep2PhotoHint.
  ///
  /// In ru, this message translates to:
  /// **'PNG, JPG до 5 МБ'**
  String get habitCreateStep2PhotoHint;

  /// No description provided for @habitCreateStep2AccentColorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цвет акцента'**
  String get habitCreateStep2AccentColorLabel;

  /// No description provided for @habitCategoryNew.
  ///
  /// In ru, this message translates to:
  /// **'+ Новая'**
  String get habitCategoryNew;

  /// No description provided for @habitCreateStep3Title.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get habitCreateStep3Title;

  /// No description provided for @habitCreateStep3Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда и как часто?'**
  String get habitCreateStep3Subtitle;

  /// No description provided for @habitCreateStep3RepeatTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип повтора'**
  String get habitCreateStep3RepeatTypeLabel;

  /// No description provided for @habitCreateStep3FrequencyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get habitCreateStep3FrequencyLabel;

  /// No description provided for @habitCreateStep3FrequencyValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} раза в неделю'**
  String habitCreateStep3FrequencyValue(int value);

  /// No description provided for @habitCreateStep3EveryNDays.
  ///
  /// In ru, this message translates to:
  /// **'Каждые {n} дней'**
  String habitCreateStep3EveryNDays(int n);

  /// No description provided for @habitCreateStep3SelectDays.
  ///
  /// In ru, this message translates to:
  /// **'ВЫБЕРИТЕ ДНИ'**
  String get habitCreateStep3SelectDays;

  /// No description provided for @habitCreateStep3GoalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цель на день'**
  String get habitCreateStep3GoalLabel;

  /// No description provided for @habitCreateStep3RemindersLabel.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get habitCreateStep3RemindersLabel;

  /// No description provided for @habitCreateStep3AddReminder.
  ///
  /// In ru, this message translates to:
  /// **'Добавить время'**
  String get habitCreateStep3AddReminder;

  /// No description provided for @habitCreateStep3RemindersHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно несколько — например, 3 раза в день для воды.'**
  String get habitCreateStep3RemindersHint;

  /// No description provided for @habitCreateStep3PeriodLabel.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get habitCreateStep3PeriodLabel;

  /// No description provided for @habitCreateStep3StartDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get habitCreateStep3StartDateLabel;

  /// No description provided for @habitCreateStep3Endless.
  ///
  /// In ru, this message translates to:
  /// **'Бессрочно'**
  String get habitCreateStep3Endless;

  /// No description provided for @habitCreateStep4Title.
  ///
  /// In ru, this message translates to:
  /// **'Усиление'**
  String get habitCreateStep4Title;

  /// No description provided for @habitCreateStep4Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Опционально. Эти поля используют проверенные техники, чтобы привычка реально прижилась. Можно пропустить.'**
  String get habitCreateStep4Subtitle;

  /// No description provided for @habitCreateStep4StackingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Habit Stacking'**
  String get habitCreateStep4StackingTitle;

  /// No description provided for @habitCreateStep4StackingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'После какой привычки делать новую?'**
  String get habitCreateStep4StackingSubtitle;

  /// No description provided for @habitCreateStep4IntentionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Implementation Intention'**
  String get habitCreateStep4IntentionTitle;

  /// No description provided for @habitCreateStep4IntentionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Где и когда именно ты это делаешь?'**
  String get habitCreateStep4IntentionSubtitle;

  /// No description provided for @habitCreateStep4IntentionWhenHint.
  ///
  /// In ru, this message translates to:
  /// **'Когда: например, после душа'**
  String get habitCreateStep4IntentionWhenHint;

  /// No description provided for @habitCreateStep4IntentionWhereHint.
  ///
  /// In ru, this message translates to:
  /// **'Где: например, на коврике в спальне'**
  String get habitCreateStep4IntentionWhereHint;

  /// No description provided for @habitCreateStep4IdentityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Identity'**
  String get habitCreateStep4IdentityTitle;

  /// No description provided for @habitCreateStep4IdentitySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Я становлюсь человеком, который...'**
  String get habitCreateStep4IdentitySubtitle;

  /// No description provided for @habitCreateStep4IdentityHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: ценит своё психическое здоровье'**
  String get habitCreateStep4IdentityHint;

  /// No description provided for @habitCreateStep4IdentityNote.
  ///
  /// In ru, this message translates to:
  /// **'Эта фраза будет появляться в напоминаниях.'**
  String get habitCreateStep4IdentityNote;

  /// No description provided for @habitCreateStep4TwoMinTitle.
  ///
  /// In ru, this message translates to:
  /// **'2-минутная версия'**
  String get habitCreateStep4TwoMinTitle;

  /// No description provided for @habitCreateStep4TwoMinSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Минимум для трудных дней'**
  String get habitCreateStep4TwoMinSubtitle;

  /// No description provided for @habitCreateStep4TwoMinHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 1 минута дыхания вместо медитации'**
  String get habitCreateStep4TwoMinHint;

  /// No description provided for @habitCreateStep4RewardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get habitCreateStep4RewardTitle;

  /// No description provided for @habitCreateStep4RewardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Что я получаю, когда выполняю'**
  String get habitCreateStep4RewardSubtitle;

  /// No description provided for @habitCreateStep4RewardHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: чашка хорошего кофе после'**
  String get habitCreateStep4RewardHint;

  /// No description provided for @habitCreateStep4PreviewLabel.
  ///
  /// In ru, this message translates to:
  /// **'ПРЕДПРОСМОТР'**
  String get habitCreateStep4PreviewLabel;

  /// No description provided for @habitCreateStep4PreviewName.
  ///
  /// In ru, this message translates to:
  /// **'Название привычки'**
  String get habitCreateStep4PreviewName;

  /// No description provided for @habitCreateStep4PreviewStreak.
  ///
  /// In ru, this message translates to:
  /// **'СТРИК'**
  String get habitCreateStep4PreviewStreak;

  /// No description provided for @habitCreateStep4PreviewToday.
  ///
  /// In ru, this message translates to:
  /// **'СЕГОДНЯ'**
  String get habitCreateStep4PreviewToday;

  /// No description provided for @habitCreateStep4ActionBinary.
  ///
  /// In ru, this message translates to:
  /// **'Отметить как выполнено'**
  String get habitCreateStep4ActionBinary;

  /// No description provided for @habitCreateStep4ActionAnti.
  ///
  /// In ru, this message translates to:
  /// **'Держаться'**
  String get habitCreateStep4ActionAnti;

  /// No description provided for @habitCreateStep4ActionOther.
  ///
  /// In ru, this message translates to:
  /// **'Зафиксировать прогресс'**
  String get habitCreateStep4ActionOther;

  /// No description provided for @habitCreateStep4Reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить и заполнить заново'**
  String get habitCreateStep4Reset;

  /// No description provided for @habitDetailStatistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get habitDetailStatistics;

  /// No description provided for @habitDetailCurrentStreak.
  ///
  /// In ru, this message translates to:
  /// **'Текущий\nstreak'**
  String get habitDetailCurrentStreak;

  /// No description provided for @habitDetailBestStreak.
  ///
  /// In ru, this message translates to:
  /// **'Лучший\nstreak'**
  String get habitDetailBestStreak;

  /// No description provided for @habitDetailLast30Days.
  ///
  /// In ru, this message translates to:
  /// **'За 30\nдней'**
  String get habitDetailLast30Days;

  /// No description provided for @habitDetailLast90Days.
  ///
  /// In ru, this message translates to:
  /// **'Последние 90 дней'**
  String get habitDetailLast90Days;

  /// No description provided for @habitDetailHeatmapDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get habitDetailHeatmapDone;

  /// No description provided for @habitDetailHeatmapPartial.
  ///
  /// In ru, this message translates to:
  /// **'Частично'**
  String get habitDetailHeatmapPartial;

  /// No description provided for @habitDetailHeatmapMissed.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get habitDetailHeatmapMissed;

  /// No description provided for @habitDetailHeatmapSkip.
  ///
  /// In ru, this message translates to:
  /// **'Skip'**
  String get habitDetailHeatmapSkip;

  /// No description provided for @habitDetailDynamics.
  ///
  /// In ru, this message translates to:
  /// **'Динамика выполнения'**
  String get habitDetailDynamics;

  /// No description provided for @habitDetailChartWeeks.
  ///
  /// In ru, this message translates to:
  /// **'{count} недель'**
  String habitDetailChartWeeks(int count);

  /// No description provided for @habitDetailChartAverage.
  ///
  /// In ru, this message translates to:
  /// **'Средний: {percent}%'**
  String habitDetailChartAverage(int percent);

  /// No description provided for @habitDetailChartWeekShort.
  ///
  /// In ru, this message translates to:
  /// **'Н{n}'**
  String habitDetailChartWeekShort(int n);

  /// No description provided for @habitDetailBehavior.
  ///
  /// In ru, this message translates to:
  /// **'Поведенческие настройки'**
  String get habitDetailBehavior;

  /// No description provided for @habitDetailBehaviorAfter.
  ///
  /// In ru, this message translates to:
  /// **'После'**
  String get habitDetailBehaviorAfter;

  /// No description provided for @habitDetailBehaviorWhere.
  ///
  /// In ru, this message translates to:
  /// **'Где'**
  String get habitDetailBehaviorWhere;

  /// No description provided for @habitDetailBehaviorIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Я'**
  String get habitDetailBehaviorIdentity;

  /// No description provided for @habitDetailBehaviorMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимум'**
  String get habitDetailBehaviorMin;

  /// No description provided for @habitDetailBehaviorReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get habitDetailBehaviorReward;

  /// No description provided for @habitMoreSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get habitMoreSheetTitle;

  /// No description provided for @habitMoreSheetIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Идентичность'**
  String get habitMoreSheetIdentity;

  /// No description provided for @habitMoreSheetReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get habitMoreSheetReward;

  /// No description provided for @habitMoreSheetIntention.
  ///
  /// In ru, this message translates to:
  /// **'Намерение'**
  String get habitMoreSheetIntention;

  /// No description provided for @habitDetailHistory.
  ///
  /// In ru, this message translates to:
  /// **'Последние отметки'**
  String get habitDetailHistory;

  /// No description provided for @habitDetailArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать'**
  String get habitDetailArchive;

  /// No description provided for @habitDetailAiChat.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в чате с ИИ'**
  String get habitDetailAiChat;

  /// No description provided for @habitDetailHistoryEdit.
  ///
  /// In ru, this message translates to:
  /// **'Дополнить →'**
  String get habitDetailHistoryEdit;

  /// No description provided for @habitCardStackAfter.
  ///
  /// In ru, this message translates to:
  /// **'После: {emoji} {name}'**
  String habitCardStackAfter(String emoji, String name);

  /// No description provided for @habitCardLogSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполнение'**
  String get habitCardLogSheetTitle;

  /// No description provided for @habitCardLogSheetFull.
  ///
  /// In ru, this message translates to:
  /// **'Полностью'**
  String get habitCardLogSheetFull;

  /// No description provided for @habitCardLogSheetFullSub.
  ///
  /// In ru, this message translates to:
  /// **'Сделал как задумывал'**
  String get habitCardLogSheetFullSub;

  /// No description provided for @habitCardLogSheetMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимальный вариант'**
  String get habitCardLogSheetMin;

  /// No description provided for @habitCardLogSheetMinSub.
  ///
  /// In ru, this message translates to:
  /// **'{version}'**
  String habitCardLogSheetMinSub(String version);

  /// No description provided for @habitDetailArchivedToast.
  ///
  /// In ru, this message translates to:
  /// **'Привычка архивирована'**
  String get habitDetailArchivedToast;

  /// No description provided for @habitDetailDeletedToast.
  ///
  /// In ru, this message translates to:
  /// **'Привычка удалена'**
  String get habitDetailDeletedToast;

  /// No description provided for @habitDetailDeleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить привычку?'**
  String get habitDetailDeleteConfirmTitle;

  /// No description provided for @habitDetailDeleteConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'Все отметки и история будут удалены навсегда. Восстановление невозможно.'**
  String get habitDetailDeleteConfirmBody;

  /// No description provided for @habitHistoryStatusDone.
  ///
  /// In ru, this message translates to:
  /// **'Сделано'**
  String get habitHistoryStatusDone;

  /// No description provided for @habitHistoryStatusMissed.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get habitHistoryStatusMissed;

  /// No description provided for @habitTimerStart.
  ///
  /// In ru, this message translates to:
  /// **'▶ Старт'**
  String get habitTimerStart;

  /// No description provided for @habitTimerPause.
  ///
  /// In ru, this message translates to:
  /// **'⏸ Пауза'**
  String get habitTimerPause;

  /// No description provided for @habitAntiDays.
  ///
  /// In ru, this message translates to:
  /// **'ДНЕЙ'**
  String get habitAntiDays;

  /// No description provided for @habitAntiMarkedToday.
  ///
  /// In ru, this message translates to:
  /// **'✓ Отмечено сегодня'**
  String get habitAntiMarkedToday;

  /// No description provided for @habitAntiHeld.
  ///
  /// In ru, this message translates to:
  /// **'Удержался'**
  String get habitAntiHeld;

  /// No description provided for @journalCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запиши день'**
  String get journalCardTitle;

  /// No description provided for @journalCardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'4 коротких вопроса или свободный текст'**
  String get journalCardSubtitle;

  /// No description provided for @journalCardEditLink.
  ///
  /// In ru, this message translates to:
  /// **'Дополнить →'**
  String get journalCardEditLink;

  /// No description provided for @journalListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневник'**
  String get journalListTitle;

  /// No description provided for @journalListFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get journalListFilterAll;

  /// No description provided for @journalListFilterMonth.
  ///
  /// In ru, this message translates to:
  /// **'Этот месяц'**
  String get journalListFilterMonth;

  /// No description provided for @journalListFilterLowMood.
  ///
  /// In ru, this message translates to:
  /// **'С низким настроением'**
  String get journalListFilterLowMood;

  /// No description provided for @journalListFilterHighMood.
  ///
  /// In ru, this message translates to:
  /// **'С высоким настроением'**
  String get journalListFilterHighMood;

  /// No description provided for @journalListEntriesLabel.
  ///
  /// In ru, this message translates to:
  /// **'записей'**
  String get journalListEntriesLabel;

  /// No description provided for @journalListStreak.
  ///
  /// In ru, this message translates to:
  /// **'Ведёшь дневник {days} дней подряд 🔥'**
  String journalListStreak(int days);

  /// No description provided for @journalFabLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get journalFabLabel;

  /// No description provided for @journalEditHeaderToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get journalEditHeaderToday;

  /// No description provided for @journalEditHeaderDate.
  ///
  /// In ru, this message translates to:
  /// **'{date}'**
  String journalEditHeaderDate(String date);

  /// No description provided for @journalEditSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get journalEditSave;

  /// No description provided for @journalEditSaving.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение…'**
  String get journalEditSaving;

  /// No description provided for @journalEditLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить запись'**
  String get journalEditLoadError;

  /// No description provided for @journalEditHabitsTitle.
  ///
  /// In ru, this message translates to:
  /// **'ПРИВЫЧКИ СЕГОДНЯ'**
  String get journalEditHabitsTitle;

  /// No description provided for @journalEditMoodLabel.
  ///
  /// In ru, this message translates to:
  /// **'Настроение'**
  String get journalEditMoodLabel;

  /// No description provided for @journalEditEnergyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get journalEditEnergyLabel;

  /// No description provided for @journalEditEntryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get journalEditEntryLabel;

  /// No description provided for @journalEditPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Что важно записать о сегодняшнем дне?'**
  String get journalEditPlaceholder;

  /// No description provided for @journalEditCharCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} символов'**
  String journalEditCharCount(int count);

  /// No description provided for @journalEditQuestionsShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать вопросы'**
  String get journalEditQuestionsShow;

  /// No description provided for @journalEditQuestionsHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get journalEditQuestionsHide;

  /// No description provided for @journalEditQuestionPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Напишите здесь...'**
  String get journalEditQuestionPlaceholder;

  /// No description provided for @journalEditChangeTemplate.
  ///
  /// In ru, this message translates to:
  /// **'Изменить шаблон вопросов'**
  String get journalEditChangeTemplate;

  /// No description provided for @analyticsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analyticsTitle;

  /// No description provided for @analyticsWeekTab.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get analyticsWeekTab;

  /// No description provided for @analyticsMonthTab.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get analyticsMonthTab;

  /// No description provided for @analyticsSummaryLabel.
  ///
  /// In ru, this message translates to:
  /// **'ВЫПОЛНЕНИЕ'**
  String get analyticsSummaryLabel;

  /// No description provided for @analyticsTrendUpWeek.
  ///
  /// In ru, this message translates to:
  /// **'↑ +{percent}% к прошлой неделе'**
  String analyticsTrendUpWeek(int percent);

  /// No description provided for @analyticsTrendDownWeek.
  ///
  /// In ru, this message translates to:
  /// **'↓ -{percent}% к прошлой неделе'**
  String analyticsTrendDownWeek(int percent);

  /// No description provided for @analyticsTrendNeutralWeek.
  ///
  /// In ru, this message translates to:
  /// **'• 0% к прошлой неделе'**
  String get analyticsTrendNeutralWeek;

  /// No description provided for @analyticsTrendUpMonth.
  ///
  /// In ru, this message translates to:
  /// **'↑ +{percent}% к прошлому месяцу'**
  String analyticsTrendUpMonth(int percent);

  /// No description provided for @analyticsTrendDownMonth.
  ///
  /// In ru, this message translates to:
  /// **'↓ -{percent}% к прошлому месяцу'**
  String analyticsTrendDownMonth(int percent);

  /// No description provided for @analyticsTrendNeutralMonth.
  ///
  /// In ru, this message translates to:
  /// **'• 0% к прошлому месяцу'**
  String get analyticsTrendNeutralMonth;

  /// No description provided for @analyticsSubtextPeriod.
  ///
  /// In ru, this message translates to:
  /// **'За период: {label}'**
  String analyticsSubtextPeriod(String label);

  /// No description provided for @analyticsMetricCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get analyticsMetricCompleted;

  /// No description provided for @analyticsMetricSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get analyticsMetricSkipped;

  /// No description provided for @analyticsMetricBestDay.
  ///
  /// In ru, this message translates to:
  /// **'Лучший день'**
  String get analyticsMetricBestDay;

  /// No description provided for @analyticsMetricStreaks.
  ///
  /// In ru, this message translates to:
  /// **'Стрики ↑'**
  String get analyticsMetricStreaks;

  /// No description provided for @analyticsMetricStreaksSubtext.
  ///
  /// In ru, this message translates to:
  /// **'привычки растут'**
  String get analyticsMetricStreaksSubtext;

  /// No description provided for @analyticsBarChartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение по дням'**
  String get analyticsBarChartTitle;

  /// No description provided for @analyticsLegendLow.
  ///
  /// In ru, this message translates to:
  /// **'< 40%'**
  String get analyticsLegendLow;

  /// No description provided for @analyticsLegendMedium.
  ///
  /// In ru, this message translates to:
  /// **'40–70%'**
  String get analyticsLegendMedium;

  /// No description provided for @analyticsLegendHigh.
  ///
  /// In ru, this message translates to:
  /// **'> 70%'**
  String get analyticsLegendHigh;

  /// No description provided for @analyticsHeatmapTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тепловая карта'**
  String get analyticsHeatmapTitle;

  /// No description provided for @analyticsHeatmapLess.
  ///
  /// In ru, this message translates to:
  /// **'Меньше'**
  String get analyticsHeatmapLess;

  /// No description provided for @analyticsHeatmapMore.
  ///
  /// In ru, this message translates to:
  /// **'Больше'**
  String get analyticsHeatmapMore;

  /// No description provided for @analyticsPieTitle.
  ///
  /// In ru, this message translates to:
  /// **'По категориям'**
  String get analyticsPieTitle;

  /// No description provided for @analyticsMoodLineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настроение и энергия'**
  String get analyticsMoodLineTitle;

  /// No description provided for @analyticsMoodLine.
  ///
  /// In ru, this message translates to:
  /// **'Настроение'**
  String get analyticsMoodLine;

  /// No description provided for @analyticsEnergyLine.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get analyticsEnergyLine;

  /// No description provided for @analyticsTopHabitsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Топ-3 привычки'**
  String get analyticsTopHabitsTitle;

  /// No description provided for @analyticsTopHabitsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'ПО ВЫПОЛНЕНИЮ'**
  String get analyticsTopHabitsSubtitle;

  /// No description provided for @analyticsAiCorrelationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-корреляции'**
  String get analyticsAiCorrelationsTitle;

  /// No description provided for @analyticsAiCorrelationsMessage.
  ///
  /// In ru, this message translates to:
  /// **'Введи ключ OpenRouter, чтобы видеть персональные корреляции и инсайты по твоим привычкам.'**
  String get analyticsAiCorrelationsMessage;

  /// No description provided for @analyticsSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get analyticsSettings;

  /// No description provided for @weeklyReviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обзор недели'**
  String get weeklyReviewTitle;

  /// No description provided for @weeklyReviewSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Короткий воскресный чеклист, чтобы закрыть неделю.'**
  String get weeklyReviewSubtitle;

  /// No description provided for @weeklyReviewItemStreak.
  ///
  /// In ru, this message translates to:
  /// **'Посмотрел стрики'**
  String get weeklyReviewItemStreak;

  /// No description provided for @weeklyReviewItemCorrelations.
  ///
  /// In ru, this message translates to:
  /// **'Посмотрел корреляции'**
  String get weeklyReviewItemCorrelations;

  /// No description provided for @weeklyReviewItemGoals.
  ///
  /// In ru, this message translates to:
  /// **'Обновил цели'**
  String get weeklyReviewItemGoals;

  /// No description provided for @aiScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'ИИ'**
  String get aiScreenTitle;

  /// No description provided for @aiChatTab.
  ///
  /// In ru, this message translates to:
  /// **'Чат'**
  String get aiChatTab;

  /// No description provided for @aiChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'ИИ'**
  String get aiChatTitle;

  /// No description provided for @aiChatSuggestion1.
  ///
  /// In ru, this message translates to:
  /// **'Проанализируй мою неделю'**
  String get aiChatSuggestion1;

  /// No description provided for @aiChatSuggestion2.
  ///
  /// In ru, this message translates to:
  /// **'Где у меня самые слабые места?'**
  String get aiChatSuggestion2;

  /// No description provided for @aiChatSuggestion3.
  ///
  /// In ru, this message translates to:
  /// **'Предложи новую привычку'**
  String get aiChatSuggestion3;

  /// No description provided for @aiChatSuggestion4.
  ///
  /// In ru, this message translates to:
  /// **'Почему я срываюсь?'**
  String get aiChatSuggestion4;

  /// No description provided for @aiChatSuggestion5.
  ///
  /// In ru, this message translates to:
  /// **'Как улучшить утренний ритуал?'**
  String get aiChatSuggestion5;

  /// No description provided for @aiSummariesTab.
  ///
  /// In ru, this message translates to:
  /// **'Сводки'**
  String get aiSummariesTab;

  /// No description provided for @aiPromptsTab.
  ///
  /// In ru, this message translates to:
  /// **'Промпты'**
  String get aiPromptsTab;

  /// No description provided for @aiChatHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История чатов'**
  String get aiChatHistoryTitle;

  /// No description provided for @aiChatNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get aiChatNew;

  /// No description provided for @aiChatDisclaimerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Твой ключ, твои данные'**
  String get aiChatDisclaimerTitle;

  /// No description provided for @aiChatDisclaimerText.
  ///
  /// In ru, this message translates to:
  /// **'Каждое сообщение — это вызов API на твой счёт OpenRouter. Бесплатная модель имеет лимит 200 запросов в день. Содержимое уходит в OpenRouter и провайдера модели. Не пиши то, что не готов поделиться.'**
  String get aiChatDisclaimerText;

  /// No description provided for @aiChatDisclaimerOk.
  ///
  /// In ru, this message translates to:
  /// **'Понял'**
  String get aiChatDisclaimerOk;

  /// No description provided for @aiChatInputPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Спроси что-нибудь...'**
  String get aiChatInputPlaceholder;

  /// No description provided for @aiChatTokenCounter.
  ///
  /// In ru, this message translates to:
  /// **'{model} · {used}/{limit}'**
  String aiChatTokenCounter(String model, int used, int limit);

  /// No description provided for @aiChatRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get aiChatRename;

  /// No description provided for @aiChatDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get aiChatDelete;

  /// No description provided for @aiChatRenameTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое название'**
  String get aiChatRenameTitle;

  /// No description provided for @aiChatRenameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название чата'**
  String get aiChatRenameHint;

  /// No description provided for @aiChatDeleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить чат?'**
  String get aiChatDeleteConfirmTitle;

  /// No description provided for @aiChatDeleteConfirmText.
  ///
  /// In ru, this message translates to:
  /// **'Все сообщения будут удалены. Это нельзя отменить.'**
  String get aiChatDeleteConfirmText;

  /// No description provided for @aiChatRateLimitedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лимит на сегодня исчерпан'**
  String get aiChatRateLimitedTitle;

  /// No description provided for @aiChatRateLimitedText.
  ///
  /// In ru, this message translates to:
  /// **'Сработал дневной лимит OpenRouter (200 запросов на бесплатной модели). Попробуй завтра или выбери платную модель в настройках ИИ.'**
  String get aiChatRateLimitedText;

  /// No description provided for @aiChatNoKeyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавь ключ OpenRouter'**
  String get aiChatNoKeyTitle;

  /// No description provided for @aiChatNoKeyText.
  ///
  /// In ru, this message translates to:
  /// **'Открой настройки ИИ и вставь ключ — без него чат не сможет отправить сообщение.'**
  String get aiChatNoKeyText;

  /// No description provided for @aiChatErrorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Проверь соединение и попробуй ещё раз.'**
  String get aiChatErrorGeneric;

  /// No description provided for @aiStyleCoachName.
  ///
  /// In ru, this message translates to:
  /// **'Коуч'**
  String get aiStyleCoachName;

  /// No description provided for @aiStyleCoachDesc.
  ///
  /// In ru, this message translates to:
  /// **'Профессиональный, без сюсюканья. По умолчанию.'**
  String get aiStyleCoachDesc;

  /// No description provided for @aiStyleCoachPreview.
  ///
  /// In ru, this message translates to:
  /// **'Три пропуска подряд — это уже паттерн. Что именно мешает: время, мотивация или обстоятельства? Давай разберём и скорректируем план.'**
  String get aiStyleCoachPreview;

  /// No description provided for @aiStyleSergeantName.
  ///
  /// In ru, this message translates to:
  /// **'Сержант'**
  String get aiStyleSergeantName;

  /// No description provided for @aiStyleSergeantDesc.
  ///
  /// In ru, this message translates to:
  /// **'Прямой, без оправданий. Жёсткий, но честный.'**
  String get aiStyleSergeantDesc;

  /// No description provided for @aiStyleSergeantPreview.
  ///
  /// In ru, this message translates to:
  /// **'Три раза. Без исключений. Это не обстоятельства — это выбор. Либо ты делаешь это сегодня, либо признаёшь, что это не приоритет.'**
  String get aiStyleSergeantPreview;

  /// No description provided for @aiStyleBuddyName.
  ///
  /// In ru, this message translates to:
  /// **'Друг'**
  String get aiStyleBuddyName;

  /// No description provided for @aiStyleBuddyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Тёплый, неформальный, с юмором. Поддерживает.'**
  String get aiStyleBuddyDesc;

  /// No description provided for @aiStyleBuddyPreview.
  ///
  /// In ru, this message translates to:
  /// **'Эй, всё норм! Жизнь случается 😅 Три пропуска — не катастрофа. Ты уже здесь и думаешь об этом, а это уже победа. Завтра?'**
  String get aiStyleBuddyPreview;

  /// No description provided for @aiStyleSageName.
  ///
  /// In ru, this message translates to:
  /// **'Мудрец'**
  String get aiStyleSageName;

  /// No description provided for @aiStyleSageDesc.
  ///
  /// In ru, this message translates to:
  /// **'Стоическая мудрость, цитаты, метафоры.'**
  String get aiStyleSageDesc;

  /// No description provided for @aiStyleSagePreview.
  ///
  /// In ru, this message translates to:
  /// **'«Не падение определяет нас, а то, как мы встаём». Три пропуска — лишь рябь на воде. Привычка — это не серия, а намерение. Что говорит тебе это молчание?'**
  String get aiStyleSagePreview;

  /// No description provided for @aiStylePoetName.
  ///
  /// In ru, this message translates to:
  /// **'Поэт'**
  String get aiStylePoetName;

  /// No description provided for @aiStylePoetDesc.
  ///
  /// In ru, this message translates to:
  /// **'Метафоры и образы. Только для поддержавших.'**
  String get aiStylePoetDesc;

  /// No description provided for @aiStylePoetPreview.
  ///
  /// In ru, this message translates to:
  /// **'Три пустых вечера, как незаполненные строфы. Тело помнит ритм, даже когда разум забыл. Что остановило движение?'**
  String get aiStylePoetPreview;

  /// No description provided for @aiSummariesInfoBanner.
  ///
  /// In ru, this message translates to:
  /// **'Сводка генерируется автоматически каждые {interval} дневника. У тебя сейчас {count} — следующая через {remaining}.'**
  String aiSummariesInfoBanner(int interval, int count, int remaining);

  /// No description provided for @aiSummariesBadgeNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая'**
  String get aiSummariesBadgeNew;

  /// No description provided for @aiSummaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сводка {from}–{to}'**
  String aiSummaryTitle(int from, int to);

  /// No description provided for @aiSummaryAsk.
  ///
  /// In ru, this message translates to:
  /// **'Спросить про сводку'**
  String get aiSummaryAsk;

  /// No description provided for @aiSummaryRegenerate.
  ///
  /// In ru, this message translates to:
  /// **'Перегенерировать'**
  String get aiSummaryRegenerate;

  /// No description provided for @aiSummaryChatPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Разбери эту сводку подробнее'**
  String get aiSummaryChatPrompt;

  /// No description provided for @aiSummaryRegenerateConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пересобрать сводку?'**
  String get aiSummaryRegenerateConfirmTitle;

  /// No description provided for @aiSummaryRegenerateConfirmText.
  ///
  /// In ru, this message translates to:
  /// **'Текущая сводка будет заменена новой.'**
  String get aiSummaryRegenerateConfirmText;

  /// No description provided for @aiPromptDeleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить промпт?'**
  String get aiPromptDeleteConfirmTitle;

  /// No description provided for @aiPromptDeleteConfirmText.
  ///
  /// In ru, this message translates to:
  /// **'Этот пользовательский промпт будет удален навсегда. Это действие нельзя отменить.'**
  String get aiPromptDeleteConfirmText;

  /// No description provided for @aiPromptCreateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый промпт'**
  String get aiPromptCreateTitle;

  /// No description provided for @aiPromptCreateEmoji.
  ///
  /// In ru, this message translates to:
  /// **'Эмодзи'**
  String get aiPromptCreateEmoji;

  /// No description provided for @aiPromptCreateTitleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get aiPromptCreateTitleLabel;

  /// No description provided for @aiPromptCreateDescLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание / Вопрос'**
  String get aiPromptCreateDescLabel;

  /// No description provided for @aiPromptCreateCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get aiPromptCreateCategoryLabel;

  /// No description provided for @aiPromptSystem1Title.
  ///
  /// In ru, this message translates to:
  /// **'Анализ паттернов'**
  String get aiPromptSystem1Title;

  /// No description provided for @aiPromptSystem1Desc.
  ///
  /// In ru, this message translates to:
  /// **'Проанализируй мои привычки и записи в дневнике за последнее время. Найди скрытые закономерности: в какие дни или периоды я наиболее продуктивен, а когда продуктивность падает, и как это связано с моим настроением.'**
  String get aiPromptSystem1Desc;

  /// No description provided for @aiPromptSystem2Title.
  ///
  /// In ru, this message translates to:
  /// **'Слепые пятна'**
  String get aiPromptSystem2Title;

  /// No description provided for @aiPromptSystem2Desc.
  ///
  /// In ru, this message translates to:
  /// **'Найди в моих данных то, что я сам не замечаю. Какие привычки я незаметно саботирую? Какие эмоции чаще всего предшествуют пропускам? Покажи неочевидные взаимосвязи.'**
  String get aiPromptSystem2Desc;

  /// No description provided for @aiPromptSystem3Title.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз срыва'**
  String get aiPromptSystem3Title;

  /// No description provided for @aiPromptSystem3Desc.
  ///
  /// In ru, this message translates to:
  /// **'Оценить стабильность выполнения моих привычек за последнюю неделю. Выдели те из них, которые находятся под наибольшей угрозой срыва, объясни почему и предложи простую стратегию их спасения.'**
  String get aiPromptSystem3Desc;

  /// No description provided for @aiPromptSystem4Title.
  ///
  /// In ru, this message translates to:
  /// **'Новые привычки'**
  String get aiPromptSystem4Title;

  /// No description provided for @aiPromptSystem4Desc.
  ///
  /// In ru, this message translates to:
  /// **'Изучи мой текущий образ жизни по записям и привычкам. Какую одну новую микро-привычку мне стоит внедрить следующей, чтобы она органично вписалась в мой график и усилила текущие результаты?'**
  String get aiPromptSystem4Desc;

  /// No description provided for @aiPromptSystem5Title.
  ///
  /// In ru, this message translates to:
  /// **'Эмоциональная карта'**
  String get aiPromptSystem5Title;

  /// No description provided for @aiPromptSystem5Desc.
  ///
  /// In ru, this message translates to:
  /// **'Проведи контент-анализ моих дневниковых записей за неделю. Какое преобладающее эмоциональное состояние у меня было? Какие триггеры вызывали радость, а какие — тревогу или спад энергии?'**
  String get aiPromptSystem5Desc;

  /// No description provided for @aiPromptSystem6Title.
  ///
  /// In ru, this message translates to:
  /// **'Анализ корреляций'**
  String get aiPromptSystem6Title;

  /// No description provided for @aiPromptSystem6Desc.
  ///
  /// In ru, this message translates to:
  /// **'Сопоставь выполнение моих ключевых привычек с моим настроением и уровнем энергии из дневника. Как физические привычки (сон, спорт, питание) напрямую влияют на мой эмоциональный фон?'**
  String get aiPromptSystem6Desc;

  /// No description provided for @aiPromptSystem7Title.
  ///
  /// In ru, this message translates to:
  /// **'Динамика роста'**
  String get aiPromptSystem7Title;

  /// No description provided for @aiPromptSystem7Desc.
  ///
  /// In ru, this message translates to:
  /// **'Сравни мои текущие показатели и рефлексию с прошлыми периодами. В чём мой главный прогресс? Как изменилось моё отношение к трудностям и какие полезные ментальные сдвиги произошли?'**
  String get aiPromptSystem7Desc;

  /// No description provided for @aiPromptSystem8Title.
  ///
  /// In ru, this message translates to:
  /// **'Оптимизация фокуса'**
  String get aiPromptSystem8Title;

  /// No description provided for @aiPromptSystem8Desc.
  ///
  /// In ru, this message translates to:
  /// **'Проанализируй привычки, которые я выполняю хуже всего или постоянно откладываю. Стоит ли мне их упростить, временно убрать или заменить на что-то более актуальное прямо сейчас?'**
  String get aiPromptSystem8Desc;

  /// No description provided for @aiPromptSystem9Title.
  ///
  /// In ru, this message translates to:
  /// **'Тайм-дизайн дня'**
  String get aiPromptSystem9Title;

  /// No description provided for @aiPromptSystem9Desc.
  ///
  /// In ru, this message translates to:
  /// **'Посмотри на мои привычки и хронометраж в дневнике. Как мне лучше сгруппировать дела и привычки по времени суток (утро/день/вечер) с учётом моих пиков энергии, чтобы тратить меньше силы воли?'**
  String get aiPromptSystem9Desc;

  /// No description provided for @aiPromptSystem10Title.
  ///
  /// In ru, this message translates to:
  /// **'Проверка ценностей'**
  String get aiPromptSystem10Title;

  /// No description provided for @aiPromptSystem10Desc.
  ///
  /// In ru, this message translates to:
  /// **'Прочитай мои цели и рефлексию. Совпадают ли мои ежедневные действия с тем, кем я хочу быть? Где кроется самый большой разрыв между моими идеалами и реальными делами, и как его сократить?'**
  String get aiPromptSystem10Desc;

  /// No description provided for @aiPromptSystem11Title.
  ///
  /// In ru, this message translates to:
  /// **'Анализ серий'**
  String get aiPromptSystem11Title;

  /// No description provided for @aiPromptSystem11Desc.
  ///
  /// In ru, this message translates to:
  /// **'Посмотри на серии выполненных привычек (стрики). Помогают ли они мне расти или превратились в рутину «ради галочки»? Как мне перестроить систему мотивации, чтобы фокус был на качестве, а не на цифрах?'**
  String get aiPromptSystem11Desc;

  /// No description provided for @aiPromptSystem12Title.
  ///
  /// In ru, this message translates to:
  /// **'Карта триггеров'**
  String get aiPromptSystem12Title;

  /// No description provided for @aiPromptSystem12Desc.
  ///
  /// In ru, this message translates to:
  /// **'Проанализируй все дни, когда я срывался или пропускал привычки. Какие внешние события, люди или внутренние состояния (усталость, стресс) послужили триггерами? Создай план защиты от этих триггеров.'**
  String get aiPromptSystem12Desc;

  /// No description provided for @aiPromptSystem13Title.
  ///
  /// In ru, this message translates to:
  /// **'Проектирование ритуалов'**
  String get aiPromptSystem13Title;

  /// No description provided for @aiPromptSystem13Desc.
  ///
  /// In ru, this message translates to:
  /// **'Выдели 2-3 привычки, которые я делаю стабильнее всего. Как я могу использовать их в качестве «якорей», чтобы прикрепить к ним новые, более сложные привычки и создать устойчивый утренний или вечерний ритуал?'**
  String get aiPromptSystem13Desc;

  /// No description provided for @aiPromptSystem14Title.
  ///
  /// In ru, this message translates to:
  /// **'Письмо поддержки'**
  String get aiPromptSystem14Title;

  /// No description provided for @aiPromptSystem14Desc.
  ///
  /// In ru, this message translates to:
  /// **'На основе моей рефлексии за неделю напиши мне тёплое, поддерживающее письмо от лица заботливого и мудрого друга. Отметь мои старания, мягко подсвети успехи и помоги справиться с самокритикой.'**
  String get aiPromptSystem14Desc;

  /// No description provided for @aiPromptsFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get aiPromptsFilterAll;

  /// No description provided for @aiPromptsFilterAnalysis.
  ///
  /// In ru, this message translates to:
  /// **'Анализ'**
  String get aiPromptsFilterAnalysis;

  /// No description provided for @aiPromptsFilterEmotions.
  ///
  /// In ru, this message translates to:
  /// **'Эмоции'**
  String get aiPromptsFilterEmotions;

  /// No description provided for @aiPromptsFilterGrowth.
  ///
  /// In ru, this message translates to:
  /// **'Рост'**
  String get aiPromptsFilterGrowth;

  /// No description provided for @aiPromptsFilterRelapse.
  ///
  /// In ru, this message translates to:
  /// **'Срывы'**
  String get aiPromptsFilterRelapse;

  /// No description provided for @aiPromptsIntro.
  ///
  /// In ru, this message translates to:
  /// **'Готовые вопросы для ИИ. Тапни — откроется чат с этим вопросом.'**
  String get aiPromptsIntro;

  /// No description provided for @aiPromptsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} промпт} few{{count} промпта} other{{count} промптов}}'**
  String aiPromptsCount(int count);

  /// No description provided for @profileSectionBasic.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get profileSectionBasic;

  /// No description provided for @profileMenuJournal.
  ///
  /// In ru, this message translates to:
  /// **'Дневник'**
  String get profileMenuJournal;

  /// No description provided for @profileMenuAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт и язык'**
  String get profileMenuAccount;

  /// No description provided for @profileSectionSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get profileSectionSettings;

  /// No description provided for @profileMenuAiSettings.
  ///
  /// In ru, this message translates to:
  /// **'ИИ и модель'**
  String get profileMenuAiSettings;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get profileMenuAppearance;

  /// No description provided for @profileMenuReflectionTemplate.
  ///
  /// In ru, this message translates to:
  /// **'Шаблон рефлексии'**
  String get profileMenuReflectionTemplate;

  /// No description provided for @profileSectionSupport.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get profileSectionSupport;

  /// No description provided for @profileMenuDonate.
  ///
  /// In ru, this message translates to:
  /// **'Поддержать проект'**
  String get profileMenuDonate;

  /// No description provided for @profileMenuAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get profileMenuAbout;

  /// No description provided for @profileMenuPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика приватности'**
  String get profileMenuPrivacy;

  /// No description provided for @profileMenuContact.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с автором'**
  String get profileMenuContact;

  /// No description provided for @profileSectionDanger.
  ///
  /// In ru, this message translates to:
  /// **'ОПАСНАЯ ЗОНА'**
  String get profileSectionDanger;

  /// No description provided for @profileMenuDeleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get profileMenuDeleteAccount;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountMessage.
  ///
  /// In ru, this message translates to:
  /// **'Все привычки, дневник и история ИИ будут удалены безвозвратно. Это действие нельзя отменить.'**
  String get profileDeleteAccountMessage;

  /// No description provided for @profileBadgeSupporter.
  ///
  /// In ru, this message translates to:
  /// **'💎 Поддержал проект'**
  String get profileBadgeSupporter;

  /// No description provided for @profileStatsDaysWithApp.
  ///
  /// In ru, this message translates to:
  /// **'дней с\nприложением'**
  String get profileStatsDaysWithApp;

  /// No description provided for @profileStatsActiveHabits.
  ///
  /// In ru, this message translates to:
  /// **'активных\nпривычек'**
  String get profileStatsActiveHabits;

  /// No description provided for @profileStatsStreak.
  ///
  /// In ru, this message translates to:
  /// **'дней\nподряд'**
  String get profileStatsStreak;

  /// No description provided for @donateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поддержать'**
  String get donateTitle;

  /// No description provided for @donateHeroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо, что есть'**
  String get donateHeroTitle;

  /// No description provided for @donateHeroMessage.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow всегда будет бесплатным. Если приложение тебе помогает — поддержи проект через Telegram Stars. Это даёт мне время и силы делать его лучше.'**
  String get donateHeroMessage;

  /// No description provided for @donatePresetsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Выбери сумму'**
  String get donatePresetsLabel;

  /// No description provided for @donateCustomInputLabel.
  ///
  /// In ru, this message translates to:
  /// **'Введи кол-во ⭐'**
  String get donateCustomInputLabel;

  /// No description provided for @donateCustomButton.
  ///
  /// In ru, this message translates to:
  /// **'Своя ⭐'**
  String get donateCustomButton;

  /// No description provided for @donateBenefitsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Бонусы поддержавшим'**
  String get donateBenefitsTitle;

  /// No description provided for @donateBenefitBadge.
  ///
  /// In ru, this message translates to:
  /// **'Бейдж «Поддержал проект» в профиле'**
  String get donateBenefitBadge;

  /// No description provided for @donateBenefitStyle.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительный стиль ИИ — Поэт'**
  String get donateBenefitStyle;

  /// No description provided for @donateBenefitColor.
  ///
  /// In ru, this message translates to:
  /// **'Кастомный акцентный цвет интерфейса'**
  String get donateBenefitColor;

  /// No description provided for @donateBenefitThanks.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо в About-экране (опционально)'**
  String get donateBenefitThanks;

  /// No description provided for @donatePopularBadge.
  ///
  /// In ru, this message translates to:
  /// **'Популярное'**
  String get donatePopularBadge;

  /// No description provided for @donateCta.
  ///
  /// In ru, this message translates to:
  /// **'Поддержать на {stars} ⭐'**
  String donateCta(int stars);

  /// No description provided for @donateMobileNote.
  ///
  /// In ru, this message translates to:
  /// **'Через Telegram Desktop ~30% выгоднее, чем через мобильный (Apple/Google комиссия)'**
  String get donateMobileNote;

  /// No description provided for @donateHistoryLink.
  ///
  /// In ru, this message translates to:
  /// **'История донатов'**
  String get donateHistoryLink;

  /// No description provided for @donateThanksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо!'**
  String get donateThanksTitle;

  /// No description provided for @donateThanksMessage.
  ///
  /// In ru, this message translates to:
  /// **'Ты поддержал проект. Это очень важно!'**
  String get donateThanksMessage;

  /// No description provided for @donateErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get donateErrorTitle;

  /// No description provided for @donateErrorMessage.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать инвойс. Попробуй ещё раз.'**
  String get donateErrorMessage;

  /// No description provided for @donateNotAvailableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата недоступна в мобильном приложении'**
  String get donateNotAvailableTitle;

  /// No description provided for @donateNotAvailableMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, откройте Habit Flow непосредственно в Telegram (как Mini App), чтобы поддержать проект.'**
  String get donateNotAvailableMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @notificationsTelegramBanner.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления через Telegram'**
  String get notificationsTelegramBanner;

  /// No description provided for @notificationsTelegramDesc.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления приходят от @habitflow_bot. Это обычные сообщения с кнопками — никаких системных push.'**
  String get notificationsTelegramDesc;

  /// No description provided for @notificationsReflectionSection.
  ///
  /// In ru, this message translates to:
  /// **'Вечерняя рефлексия'**
  String get notificationsReflectionSection;

  /// No description provided for @notificationsReflectionToggle.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать вести дневник'**
  String get notificationsReflectionToggle;

  /// No description provided for @notificationsReflectionHint.
  ///
  /// In ru, this message translates to:
  /// **'Бот спросит, что было важно за день'**
  String get notificationsReflectionHint;

  /// No description provided for @notificationsQuietHoursSection.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы'**
  String get notificationsQuietHoursSection;

  /// No description provided for @notificationsQuietToggle.
  ///
  /// In ru, this message translates to:
  /// **'Не беспокоить'**
  String get notificationsQuietToggle;

  /// No description provided for @notificationsQuietFrom.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get notificationsQuietFrom;

  /// No description provided for @notificationsQuietTo.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get notificationsQuietTo;

  /// No description provided for @notificationsQuietHint.
  ///
  /// In ru, this message translates to:
  /// **'В это время уведомления не приходят. Привычки, попадающие в окно, переносятся.'**
  String get notificationsQuietHint;

  /// No description provided for @notificationsSoundSection.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get notificationsSoundSection;

  /// No description provided for @notificationsSoundOn.
  ///
  /// In ru, this message translates to:
  /// **'Со звуком'**
  String get notificationsSoundOn;

  /// No description provided for @notificationsSoundOnSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'по умолчанию'**
  String get notificationsSoundOnSubtitle;

  /// No description provided for @notificationsSoundOff.
  ///
  /// In ru, this message translates to:
  /// **'Без звука'**
  String get notificationsSoundOff;

  /// No description provided for @notificationsSoundOffSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'через disable_notification'**
  String get notificationsSoundOffSubtitle;

  /// No description provided for @notificationsPreviewSection.
  ///
  /// In ru, this message translates to:
  /// **'Превью уведомления'**
  String get notificationsPreviewSection;

  /// No description provided for @notificationsPreviewHint.
  ///
  /// In ru, this message translates to:
  /// **'Так выглядит обычное напоминание о привычке'**
  String get notificationsPreviewHint;

  /// No description provided for @notificationsPreviewBubble.
  ///
  /// In ru, this message translates to:
  /// **'🌅 Утренняя медитация — твоё время. Минимум — 1 минута.\nStreak: 14 дней 🔥'**
  String get notificationsPreviewBubble;

  /// No description provided for @notificationsPreviewDone.
  ///
  /// In ru, this message translates to:
  /// **'✅ Сделано'**
  String get notificationsPreviewDone;

  /// No description provided for @notificationsPreviewSkip.
  ///
  /// In ru, this message translates to:
  /// **'⏭ Пропустил'**
  String get notificationsPreviewSkip;

  /// No description provided for @notificationsPreviewMore.
  ///
  /// In ru, this message translates to:
  /// **'💬 Подробнее'**
  String get notificationsPreviewMore;

  /// No description provided for @notificationsRareSection.
  ///
  /// In ru, this message translates to:
  /// **'Редкие уведомления'**
  String get notificationsRareSection;

  /// No description provided for @notificationsWeeklyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Воскресный обзор недели'**
  String get notificationsWeeklyTitle;

  /// No description provided for @notificationsWeeklySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Каждое воскресенье вечером'**
  String get notificationsWeeklySubtitle;

  /// No description provided for @notificationsAiSummaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Готова ИИ-сводка'**
  String get notificationsAiSummaryTitle;

  /// No description provided for @notificationsAiSummarySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'После каждых 30 записей'**
  String get notificationsAiSummarySubtitle;

  /// No description provided for @notificationsRecoveryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Recovery-сообщения'**
  String get notificationsRecoveryTitle;

  /// No description provided for @notificationsRecoverySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Если пропустил вчера'**
  String get notificationsRecoverySubtitle;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'ИИ и модель'**
  String get aiSettingsTitle;

  /// No description provided for @aiSettingsApiKeySection.
  ///
  /// In ru, this message translates to:
  /// **'Ключ OpenRouter'**
  String get aiSettingsApiKeySection;

  /// No description provided for @aiSettingsApiKeyLabel.
  ///
  /// In ru, this message translates to:
  /// **'API ключ'**
  String get aiSettingsApiKeyLabel;

  /// No description provided for @aiSettingsApiKeyLink.
  ///
  /// In ru, this message translates to:
  /// **'Где взять ключ'**
  String get aiSettingsApiKeyLink;

  /// No description provided for @aiSettingsHowItWorks.
  ///
  /// In ru, this message translates to:
  /// **'Как это работает'**
  String get aiSettingsHowItWorks;

  /// No description provided for @aiSettingsStatusUnchecked.
  ///
  /// In ru, this message translates to:
  /// **'Не проверен'**
  String get aiSettingsStatusUnchecked;

  /// No description provided for @aiSettingsStatusChecking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем...'**
  String get aiSettingsStatusChecking;

  /// No description provided for @aiSettingsStatusOk.
  ///
  /// In ru, this message translates to:
  /// **'Ключ работает'**
  String get aiSettingsStatusOk;

  /// No description provided for @aiSettingsStatusError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка авторизации'**
  String get aiSettingsStatusError;

  /// No description provided for @aiSettingsTestButton.
  ///
  /// In ru, this message translates to:
  /// **'Тестовый запрос'**
  String get aiSettingsTestButton;

  /// No description provided for @aiSettingsModelSection.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get aiSettingsModelSection;

  /// No description provided for @aiSettingsAllModelsLink.
  ///
  /// In ru, this message translates to:
  /// **'Все модели OpenRouter'**
  String get aiSettingsAllModelsLink;

  /// No description provided for @aiSettingsStyleSection.
  ///
  /// In ru, this message translates to:
  /// **'Стиль ИИ'**
  String get aiSettingsStyleSection;

  /// No description provided for @aiSettingsStyleSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Тон собеседника'**
  String get aiSettingsStyleSubtitle;

  /// No description provided for @aiBadgeFree.
  ///
  /// In ru, this message translates to:
  /// **'БЕСПЛАТНО'**
  String get aiBadgeFree;

  /// No description provided for @aiSettingsStyleExampleHeader.
  ///
  /// In ru, this message translates to:
  /// **'ПРИМЕР ОТВЕТА · «Я ПРОПУСТИЛ СПОРТ УЖЕ ТРИ РАЗА»'**
  String get aiSettingsStyleExampleHeader;

  /// No description provided for @aiSettingsUsageSection.
  ///
  /// In ru, this message translates to:
  /// **'Использование'**
  String get aiSettingsUsageSection;

  /// No description provided for @aiSettingsUsageToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get aiSettingsUsageToday;

  /// No description provided for @aiSettingsUsageMonth.
  ///
  /// In ru, this message translates to:
  /// **'За месяц'**
  String get aiSettingsUsageMonth;

  /// No description provided for @aiSettingsUsageSpent.
  ///
  /// In ru, this message translates to:
  /// **'Потрачено'**
  String get aiSettingsUsageSpent;

  /// No description provided for @aiSettingsUsageNote.
  ///
  /// In ru, this message translates to:
  /// **'Платные модели — на твоём счёте OpenRouter.'**
  String get aiSettingsUsageNote;

  /// No description provided for @aiSettingsHowItem1Title.
  ///
  /// In ru, this message translates to:
  /// **'Твой ключ — твои данные'**
  String get aiSettingsHowItem1Title;

  /// No description provided for @aiSettingsHowItem1Text.
  ///
  /// In ru, this message translates to:
  /// **'Ключ API хранится только на твоём устройстве и отправляется напрямую в OpenRouter. HabitFlow не видит ни ключ, ни переписку.'**
  String get aiSettingsHowItem1Text;

  /// No description provided for @aiSettingsHowItem2Title.
  ///
  /// In ru, this message translates to:
  /// **'OpenRouter — маршрутизатор моделей'**
  String get aiSettingsHowItem2Title;

  /// No description provided for @aiSettingsHowItem2Text.
  ///
  /// In ru, this message translates to:
  /// **'Это прокси, который даёт доступ к десяткам AI-моделей через единый API. Бесплатные модели не требуют пополнения счёта.'**
  String get aiSettingsHowItem2Text;

  /// No description provided for @aiSettingsHowItem3Title.
  ///
  /// In ru, this message translates to:
  /// **'Оплата только за то, что используешь'**
  String get aiSettingsHowItem3Title;

  /// No description provided for @aiSettingsHowItem3Text.
  ///
  /// In ru, this message translates to:
  /// **'Платные модели списываются с баланса OpenRouter. Бесплатные — с лимитами 20 RPM и 200 RPD — доступны сразу.'**
  String get aiSettingsHowItem3Text;

  /// No description provided for @appearanceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get appearanceTitle;

  /// No description provided for @appearanceThemeSection.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get appearanceThemeSection;

  /// No description provided for @appearanceThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'☀️ Светлая'**
  String get appearanceThemeLight;

  /// No description provided for @appearanceThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'🌙 Тёмная'**
  String get appearanceThemeDark;

  /// No description provided for @appearanceThemeAuto.
  ///
  /// In ru, this message translates to:
  /// **'⚙️ Авто'**
  String get appearanceThemeAuto;

  /// No description provided for @appearanceAccentSection.
  ///
  /// In ru, this message translates to:
  /// **'Акцент'**
  String get appearanceAccentSection;

  /// No description provided for @accentBlue.
  ///
  /// In ru, this message translates to:
  /// **'Синий'**
  String get accentBlue;

  /// No description provided for @accentGreen.
  ///
  /// In ru, this message translates to:
  /// **'Зелёный'**
  String get accentGreen;

  /// No description provided for @accentAmber.
  ///
  /// In ru, this message translates to:
  /// **'Амбер'**
  String get accentAmber;

  /// No description provided for @accentRed.
  ///
  /// In ru, this message translates to:
  /// **'Красный'**
  String get accentRed;

  /// No description provided for @accentViolet.
  ///
  /// In ru, this message translates to:
  /// **'Фиолет.'**
  String get accentViolet;

  /// No description provided for @accentPink.
  ///
  /// In ru, this message translates to:
  /// **'Розовый'**
  String get accentPink;

  /// No description provided for @accentTeal.
  ///
  /// In ru, this message translates to:
  /// **'Бирюза'**
  String get accentTeal;

  /// No description provided for @accentGray.
  ///
  /// In ru, this message translates to:
  /// **'Серый'**
  String get accentGray;

  /// No description provided for @accountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт и язык'**
  String get accountTitle;

  /// No description provided for @accountTelegramSection.
  ///
  /// In ru, this message translates to:
  /// **'Telegram'**
  String get accountTelegramSection;

  /// No description provided for @accountLanguageSection.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса'**
  String get accountLanguageSection;

  /// No description provided for @accountFirstDaySection.
  ///
  /// In ru, this message translates to:
  /// **'Первый день недели'**
  String get accountFirstDaySection;

  /// No description provided for @accountFirstDayMonday.
  ///
  /// In ru, this message translates to:
  /// **'Понедельник'**
  String get accountFirstDayMonday;

  /// No description provided for @accountFirstDaySunday.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get accountFirstDaySunday;

  /// No description provided for @reflectionTemplateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Шаблон рефлексии'**
  String get reflectionTemplateTitle;

  /// No description provided for @reflectionTemplateDesc.
  ///
  /// In ru, this message translates to:
  /// **'Эти вопросы появятся в дневнике, когда ты включишь раздел «Показать вопросы». Можешь править, добавлять и удалять.'**
  String get reflectionTemplateDesc;

  /// No description provided for @reflectionTemplateQ1.
  ///
  /// In ru, this message translates to:
  /// **'Что было главным сегодня?'**
  String get reflectionTemplateQ1;

  /// No description provided for @reflectionTemplateQ2.
  ///
  /// In ru, this message translates to:
  /// **'За что ты благодарен?'**
  String get reflectionTemplateQ2;

  /// No description provided for @reflectionTemplateQ3.
  ///
  /// In ru, this message translates to:
  /// **'Что бы сделал по-другому?'**
  String get reflectionTemplateQ3;

  /// No description provided for @reflectionTemplateQ4.
  ///
  /// In ru, this message translates to:
  /// **'Что зарядило / опустошило?'**
  String get reflectionTemplateQ4;

  /// No description provided for @reflectionTemplateInputHint.
  ///
  /// In ru, this message translates to:
  /// **'Вопрос…'**
  String get reflectionTemplateInputHint;

  /// No description provided for @reflectionTemplateAddButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить вопрос'**
  String get reflectionTemplateAddButton;

  /// No description provided for @reflectionTemplateResetButton.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить к шаблону'**
  String get reflectionTemplateResetButton;

  /// No description provided for @aboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutWhatLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что это'**
  String get aboutWhatLabel;

  /// No description provided for @aboutWhatText.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow — Telegram Mini App: трекер привычек, дневник рефлексии и ИИ-аналитик личных данных.'**
  String get aboutWhatText;

  /// No description provided for @aboutPrinciplesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Принципы'**
  String get aboutPrinciplesLabel;

  /// No description provided for @aboutPrinciplesText.
  ///
  /// In ru, this message translates to:
  /// **'Telegram-нативность · BYO-ключ OpenRouter · полная бесплатность с донатами через Stars · поведенческая наука в UX · RU + EN с первого дня.'**
  String get aboutPrinciplesText;

  /// No description provided for @aboutSpecLink.
  ///
  /// In ru, this message translates to:
  /// **'Спецификация'**
  String get aboutSpecLink;

  /// No description provided for @aboutSpecHint.
  ///
  /// In ru, this message translates to:
  /// **'SPEC.md в репозитории'**
  String get aboutSpecHint;

  /// No description provided for @aboutChannelLink.
  ///
  /// In ru, this message translates to:
  /// **'Telegram-канал'**
  String get aboutChannelLink;

  /// No description provided for @aboutSourceLink.
  ///
  /// In ru, this message translates to:
  /// **'Исходники'**
  String get aboutSourceLink;

  /// No description provided for @privacyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Политика приватности'**
  String get privacyTitle;

  /// No description provided for @privacyAuthLabel.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация'**
  String get privacyAuthLabel;

  /// No description provided for @privacyAuthText.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow использует Telegram initData для входа — мы не запрашиваем email или пароль. На сервер уходит подписанная Telegram строка, мы её проверяем и выпускаем JWT. Никаких сторонних провайдеров.'**
  String get privacyAuthText;

  /// No description provided for @privacyStorageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что хранится'**
  String get privacyStorageLabel;

  /// No description provided for @privacyStorageText.
  ///
  /// In ru, this message translates to:
  /// **'Привычки, отметки выполнения, записи дневника, история ИИ-чата — у нас в Supabase Postgres. Данные привязаны к твоему telegram_user_id и доступны только тебе через Row Level Security.'**
  String get privacyStorageText;

  /// No description provided for @privacyKeyLabel.
  ///
  /// In ru, this message translates to:
  /// **'OpenRouter ключ'**
  String get privacyKeyLabel;

  /// No description provided for @privacyKeyText.
  ///
  /// In ru, this message translates to:
  /// **'API-ключ OpenRouter — твой собственный (BYO key). Он хранится локально на твоём устройстве и отправляется напрямую в OpenRouter. HabitFlow не видит ни ключ, ни переписку с ИИ.'**
  String get privacyKeyText;

  /// No description provided for @privacyNotCollectLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что мы НЕ собираем'**
  String get privacyNotCollectLabel;

  /// No description provided for @privacyNotCollectText.
  ///
  /// In ru, this message translates to:
  /// **'Не логируем initData, не передаём данные третьим лицам, не показываем рекламу, не используем аналитику пользовательских действий внутри приложения.'**
  String get privacyNotCollectText;

  /// No description provided for @privacyDeletionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Удаление данных'**
  String get privacyDeletionLabel;

  /// No description provided for @privacyDeletionText.
  ///
  /// In ru, this message translates to:
  /// **'В разделе «Опасная зона» можно удалить аккаунт. Все привычки, дневник и история ИИ удаляются каскадно из БД. Восстановление невозможно.'**
  String get privacyDeletionText;

  /// No description provided for @privacyContactLabel.
  ///
  /// In ru, this message translates to:
  /// **'Контакт'**
  String get privacyContactLabel;

  /// No description provided for @privacyContactText.
  ///
  /// In ru, this message translates to:
  /// **'Вопросы по приватности — пиши автору через раздел «Связаться с автором» в профиле.'**
  String get privacyContactText;

  /// No description provided for @contactTitle.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с автором'**
  String get contactTitle;

  /// No description provided for @contactDesc.
  ///
  /// In ru, this message translates to:
  /// **'Напиши, если нашёл баг, есть идея фичи или просто хочется поделиться. Отвечаю обычно в течение пары дней.'**
  String get contactDesc;

  /// No description provided for @contactChannelTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Telegram'**
  String get contactChannelTelegram;

  /// No description provided for @contactChannelEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get contactChannelEmail;

  /// No description provided for @contactChannelGithub.
  ///
  /// In ru, this message translates to:
  /// **'GitHub Issues'**
  String get contactChannelGithub;

  /// No description provided for @contactCopiedToast.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано: {value}'**
  String contactCopiedToast(String value);

  /// No description provided for @splashOutsideTelegramTitle.
  ///
  /// In ru, this message translates to:
  /// **'Открой в Telegram'**
  String get splashOutsideTelegramTitle;

  /// No description provided for @splashOutsideTelegramDesc.
  ///
  /// In ru, this message translates to:
  /// **'HabitFlow — это Telegram Mini App. Открой его через бота или ссылку t.me внутри Telegram.'**
  String get splashOutsideTelegramDesc;

  /// No description provided for @splashAuthErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка входа'**
  String get splashAuthErrorTitle;

  /// No description provided for @splashAuthErrorDesc.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться к серверу. Проверь соединение и попробуй снова.'**
  String get splashAuthErrorDesc;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет интернета'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkDesc.
  ///
  /// In ru, this message translates to:
  /// **'Проверь соединение и попробуй снова.'**
  String get errorNetworkDesc;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нужно войти заново'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorizedDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сессия устарела. Открой приложение заново.'**
  String get errorUnauthorizedDesc;

  /// No description provided for @errorAiLimitTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лимит исчерпан'**
  String get errorAiLimitTitle;

  /// No description provided for @errorAiLimitDesc.
  ///
  /// In ru, this message translates to:
  /// **'Все запросы использованы. Подожди или поменяй модель.'**
  String get errorAiLimitDesc;

  /// No description provided for @errorServerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сервер недоступен'**
  String get errorServerTitle;

  /// No description provided for @errorServerDesc.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так на стороне сервера. Попробуй ещё раз.'**
  String get errorServerDesc;

  /// No description provided for @errorValidationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверь поля'**
  String get errorValidationTitle;

  /// No description provided for @errorValidationDesc.
  ///
  /// In ru, this message translates to:
  /// **'Некоторые поля заполнены неверно.'**
  String get errorValidationDesc;

  /// No description provided for @errorGenericTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericDesc.
  ///
  /// In ru, this message translates to:
  /// **'Произошла непредвиденная ошибка. Попробуй ещё раз.'**
  String get errorGenericDesc;

  /// No description provided for @errorRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get errorRetry;

  /// No description provided for @errorRelogin.
  ///
  /// In ru, this message translates to:
  /// **'Перезайти'**
  String get errorRelogin;

  /// No description provided for @errorWait.
  ///
  /// In ru, this message translates to:
  /// **'Подождать'**
  String get errorWait;

  /// No description provided for @errorChangeModel.
  ///
  /// In ru, this message translates to:
  /// **'Поменять модель'**
  String get errorChangeModel;

  /// No description provided for @deviceLinkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Привязка устройства'**
  String get deviceLinkTitle;

  /// No description provided for @deviceLinkBtn.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Telegram'**
  String get deviceLinkBtn;

  /// No description provided for @deviceLinkInstructions.
  ///
  /// In ru, this message translates to:
  /// **'1. Нажмите кнопку ниже, чтобы открыть нашего Telegram-бота.\n2. Нажмите кнопку \'Запустить\' (Start) для подтверждения привязки.\n3. Не закрывайте этот экран, привязка произойдет автоматически.'**
  String get deviceLinkInstructions;

  /// No description provided for @deviceLinkOpenBotBtn.
  ///
  /// In ru, this message translates to:
  /// **'Открыть Telegram-бота'**
  String get deviceLinkOpenBotBtn;

  /// No description provided for @deviceLinkWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание подтверждения...'**
  String get deviceLinkWaiting;

  /// No description provided for @deviceLinkSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Устройство успешно привязано! Перенаправление...'**
  String get deviceLinkSuccess;

  /// No description provided for @deviceLinkFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось привязать устройство: {reason}'**
  String deviceLinkFailed(String reason);

  /// No description provided for @deviceLinkReasonExpired.
  ///
  /// In ru, this message translates to:
  /// **'Срок действия ссылки истек. Пожалуйста, попробуйте снова.'**
  String get deviceLinkReasonExpired;

  /// No description provided for @deviceLinkReasonConsumed.
  ///
  /// In ru, this message translates to:
  /// **'Эта ссылка уже была использована. Пожалуйста, попробуйте снова.'**
  String get deviceLinkReasonConsumed;

  /// No description provided for @deviceLinkReasonNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сети. Проверьте подключение к интернету.'**
  String get deviceLinkReasonNetwork;

  /// No description provided for @deviceLinkReasonUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Произошла неизвестная ошибка. Пожалуйста, попробуйте снова.'**
  String get deviceLinkReasonUnknown;

  /// No description provided for @habitCatHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get habitCatHealth;

  /// No description provided for @habitCatSport.
  ///
  /// In ru, this message translates to:
  /// **'Спорт'**
  String get habitCatSport;

  /// No description provided for @habitCatStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get habitCatStudy;

  /// No description provided for @habitCatWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа'**
  String get habitCatWork;

  /// No description provided for @habitCatRelationships.
  ///
  /// In ru, this message translates to:
  /// **'Отношения'**
  String get habitCatRelationships;

  /// No description provided for @habitCatFinance.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get habitCatFinance;

  /// No description provided for @habitCatHobby.
  ///
  /// In ru, this message translates to:
  /// **'Хобби'**
  String get habitCatHobby;

  /// No description provided for @habitCatMental.
  ///
  /// In ru, this message translates to:
  /// **'Ментальное'**
  String get habitCatMental;

  /// No description provided for @habitCatNew.
  ///
  /// In ru, this message translates to:
  /// **'+ Новая'**
  String get habitCatNew;

  /// No description provided for @habitRepeatDaily.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get habitRepeatDaily;

  /// No description provided for @habitRepeatWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По дням недели'**
  String get habitRepeatWeekdays;

  /// No description provided for @habitRepeatNPerWeek.
  ///
  /// In ru, this message translates to:
  /// **'X раз в неделю'**
  String get habitRepeatNPerWeek;

  /// No description provided for @habitRepeatEveryN.
  ///
  /// In ru, this message translates to:
  /// **'Каждые N дней'**
  String get habitRepeatEveryN;

  /// No description provided for @habitRepeatMonthly.
  ///
  /// In ru, this message translates to:
  /// **'По датам месяца'**
  String get habitRepeatMonthly;

  /// No description provided for @habitWeekMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get habitWeekMon;

  /// No description provided for @habitWeekTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get habitWeekTue;

  /// No description provided for @habitWeekWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get habitWeekWed;

  /// No description provided for @habitWeekThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get habitWeekThu;

  /// No description provided for @habitWeekFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get habitWeekFri;

  /// No description provided for @habitWeekSat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get habitWeekSat;

  /// No description provided for @habitWeekSun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get habitWeekSun;

  /// No description provided for @habitGoalUnitTimes.
  ///
  /// In ru, this message translates to:
  /// **'раз'**
  String get habitGoalUnitTimes;

  /// No description provided for @habitStackingNoHabits.
  ///
  /// In ru, this message translates to:
  /// **'— Сначала создай другую привычку —'**
  String get habitStackingNoHabits;

  /// No description provided for @todayAllDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Все привычки на сегодня!'**
  String get todayAllDoneTitle;

  /// No description provided for @todayAllDoneSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отличный день! 🎉'**
  String get todayAllDoneSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
