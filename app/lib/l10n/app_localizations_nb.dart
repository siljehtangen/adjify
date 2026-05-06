// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get signingIn => 'Logger inn…';

  @override
  String get continueWithGoogle => 'Fortsett med Google';

  @override
  String get signInFailed => 'Innlogging mislyktes. Prøv igjen.';

  @override
  String get loginSubtitlePre => 'Det ';

  @override
  String get loginSubtitlePost => ' fortellingsspillet';

  @override
  String get loginAdj0 => 'kreative';

  @override
  String get loginAdj1 => 'morsomme';

  @override
  String get loginAdj2 => 'absurde';

  @override
  String get loginAdj3 => 'episke';

  @override
  String get loginAdj4 => 'ville';

  @override
  String get loginAdj5 => 'kaotiske';

  @override
  String get loginAdj6 => 'legendariske';

  @override
  String get chooseMode => 'Velg modus';

  @override
  String get joinFriendRoomSubtitle => 'Eller bli med i en venns rom nedenfor';

  @override
  String get modeFillReveal => 'Fyll og Avslør';

  @override
  String get modeFillRevealSubtitle =>
      'Fyll skjulte adjektiv-felt — alene eller med venner';

  @override
  String get fillRevealPlayerLabel => '1 – ★ felt';

  @override
  String get modeRotatingChain => 'Rullerende Kjede';

  @override
  String get modeRotatingChainSubtitle =>
      'Bygg en kaotisk historie steg for steg i hemmelighet';

  @override
  String get rotatingChainPlayerLabel => '2 – 6 spillere';

  @override
  String get modeAdjectiveBattle => 'Adjektiv-kamp';

  @override
  String get modeBattleSubtitle =>
      'Konkurrer om å lage den morsomste historien fra samme utgangspunkt';

  @override
  String get battlePlayerLabel => '2 – 8 spillere';

  @override
  String get joinARoom => 'Bli med i et rom';

  @override
  String get numberOfPlayers => 'Antall spillere';

  @override
  String get solo => 'Solo';

  @override
  String get createRoom => 'Opprett rom';

  @override
  String get failedToCreateRoom => 'Kunne ikke opprette rommet';

  @override
  String get fillRevealPlayerHint =>
      'Solo = bare deg. Flerspiller = du skriver historien, andre fyller feltene. Du trenger minst ett [ADJ]-felt per spiller.';

  @override
  String get rotatingChainPlayerHint =>
      'Min 2, maks 6 — hver spiller skriver ett steg.';

  @override
  String get battlePlayerHint =>
      'Min 2, maks 8 — alle fyller samme historie og stemmer.';

  @override
  String get fillRevealBannerDesc =>
      'Skriv en historie med adjektiv-felt. Alle fyller dem inn — så avsløres hele historien!';

  @override
  String get rotatingChainBannerDesc =>
      'Hver spiller skriver én del av historien i hemmelighet og sender den videre.';

  @override
  String get battleBannerDesc =>
      'Alle spillere fyller samme historie uavhengig av hverandre. Gruppen stemmer på det morsomste resultatet!';

  @override
  String get enterRoomCode => 'Skriv inn en romkode';

  @override
  String get askHostForCode => 'Spør verten om den 6-tegns koden';

  @override
  String get roomCodeLabel => 'Romkode';

  @override
  String get lettersAndNumbersOnly => 'Kun bokstaver og tall';

  @override
  String get joinRoom => 'Bli med i rommet';

  @override
  String get roomNotFound =>
      'Rommet ble ikke funnet. Sjekk koden og prøv igjen.';

  @override
  String get lobby => 'Lobby';

  @override
  String get players => 'Spillere';

  @override
  String get startGame => 'Start spillet';

  @override
  String get waitingForHostToStart => 'Venter på at verten starter…';

  @override
  String get failedToLoadRoom => 'Kunne ikke laste rommet';

  @override
  String get failedToStartGame => 'Kunne ikke starte spillet';

  @override
  String get hostBadge => 'VERT';

  @override
  String get roomCodeCopied => 'Romkoden er kopiert!';

  @override
  String get hide => 'Skjul';

  @override
  String get reveal => 'Avslør!';

  @override
  String get waitingForStoryWriter => 'Venter på historieforfatteren…';

  @override
  String get hostIsWritingStory =>
      'Verten skriver en historie. Du fyller inn adjektivene når den er klar.';

  @override
  String get failedToLoadGame => 'Kunne ikke laste spillet';

  @override
  String get storyNeedsPlaceholder =>
      'Historien din trenger minst ett [ADJ]-felt';

  @override
  String addAtLeastNBlanks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Legg til minst $count [ADJ]-felt — ett per spiller',
      one: 'Legg til minst $count [ADJ]-felt — ett per spiller',
    );
    return '$_temp0';
  }

  @override
  String get failedToCreateStory => 'Kunne ikke opprette historien';

  @override
  String get failedToSubmitAdjective => 'Kunne ikke sende inn adjektivet';

  @override
  String get writeAStory => 'Skriv en historie';

  @override
  String get soloStoryHint =>
      'Legg til [ADJ]-felt — de fylles med tilfeldige adjektiver når du lagrer.';

  @override
  String get multiStoryHintBase => 'Bruk [ADJ] som plassholder for adjektiver.';

  @override
  String multiStoryHintBlanks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du trenger minst $count [ADJ]-felt — ett per spiller.',
      one: 'Du trenger minst $count [ADJ]-felt — ett per spiller.',
    );
    return '$_temp0';
  }

  @override
  String get storyExampleHint =>
      'Eksempel: \"Den [ADJ] katten satt på en [ADJ] matte.\"';

  @override
  String get writeStoryHere => 'Skriv historien din her…';

  @override
  String get saveAndFillRandomly => 'Lagre og fyll tilfeldig';

  @override
  String get saveStory => 'Lagre historien';

  @override
  String get youWroteThisStory =>
      'Du skrev denne historien. Vent på at de andre spillerne fyller inn feltene.';

  @override
  String blanksFilled(int filled, int total) {
    return '$filled/$total felt fylt';
  }

  @override
  String blankN(int n) {
    return 'Felt $n';
  }

  @override
  String get waitingForYourTurn => 'Venter på din tur…';

  @override
  String roundN(String n) {
    return 'Runde $n';
  }

  @override
  String get failedToLoadTurn => 'Kunne ikke laste tur';

  @override
  String get failedToSubmit => 'Kunne ikke sende inn';

  @override
  String get yourTurnWriteSentence => 'Din tur: skriv en setning';

  @override
  String get yourTurnFillAdjective => 'Din tur: fyll inn adjektivfeltet';

  @override
  String get includePlaceholder => 'Inkluder [ADJ] som plassholder';

  @override
  String get whatAdjectiveFits => 'Hvilket adjektiv passer her?';

  @override
  String get previous => 'Forrige:';

  @override
  String get sentenceHint =>
      'Den [ADJ] veiviseren gikk inn i den [ADJ] skogen…';

  @override
  String get chainAdjectiveHint => 'mystisk, gammel, fluffy…';

  @override
  String get submit => 'Send inn';

  @override
  String get storySubmitted => 'Historien er sendt inn!';

  @override
  String get waitingForOtherPlayers => 'Venter på de andre spillerne…';

  @override
  String get failedToLoadPrompt => 'Kunne ikke laste oppgaven';

  @override
  String get failedToSubmitEntry => 'Kunne ikke sende inn bidraget ditt';

  @override
  String get failedToCastVote => 'Kunne ikke avgi stemme';

  @override
  String get fillInAdjectives => 'Fyll inn adjektivene';

  @override
  String get yourContinuation => 'Din fortsettelse';

  @override
  String get continueStoryHint => 'Fortsett historien med dine egne ord…';

  @override
  String get submitStory => 'Send inn historien';

  @override
  String get voteForBestStory => 'Stem på den beste historien!';

  @override
  String get results => '🏆 Resultater';

  @override
  String get player => 'Spiller';

  @override
  String get vote => 'Stem';

  @override
  String get enterAnAdjective => 'Skriv inn et adjektiv';

  @override
  String get blankInputHint => 'f.eks. mystisk, fluffy, gammel…';

  @override
  String get confirm => 'Bekreft';

  @override
  String get pageNotFound => 'Siden ble ikke funnet';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get goHome => 'Gå hjem';

  @override
  String get playAgain => 'Spill igjen';
}
