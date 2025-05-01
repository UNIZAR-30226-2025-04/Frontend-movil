import 'package:flutter/material.dart';
import 'package:nogler/websocket/websocket_client.dart';
import 'package:nogler/widgets/in_game/card_widget.dart';
import 'package:nogler/widgets/in_game/joker_cards_widget.dart';
import 'package:playing_cards/playing_cards.dart';

/// A widget that displays a set of main cards with draggable behavior.
class MainCards extends StatefulWidget {
  final Function(int)? onDeckUpdated;
  final void Function(List<SelectableCard>)? onPlayCards;
  final Function(int)? onDiscardUpdated;
  final Function(int)? onPlayingdUpdated;
  final Function(int)? onScore;
  final Function(int)? onBlueScore;
  final Function(int)? onRedScore;
  final Function(int)? onHandType;
  final List<SelectableCard> handCards;
  final GlobalKey<JokerCardsState> jokerCardsKey;
  final int blind;
  final int gold;
  const MainCards({
    super.key,
    this.onDeckUpdated,
    this.onPlayCards,
    this.onDiscardUpdated,
    this.onPlayingdUpdated,
    this.onBlueScore,
    this.onRedScore,
    this.onScore,
    this.onHandType,
    required this.blind,
    required this.handCards,
    required this.jokerCardsKey,
    required this.gold,
  });

  @override
  MainCardsState createState() => MainCardsState();
}

class MainCardsState extends State<MainCards> {
  List<SelectableCard> handCards = [];
  List<PlayingCard> remainingDeck = [];
  int totalScore = 0;

  /// Stores the index of the dragged card
  int? _draggedIndex;
  int? discardingCards;
  int? playingCards;
  int get remainingCards => remainingDeck.length;
  final WebSocketClient wsClient = WebSocketClient();
  int gold = 0;
  bool isReached = false;

  /// Overlay for card description
  OverlayEntry? _overlayEntry;
  String? lobbyId;
  @override
  void initState() {
    super.initState();
    gold = widget.gold;
    _setupWebSocketListeners();
    _getCards();
    handCards = widget.handCards;
  }

  /// Starts the game by drawing cards from the deck
  void _getCards() {
    // Send the request to the server to draw cards
    wsClient.sendMessage("get_cards", {});
  }

