import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('nb')
  ];

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @loginSubtitlePre.
  ///
  /// In en, this message translates to:
  /// **'The '**
  String get loginSubtitlePre;

  /// No description provided for @loginSubtitlePost.
  ///
  /// In en, this message translates to:
  /// **' storytelling game'**
  String get loginSubtitlePost;

  /// No description provided for @loginAdj0.
  ///
  /// In en, this message translates to:
  /// **'creative'**
  String get loginAdj0;

  /// No description provided for @loginAdj1.
  ///
  /// In en, this message translates to:
  /// **'hilarious'**
  String get loginAdj1;

  /// No description provided for @loginAdj2.
  ///
  /// In en, this message translates to:
  /// **'ridiculous'**
  String get loginAdj2;

  /// No description provided for @loginAdj3.
  ///
  /// In en, this message translates to:
  /// **'epic'**
  String get loginAdj3;

  /// No description provided for @loginAdj4.
  ///
  /// In en, this message translates to:
  /// **'wild'**
  String get loginAdj4;

  /// No description provided for @loginAdj5.
  ///
  /// In en, this message translates to:
  /// **'chaotic'**
  String get loginAdj5;

  /// No description provided for @loginAdj6.
  ///
  /// In en, this message translates to:
  /// **'legendary'**
  String get loginAdj6;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get chooseMode;

  /// No description provided for @joinFriendRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Or join a friend’s room below'**
  String get joinFriendRoomSubtitle;

  /// No description provided for @modeFillReveal.
  ///
  /// In en, this message translates to:
  /// **'Fill & Reveal'**
  String get modeFillReveal;

  /// No description provided for @modeFillRevealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill hidden adjective blanks — solo or with friends'**
  String get modeFillRevealSubtitle;

  /// No description provided for @fillRevealPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'1 – ★ blanks'**
  String get fillRevealPlayerLabel;

  /// No description provided for @modeRotatingChain.
  ///
  /// In en, this message translates to:
  /// **'Rotating Chain'**
  String get modeRotatingChain;

  /// No description provided for @modeRotatingChainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a chaotic story step-by-step in secret'**
  String get modeRotatingChainSubtitle;

  /// No description provided for @rotatingChainPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'2 – 6 players'**
  String get rotatingChainPlayerLabel;

  /// No description provided for @modeAdjectiveBattle.
  ///
  /// In en, this message translates to:
  /// **'Adjective Battle'**
  String get modeAdjectiveBattle;

  /// No description provided for @modeBattleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete to make the funniest story from the same prompt'**
  String get modeBattleSubtitle;

  /// No description provided for @battlePlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'2 – 8 players'**
  String get battlePlayerLabel;

  /// No description provided for @joinARoom.
  ///
  /// In en, this message translates to:
  /// **'Join a Room'**
  String get joinARoom;

  /// No description provided for @numberOfPlayers.
  ///
  /// In en, this message translates to:
  /// **'Number of players'**
  String get numberOfPlayers;

  /// No description provided for @solo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get solo;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @failedToCreateRoom.
  ///
  /// In en, this message translates to:
  /// **'Failed to create room'**
  String get failedToCreateRoom;

  /// No description provided for @fillRevealPlayerHint.
  ///
  /// In en, this message translates to:
  /// **'Solo = just you. Multiplayer = you write the story, others fill the blanks. You need at least one [ADJ] blank per other player.'**
  String get fillRevealPlayerHint;

  /// No description provided for @rotatingChainPlayerHint.
  ///
  /// In en, this message translates to:
  /// **'Min 2, max 6 — each player writes one step.'**
  String get rotatingChainPlayerHint;

  /// No description provided for @battlePlayerHint.
  ///
  /// In en, this message translates to:
  /// **'Min 2, max 8 — everyone fills the same story and votes.'**
  String get battlePlayerHint;

  /// No description provided for @fillRevealBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Write a story with adjective blanks. Everyone fills them in — then the full story is revealed!'**
  String get fillRevealBannerDesc;

  /// No description provided for @rotatingChainBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Each player writes one part of the story in secret, passing it around the chain.'**
  String get rotatingChainBannerDesc;

  /// No description provided for @battleBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'All players fill the same story independently. The group votes for the funniest result!'**
  String get battleBannerDesc;

  /// No description provided for @enterRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a room code'**
  String get enterRoomCode;

  /// No description provided for @askHostForCode.
  ///
  /// In en, this message translates to:
  /// **'Ask your host for the 6-character code'**
  String get askHostForCode;

  /// No description provided for @roomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get roomCodeLabel;

  /// No description provided for @lettersAndNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Letters and numbers only'**
  String get lettersAndNumbersOnly;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @roomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Room not found. Check the code and try again.'**
  String get roomNotFound;

  /// No description provided for @lobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get lobby;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @waitingForHostToStart.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host to start…'**
  String get waitingForHostToStart;

  /// No description provided for @failedToLoadRoom.
  ///
  /// In en, this message translates to:
  /// **'Failed to load room'**
  String get failedToLoadRoom;

  /// No description provided for @failedToStartGame.
  ///
  /// In en, this message translates to:
  /// **'Failed to start the game'**
  String get failedToStartGame;

  /// No description provided for @hostBadge.
  ///
  /// In en, this message translates to:
  /// **'HOST'**
  String get hostBadge;

  /// No description provided for @roomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code copied!'**
  String get roomCodeCopied;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal!'**
  String get reveal;

  /// No description provided for @waitingForStoryWriter.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the story writer…'**
  String get waitingForStoryWriter;

  /// No description provided for @hostIsWritingStory.
  ///
  /// In en, this message translates to:
  /// **'The host is writing a story. You’ll fill in the adjectives once it’s ready.'**
  String get hostIsWritingStory;

  /// No description provided for @failedToLoadGame.
  ///
  /// In en, this message translates to:
  /// **'Failed to load game'**
  String get failedToLoadGame;

  /// No description provided for @storyNeedsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your story needs at least one [ADJ] placeholder'**
  String get storyNeedsPlaceholder;

  /// No description provided for @addAtLeastNBlanks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Add at least {count} [ADJ] blank — one per player} other{Add at least {count} [ADJ] blanks — one per player}}'**
  String addAtLeastNBlanks(int count);

  /// No description provided for @failedToCreateStory.
  ///
  /// In en, this message translates to:
  /// **'Failed to create story'**
  String get failedToCreateStory;

  /// No description provided for @failedToSubmitAdjective.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit adjective'**
  String get failedToSubmitAdjective;

  /// No description provided for @writeAStory.
  ///
  /// In en, this message translates to:
  /// **'Write a story'**
  String get writeAStory;

  /// No description provided for @soloStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Add [ADJ] placeholders — they’ll be filled with random adjectives when you save.'**
  String get soloStoryHint;

  /// No description provided for @multiStoryHintBase.
  ///
  /// In en, this message translates to:
  /// **'Use [ADJ] as placeholders for adjectives.'**
  String get multiStoryHintBase;

  /// No description provided for @multiStoryHintBlanks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You need at least {count} [ADJ] blank — one per player.} other{You need at least {count} [ADJ] blanks — one per player.}}'**
  String multiStoryHintBlanks(int count);

  /// No description provided for @storyExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: \"The [ADJ] cat sat on a [ADJ] mat.\"'**
  String get storyExampleHint;

  /// No description provided for @writeStoryHere.
  ///
  /// In en, this message translates to:
  /// **'Write your story here…'**
  String get writeStoryHere;

  /// No description provided for @saveAndFillRandomly.
  ///
  /// In en, this message translates to:
  /// **'Save & Fill Randomly'**
  String get saveAndFillRandomly;

  /// No description provided for @saveStory.
  ///
  /// In en, this message translates to:
  /// **'Save Story'**
  String get saveStory;

  /// No description provided for @youWroteThisStory.
  ///
  /// In en, this message translates to:
  /// **'You wrote this story. Wait for the other players to fill in the blanks.'**
  String get youWroteThisStory;

  /// No description provided for @blanksFilled.
  ///
  /// In en, this message translates to:
  /// **'{filled}/{total} blanks filled'**
  String blanksFilled(int filled, int total);

  /// No description provided for @blankN.
  ///
  /// In en, this message translates to:
  /// **'Blank {n}'**
  String blankN(int n);

  /// No description provided for @waitingForYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your turn…'**
  String get waitingForYourTurn;

  /// No description provided for @roundN.
  ///
  /// In en, this message translates to:
  /// **'Round {n}'**
  String roundN(String n);

  /// No description provided for @failedToLoadTurn.
  ///
  /// In en, this message translates to:
  /// **'Failed to load turn'**
  String get failedToLoadTurn;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit'**
  String get failedToSubmit;

  /// No description provided for @yourTurnWriteSentence.
  ///
  /// In en, this message translates to:
  /// **'Your turn: write a sentence'**
  String get yourTurnWriteSentence;

  /// No description provided for @yourTurnFillAdjective.
  ///
  /// In en, this message translates to:
  /// **'Your turn: fill the adjective blank'**
  String get yourTurnFillAdjective;

  /// No description provided for @includePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Include [ADJ] as a placeholder'**
  String get includePlaceholder;

  /// No description provided for @whatAdjectiveFits.
  ///
  /// In en, this message translates to:
  /// **'What adjective fits here?'**
  String get whatAdjectiveFits;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous:'**
  String get previous;

  /// No description provided for @sentenceHint.
  ///
  /// In en, this message translates to:
  /// **'The [ADJ] wizard walked into the [ADJ] forest…'**
  String get sentenceHint;

  /// No description provided for @chainAdjectiveHint.
  ///
  /// In en, this message translates to:
  /// **'mysterious, ancient, fluffy…'**
  String get chainAdjectiveHint;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @storySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Story submitted!'**
  String get storySubmitted;

  /// No description provided for @waitingForOtherPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for other players…'**
  String get waitingForOtherPlayers;

  /// No description provided for @failedToLoadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prompt'**
  String get failedToLoadPrompt;

  /// No description provided for @failedToSubmitEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit your entry'**
  String get failedToSubmitEntry;

  /// No description provided for @failedToCastVote.
  ///
  /// In en, this message translates to:
  /// **'Failed to cast vote'**
  String get failedToCastVote;

  /// No description provided for @fillInAdjectives.
  ///
  /// In en, this message translates to:
  /// **'Fill in the adjectives'**
  String get fillInAdjectives;

  /// No description provided for @yourContinuation.
  ///
  /// In en, this message translates to:
  /// **'Your continuation'**
  String get yourContinuation;

  /// No description provided for @continueStoryHint.
  ///
  /// In en, this message translates to:
  /// **'Continue the story in your own words…'**
  String get continueStoryHint;

  /// No description provided for @submitStory.
  ///
  /// In en, this message translates to:
  /// **'Submit Story'**
  String get submitStory;

  /// No description provided for @voteForBestStory.
  ///
  /// In en, this message translates to:
  /// **'Vote for the best story!'**
  String get voteForBestStory;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'🏆 Results'**
  String get results;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @enterAnAdjective.
  ///
  /// In en, this message translates to:
  /// **'Enter an adjective'**
  String get enterAnAdjective;

  /// No description provided for @blankInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. mysterious, fluffy, ancient…'**
  String get blankInputHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;
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
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
