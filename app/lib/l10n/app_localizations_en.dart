// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signingIn => 'Signing in…';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signInFailed => 'Sign-in failed. Please try again.';

  @override
  String get loginSubtitlePre => 'The ';

  @override
  String get loginSubtitlePost => ' storytelling game';

  @override
  String get loginAdj0 => 'creative';

  @override
  String get loginAdj1 => 'hilarious';

  @override
  String get loginAdj2 => 'ridiculous';

  @override
  String get loginAdj3 => 'epic';

  @override
  String get loginAdj4 => 'wild';

  @override
  String get loginAdj5 => 'chaotic';

  @override
  String get loginAdj6 => 'legendary';

  @override
  String get chooseMode => 'Choose a mode';

  @override
  String get joinFriendRoomSubtitle => 'Or join a friend’s room below';

  @override
  String get modeFillReveal => 'Fill & Reveal';

  @override
  String get modeFillRevealSubtitle =>
      'Fill hidden adjective blanks — solo or with friends';

  @override
  String get fillRevealPlayerLabel => '1 – ★ blanks';

  @override
  String get modeRotatingChain => 'Rotating Chain';

  @override
  String get modeRotatingChainSubtitle =>
      'Build a chaotic story step-by-step in secret';

  @override
  String get rotatingChainPlayerLabel => '2 – 6 players';

  @override
  String get modeAdjectiveBattle => 'Adjective Battle';

  @override
  String get modeBattleSubtitle =>
      'Compete to make the funniest story from the same prompt';

  @override
  String get battlePlayerLabel => '2 – 8 players';

  @override
  String get joinARoom => 'Join a Room';

  @override
  String get numberOfPlayers => 'Number of players';

  @override
  String get solo => 'Solo';

  @override
  String get createRoom => 'Create Room';

  @override
  String get failedToCreateRoom => 'Failed to create room';

  @override
  String get fillRevealPlayerHint =>
      'Solo = just you. Multiplayer = you write the story, others fill the blanks. You need at least one [ADJ] blank per other player.';

  @override
  String get rotatingChainPlayerHint =>
      'Min 2, max 6 — each player writes one step.';

  @override
  String get battlePlayerHint =>
      'Min 2, max 8 — everyone fills the same story and votes.';

  @override
  String get fillRevealBannerDesc =>
      'Write a story with adjective blanks. Everyone fills them in — then the full story is revealed!';

  @override
  String get rotatingChainBannerDesc =>
      'Each player writes one part of the story in secret, passing it around the chain.';

  @override
  String get battleBannerDesc =>
      'All players fill the same story independently. The group votes for the funniest result!';

  @override
  String get enterRoomCode => 'Enter a room code';

  @override
  String get askHostForCode => 'Ask your host for the 6-character code';

  @override
  String get roomCodeLabel => 'Room Code';

  @override
  String get lettersAndNumbersOnly => 'Letters and numbers only';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get roomNotFound => 'Room not found. Check the code and try again.';

  @override
  String get lobby => 'Lobby';

  @override
  String get players => 'Players';

  @override
  String get startGame => 'Start Game';

  @override
  String get waitingForHostToStart => 'Waiting for host to start…';

  @override
  String get failedToLoadRoom => 'Failed to load room';

  @override
  String get failedToStartGame => 'Failed to start the game';

  @override
  String get hostBadge => 'HOST';

  @override
  String get roomCodeCopied => 'Room code copied!';

  @override
  String get hide => 'Hide';

  @override
  String get reveal => 'Reveal!';

  @override
  String get waitingForStoryWriter => 'Waiting for the story writer…';

  @override
  String get hostIsWritingStory =>
      'The host is writing a story. You’ll fill in the adjectives once it’s ready.';

  @override
  String get failedToLoadGame => 'Failed to load game';

  @override
  String get storyNeedsPlaceholder =>
      'Your story needs at least one [ADJ] placeholder';

  @override
  String addAtLeastNBlanks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add at least $count [ADJ] blanks — one per player',
      one: 'Add at least $count [ADJ] blank — one per player',
    );
    return '$_temp0';
  }

  @override
  String get failedToCreateStory => 'Failed to create story';

  @override
  String get failedToSubmitAdjective => 'Failed to submit adjective';

  @override
  String get writeAStory => 'Write a story';

  @override
  String get soloStoryHint =>
      'Add [ADJ] placeholders — they’ll be filled with random adjectives when you save.';

  @override
  String get multiStoryHintBase => 'Use [ADJ] as placeholders for adjectives.';

  @override
  String multiStoryHintBlanks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You need at least $count [ADJ] blanks — one per player.',
      one: 'You need at least $count [ADJ] blank — one per player.',
    );
    return '$_temp0';
  }

  @override
  String get storyExampleHint =>
      'Example: \"The [ADJ] cat sat on a [ADJ] mat.\"';

  @override
  String get writeStoryHere => 'Write your story here…';

  @override
  String get saveAndFillRandomly => 'Save & Fill Randomly';

  @override
  String get saveStory => 'Save Story';

  @override
  String get youWroteThisStory =>
      'You wrote this story. Wait for the other players to fill in the blanks.';

  @override
  String blanksFilled(int filled, int total) {
    return '$filled/$total blanks filled';
  }

  @override
  String blankN(int n) {
    return 'Blank $n';
  }

  @override
  String get waitingForYourTurn => 'Waiting for your turn…';

  @override
  String roundN(String n) {
    return 'Round $n';
  }

  @override
  String get failedToLoadTurn => 'Failed to load turn';

  @override
  String get failedToSubmit => 'Failed to submit';

  @override
  String get yourTurnWriteSentence => 'Your turn: write a sentence';

  @override
  String get yourTurnFillAdjective => 'Your turn: fill the adjective blank';

  @override
  String get includePlaceholder => 'Include [ADJ] as a placeholder';

  @override
  String get whatAdjectiveFits => 'What adjective fits here?';

  @override
  String get previous => 'Previous:';

  @override
  String get sentenceHint => 'The [ADJ] wizard walked into the [ADJ] forest…';

  @override
  String get chainAdjectiveHint => 'mysterious, ancient, fluffy…';

  @override
  String get submit => 'Submit';

  @override
  String get storySubmitted => 'Story submitted!';

  @override
  String get waitingForOtherPlayers => 'Waiting for other players…';

  @override
  String get failedToLoadPrompt => 'Failed to load prompt';

  @override
  String get failedToSubmitEntry => 'Failed to submit your entry';

  @override
  String get failedToCastVote => 'Failed to cast vote';

  @override
  String get fillInAdjectives => 'Fill in the adjectives';

  @override
  String get yourContinuation => 'Your continuation';

  @override
  String get continueStoryHint => 'Continue the story in your own words…';

  @override
  String get submitStory => 'Submit Story';

  @override
  String get voteForBestStory => 'Vote for the best story!';

  @override
  String get results => '🏆 Results';

  @override
  String get player => 'Player';

  @override
  String get vote => 'Vote';

  @override
  String get enterAnAdjective => 'Enter an adjective';

  @override
  String get blankInputHint => 'e.g. mysterious, fluffy, ancient…';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get goHome => 'Go Home';

  @override
  String get playAgain => 'Play Again';
}