  /// Sets up the WebSocket listener to receive card data from the server.
  void _setupWebSocketListeners() {
    // Listen for the 'get_cardsno' event to receive the deck of cards
    wsClient.addEventListener('got_cards', (data) async {
      try {
        // Parse the data received from the server
        final deckSize = data['deck_size'] as int;

        // new_cards is a List
        final List<dynamic> parsedList = data['new_cards'] as List<dynamic>;

        // Filter and map the parsed list to create a new list of cards
        final newCards =
            parsedList
                .map((item) {
                  return {
                    'Rank': item['Rank']?.toString(),
                    'Suit': item['Suit']?.toString().toLowerCase(),
                    'Enhancement': item['Enhancement'],
                  };
                })
                .where((card) => card['Rank'] != null && card['Suit'] != null)
                .toList();

        // Create a list of SelectableCard objects from the new cards
        final receivedCards =
            newCards.map((cardData) {
              final card = createCardFromServerData(cardData);
              return card;
            }).toList();

        // Update the remaining deck with the new cards
        widget.onDeckUpdated?.call(deckSize);

        // Animate the new cards coming in
        if (receivedCards.isNotEmpty) {
          // Add cards one by one with animation
          for (final card in receivedCards) {
            card.isNew = true;

            setState(() {
              handCards.add(card);
            });

            await Future.delayed(const Duration(milliseconds: 200));

            setState(() {
              card.isNew = false;
            });

            await Future.delayed(const Duration(milliseconds: 300));
          }
        } else {
          // No animation needed if no cards
          setState(() {
            handCards = receivedCards;
          });
        }
      } catch (e) {
        debugPrint("❌ Error parsing card data: $e");
      }
    });

    wsClient.addEventListener('discarded_cards', (data) async {
      final selected = handCards.where((c) => c.isSelected).toList();
      final leftDraws = data['left_discards'] as int;

      // Notify the parent widget about the number of cards left to draw
      widget.onDiscardUpdated?.call(leftDraws);

      // Notify the parent widget about the discarded cards
      setState(() {
        for (var c in selected) {
          c.isDiscarding = true;
        }
        discardingCards = leftDraws;
      });

      // Simulate a delay for the animation effect
      await Future.delayed(const Duration(milliseconds: 350));

      // Notify the parent widget about the discarded cards
      setState(() {
        handCards.removeWhere((c) => c.isDiscarding);
      });

      // Simulate a delay for the animation effect
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        // Parse the data received from the server
        var deckSize = data['unplayed_cards'] as int;

        // new_cards is a List
        final List<dynamic> parsedList = data['new_cards'] as List<dynamic>;
        deckSize = deckSize - 8;
        // Filter and map the parsed list to create a new list of cards
        final newCards =
            parsedList
                .map((item) {
                  return {
                    'Rank': item['Rank']?.toString(),
                    'Suit': item['Suit']?.toString().toLowerCase(),
                    'Enhancement': item['Enhancement'],
                  };
                })
                .where((card) => card['Rank'] != null && card['Suit'] != null)
                .toList();

        // Create a list of SelectableCard objects from the new cards
        final receivedCards =
            newCards.map((cardData) {
              final card = createCardFromServerData(cardData);
              return card;
            }).toList();

        // Update the remaining deck with the new cards
        widget.onDeckUpdated?.call(deckSize);

        // Animate the new cards coming in
        if (receivedCards.isNotEmpty) {
          // Add cards one by one with animation
          for (final card in receivedCards) {
            card.isNew = true;

            setState(() {
              handCards.add(card);
            });

            await Future.delayed(const Duration(milliseconds: 200));

            setState(() {
              card.isNew = false;
            });

            await Future.delayed(const Duration(milliseconds: 300));
          }
        } else {
          // No animation needed if no cards
          setState(() {
            handCards = receivedCards;
          });
        }
      } catch (e) {
        debugPrint("❌ Error parsing card data: $e");
      }
    });
    // Score map by hand type
    const handScoresList = [
      0,
      35, // 1: Flush five
      32, // 2: Flush house
      30, // 3: Five of a kind
      65, // 4: Royal flush
      50, // 5: Straight flush
      25, // 6: Four of a kind
      20, // 7: Full house
      15, // 8: Flush
      12, // 9: Straight
      10, // 10: Three of a kind
      8, // 11: Two pair
      4, // 12: One pair
      1, // 13: High card
    ];
    // Listen for the 'played_hand' event to receive the played hand data
    wsClient.addEventListener('played_hand', (data) async {
      final selected = handCards.where((c) => c.isSelected).toList();
      final selectedCards = selected.map((c) => c).toList();
      final playedCards = data['left_plays'] as int;
      final redScore = data['red_score'] as int;
      final handType = data['hand_type'] as int;
      final score = data['total_score'] as int;
      final List<dynamic> scoreCards = data['scored_cards'] as List<dynamic>;
      final time = scoreCards.length + 1;
      final scoreToAdd = handScoresList[handType];

      setState(() {
        for (var c in selected) {
          c.blueScore = (scoreToAdd).toString();
        }
      });
      // Notify the parent widget about the played cards
      widget.onPlayCards?.call(selectedCards);
      widget.onBlueScore?.call(scoreToAdd);
      widget.onRedScore?.call(redScore);
      widget.onHandType?.call(handType);

      // Notify the parent widget about the number of hands left to play
      widget.onPlayingdUpdated?.call(playedCards);
      // Notify the parent widget about the discarded cards
      setState(() {
        for (var c in selected) {
          c.isDiscarding = true;
          // Check if this card is listed among the scored cards
          final isInScored = scoreCards.any(
            (scored) => scored['Rank'] == c.rank && scored['Suit'] == c.suit,
          );

          if (isInScored) {
            // Mark the card as having scored
            c.isScored = true;
          }
        }
        playingCards = playedCards;
        totalScore += score;
      });

      // Simulate a delay for the animation effect
      await Future.delayed(const Duration(milliseconds: 350));

      // Notify the parent widget about the discarded cards
      setState(() {
        handCards.removeWhere((c) => c.isDiscarding);
      });

      // Simulate a delay for the animation effect
      await Future.delayed(Duration(seconds: time));

      // Clear the played cards from the parent widget
      widget.onPlayCards?.call([]);

      widget.onScore?.call(totalScore);
      if (totalScore >= widget.blind) {
        if (!mounted) return;
        setState(() {
          isReached = true;
        });
      }
      widget.onRedScore?.call(0);
      widget.onBlueScore?.call(0);
      try {
        // Parse the data received from the server
        var deckSize = data['unplayed_cards'] as int;

        // new_cards is a List
        final List<dynamic> parsedList = data['new_cards'] as List<dynamic>;
        deckSize = deckSize - 8;
        // Filter and map the parsed list to create a new list of cards
        final newCards =
            parsedList
                .map((item) {
                  return {
                    'Rank': item['Rank']?.toString(),
                    'Suit': item['Suit']?.toString().toLowerCase(),
                    'Enhancement': item['Enhancement'],
                  };
                })
                .where((card) => card['Rank'] != null && card['Suit'] != null)
                .toList();

        // Create a list of SelectableCard objects from the new cards
        final receivedCards =
            newCards.map((cardData) {
              final card = createCardFromServerData(cardData);
              return card;
            }).toList();

        // Update the remaining deck with the new cards
        widget.onDeckUpdated?.call(deckSize);

        // Animate the new cards coming in
        if (receivedCards.isNotEmpty) {
          // Add cards one by one with animation
          for (final card in receivedCards) {
            card.isNew = true;

            setState(() {
              handCards.add(card);
            });

            await Future.delayed(const Duration(milliseconds: 200));

            setState(() {
              card.isNew = false;
            });

            await Future.delayed(const Duration(milliseconds: 300));
          }
        } else {
          // No animation needed if no cards
          setState(() {
            handCards = receivedCards;
          });
        }
      } catch (e) {
        debugPrint("❌ Error parsing card data: $e");
      }
    });
  }

  /// Creates a SelectableCard object from the server data.
  SelectableCard createCardFromServerData(Map<String, dynamic> cardData) {
    // Extract the rank and suit from the card data
    final rank = cardData['Rank'].toString();
    final suit = cardData['Suit'].toString().toLowerCase();

    // Convert the suit and rank to the appropriate enum values
    final cardValue = valueFromString(rank);
    final cardSuit = suitFromString(suit);

    // Create a SelectableCard object with the extracted data
    return SelectableCard(
      rank: rank,
      suit: suit,
      overlay: cardData['Enhancement'],
      card: PlayingCard(cardSuit, cardValue),
      score: getCardValueFromRank(rank),
    );
  }

  /// Converts a string representation of a suit to the corresponding Suit enum value.
  Suit suitFromString(String suit) {
    switch (suit) {
      case 'h':
        return Suit.hearts;
      case 'd':
        return Suit.diamonds;
      case 'c':
        return Suit.clubs;
      case 's':
        return Suit.spades;
      default:
        return Suit.hearts;
    }
  }

  /// Converts a string representation of a rank to the corresponding CardValue enum value.
  CardValue valueFromString(String rank) {
    switch (rank) {
      case 'A':
        return CardValue.ace;
      case 'J':
        return CardValue.jack;
      case 'Q':
        return CardValue.queen;
      case 'K':
        return CardValue.king;
      case '2':
        return CardValue.two;
      case '3':
        return CardValue.three;
      case '4':
        return CardValue.four;
      case '5':
        return CardValue.five;
      case '6':
        return CardValue.six;
      case '7':
        return CardValue.seven;
      case '8':
        return CardValue.eight;
      case '9':
        return CardValue.nine;
      case '10':
        return CardValue.ten;
      default:
        return CardValue.ace;
    }
  }

  /// Discards selected cards and replaces them with new ones from the deck.
  void discardSelectedCards() async {
    // If there are no more discards or the player has reached the blind, do nothing
    if (discardingCards == 0 || isReached) return;
    final selected = handCards.where((c) => c.isSelected).toList();
    final discards =
        selected.map((card) => {'rank': card.rank, 'suit': card.suit}).toList();
    wsClient.sendMessage("discard_cards", [discards]);
  }

  /// Plays selected cards and replaces them with new ones from the deck.
  void playSelectedCards() async {
    // If there are no more plays or the player has reached the blind, do nothing
    if (playingCards == 0 || isReached) return;
    final selected = handCards.where((c) => c.isSelected).toList();

    // Data to send to the server
    final handData = {
      'cards':
          selected
              .map(
                (card) => {
                  'rank': card.rank,
                  'suit': card.suit.toLowerCase(), // Ensure lowercase suits
                  'Enhancement': card.overlay,
                },
              )
              .toList(),
      'jokers': {
        'Juglares':
            widget.jokerCardsKey.currentState!.jokersOwned
                .map((joker) => joker.subtype)
                .toList(),
      },
      'gold': gold,
    };

    // Send the request to the server to play the hand
    wsClient.sendMessage("play_hand", handData);
  }

  /// Sorts the cards in the hand by rank
  void sortCardsByRank() {
    setState(() {
      // Sort the cards by rank using a custom order
      const rankOrder = {
        'A': 1,
        '2': 2,
        '3': 3,
        '4': 4,
        '5': 5,
        '6': 6,
        '7': 7,
        '8': 8,
        '9': 9,
        '10': 10,
        'J': 11,
        'Q': 12,
        'K': 13,
      };

      // Sort the hand cards based on the rank order
      handCards.sort((a, b) {
        final aRankValue = rankOrder[a.rank] ?? 0;
        final bRankValue = rankOrder[b.rank] ?? 0;
        return bRankValue.compareTo(aRankValue);
      });
    });
  }

  /// Sort the cards in the hand by suit
  void sortCardsBySuit() {
    setState(() {
      // Sort the cards by suit using a custom order
      const suitOrder = {
        'h': 1, // hearts
        'd': 2, // diamonds
        'c': 3, // clubs
        's': 4, // spades
      };

      // Sort the hand cards based on the suit order
      handCards.sort((a, b) {
        final aSuitValue = suitOrder[a.suit] ?? 0;
        final bSuitValue = suitOrder[b.suit] ?? 0;

        // If suits are the same, sort by rank
        if (aSuitValue == bSuitValue) {
          const rankOrder = {
            'A': 1,
            '2': 2,
            '3': 3,
            '4': 4,
            '5': 5,
            '6': 6,
            '7': 7,
            '8': 8,
            '9': 9,
            '10': 10,
            'J': 11,
            'Q': 12,
            'K': 13,
          };
          final aRankValue = rankOrder[a.rank] ?? 0;
          final bRankValue = rankOrder[b.rank] ?? 0;
          return bRankValue.compareTo(aRankValue);
        }
        // Sort by suit value if suits are different
        return bSuitValue.compareTo(aSuitValue);
      });
    });
  }

  /// Returns the numeric value of a card rank as a string.
  String getCardValueFromRank(String rank) {
    switch (rank.toUpperCase()) {
      case 'A':
        return '11';
      case 'K':
        return '10';
      case 'Q':
        return '10';
      case 'J':
        return '10';
      default:
        return rank;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child:
          handCards.isNotEmpty
              ? Row(
                key: ValueKey(
                  handCards.map((c) => '${c.rank}_${c.suit}').join(),
                ),
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(handCards.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 65,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildDraggableCard(index),
                  );
                }),
              )
              : const SizedBox(height: 97), // Placeholder if no cards available
    );
  }

  /// Builds a draggable and droppable card.
  Widget _buildDraggableCard(int index) {
    final card = handCards[index];

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        // Move the card to the new position
        setState(() {
          final temp = handCards[fromIndex];
          handCards[fromIndex] = handCards[index];
          handCards[index] = temp;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          onDragStarted: () {
            // Update the dragged index when dragging starts
            setState(() {
              _draggedIndex = index;
            });
          },
          onDragEnd: (_) {
            setState(() {
              // Reset the dragged index when dragging ends
              _draggedIndex = null;
            });
          },
          // This widget is shown when the card is being dragged
          feedback: Container(
            width: 65,
            height: 97,
            color: Colors.transparent,
            child: _buildCard(card),
          ),
          // This widget is shown when the card is being dragged
          childWhenDragging:
              _draggedIndex == index
                  ? const SizedBox.shrink()
                  : _buildCard(card),
          child: Builder(
            builder:
                (cardContext) => GestureDetector(
                  onTap: () {
                    setState(() {
                      final selectedCount =
                          handCards.where((c) => c.isSelected).length;
                      final isSelected = handCards[index].isSelected;
                      if (isSelected || selectedCount < 5) {
                        handCards[index].isSelected = !isSelected;
                      }
                    });
                  },
                  onLongPress: () {
                    final renderBox =
                        cardContext.findRenderObject() as RenderBox;
                    final size = renderBox.size;
                    final position = renderBox.localToGlobal(
                      Offset(size.width, 0),
                    );
                    _showCardDescription(card, position);
                  },
                  onLongPressEnd: (_) => _hideCardDescription(),
                  child: _buildCard(card),
                ),
          ),
        );
      },
    );
  }

  /// Builds a visual playing card using the playing_cards package.
  Widget _buildCard(SelectableCard selectable) {
    return AspectRatio(
      aspectRatio: 65 / 90,

      child: AnimatedOpacity(
        opacity: selectable.isDiscarding ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedSlide(
          offset:
              selectable.isDiscarding
                  ? const Offset(0, 0.5)
                  : selectable.isNew
                  ? const Offset(0, 0.5)
                  : (selectable.isSelected
                      ? const Offset(0, -0.1)
                      : Offset.zero),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: selectable.isNew ? 0.8 : 1.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: buildCard(selectable),
          ),
        ),
      ),
    );
  }

  /// Builds the card description above it
  void _showCardDescription(SelectableCard card, Offset position) {
    _overlayEntry?.remove();

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Builder(
          builder: (ctx) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final renderBox = ctx.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final height = renderBox.size.height;

                // Resize the overlay just a bit above the card
                _overlayEntry?.remove();
                _overlayEntry = OverlayEntry(
                  builder:
                      (_) => Positioned(
                        left: position.dx - 95,
                        top: position.dy - height - 20,
                        width: 120,
                        child: Material(
                          color: Colors.transparent,
                          child: _buildDescription(card),
                        ),
                      ),
                );
                Overlay.of(ctx).insert(_overlayEntry!);
              }
            });

            // Provisional position for the description
            return Positioned(
              top: -9999,
              left: -9999,
              child: Material(
                color: Colors.transparent,
                child: _buildDescription(card),
              ),
            );
          },
        );
      },
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  /// Hides the card description when no longer onLongPressed
  void _hideCardDescription() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Shows the cards atributtes:
  /// - Card and suit
  /// - Chips added when played
  /// - Card overlay effect
  /// - Card overlay name
  Widget _buildDescription(SelectableCard selectable) {
    return Container(
      //width: 100,
      //height ?
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Container to show the card played
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade700, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              // Container to add some margin
              margin: const EdgeInsets.all(4),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "${selectable.rank} of ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: selectable.suit,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container to show the chips gained and aditional effects triggered when the card is played
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade700, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              // Container to add some margin
              margin: const EdgeInsets.all(4),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "+${getCardValueFromRank(selectable.rank)}",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(
                      text: " chips",
                      style: TextStyle(color: Colors.black),
                    ),
                    if (cardOverlay[selectable.overlay]['overlay']! !=
                        "no overlay")
                      TextSpan(
                        text:
                            "\n ${cardOverlay[selectable.overlay]['overlayDescription']!}",
                        style: TextStyle(color: Colors.black),
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (cardOverlay[selectable.overlay]['overlay']! != "no overlay")
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                border: Border.all(color: Colors.grey.shade700, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                child: Text(
                  cardOverlay[selectable.overlay]['overlayName']!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
