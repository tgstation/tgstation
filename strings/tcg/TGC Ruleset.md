<h1> Comprehensive TGC Rules </h1>

<h2> 0: About this Document </h2> <br>

0.1: This is the TGC Comprehensive Rules, explaining how to play the TGC. <br>
0.2: Any deviations between this document, other documents and/or the Wiki then this document\'s wording is the ruling one.<br>
    0.2.1: An exception is given to the rulings document, which can overrule these rules when talking about specific cards. <br>
0.3: Sections marked as ".x:" are clarifications; they are not necessary rules text but examples, reminders and etc to make learning the game easier. <br>
    0.3.1: Sections ".x:" also fall under rule 0.2 in that if there were to be deviations or contradictions between the ".x:" sections and the main sections of this document then the non-".x:" sections take precedence over the ".x:" ones. <br>

<h2> 1: Card & Game Basics </h2> 

1.1: To start a game you need two players. <br>

1.2: Each player needs a deck of cards to play. <br>
    1.2.1: Decks must include 40 total cards.  <br>
    1.2.2: You can run up to 4 copies of a specific card in your deck. <br>
    1.2.3: All cards in your deck must be a legal TGC card. <br>
    1.2.4: The following rules are deckbuilding rules for the tournament standard of TGC and may be ignored freely in casual play. <br>
        1.2.4.1: When building your deck choose 3 card subtypes. Every card in your deck must have at least one of these subtypes. <br>
        1.2.4.2: Every card in your deck must be legal, not banned and not be misprint. <br>

1.3: A coin toss is done to decide who goes first. <br>
    1.3.1: The coin toss decides who goes first, not who decides to go first. <br>
    1.3.x: This means a player is decided to be heads and the other tails; whichever side the coin lands on goes first. <br>

1.4: Each player draws 5 cards from their deck. <br>
1.5: Then, each player may mulligan cards in their hand. <br>
    1.5.1 During the mulligan each player may discard a card (face-down) from their hand to draw 1. <br>
        1.5.1.x: The opponent is not allowed to see the discarded cards but can know how many cards you chose to discard.  <br>
    1.5.2: They can perform this up to 3 times. <br>
    1.5.3: After both players have finished mulliganing shuffle all discarded cards back into the deck. <br>

1.6: Both players starts with 20 Heathshards (or HS) and 1 Plasma. <br>
1.7: The game begins on the Draw Phase of the player who won the coin toss. <br>
1.8: The player that plays second keeps the coin and places it besides them, flipped on heads. <br>
     1.9.x: This is relevant for the \"Flip Coin\" action, detailed in 3.6 <br>

1.9: Turns in this game are divided in 5 parts, called the phases. <br>
    1.9.a: Draw Phase <br>
    1.9.b: Standby Phase <br>
    1.9.c: Play Phase <br>
    1.9.d: Battle Phase <br>
    1.9.e: End Phase <br>
        1.9.x: There is no \"Play Phase 2\". You do not get to return to a Play Phase after the Battle Phase. <br>

1.10: During the Draw Phase a number of automatic game actions happen, in the following order. <br>
    1.10.1: The turn player\'s mana gets set to the amount of Draw Phases they have had in total, including this one. <br>
        1.10.1.x: So on their first turn they get 1 mana, on their second 2 mana, on their third 3 mana, etc. <br>
    1.10.2: The turn player draws a card. <br>
    1.10.3: The turn player untaps all their tapped cards. <br>
    1.10.4: The "Pass Phase" action is immediately performed. <br>
    1.10.5: This Pass Phase does not create an Open gamestate. <br>

1.11: Terminology definitions: <br>
    1.11.a: When you draw a card you add the top card of your deck to your hand. <br>
    1.11.b: When a card is destroyed it is moved to the discard pile <br>
        1.11.b.1: When a card is destroyed all cards attached to it also get destroyed. <br>
    1.11.c: When a card is tapped it is flipped sideways. <br>
    1.11.d: When a card is untapped it is returned to the upright position <br>

1.12: Any player that have their HP reduced to, set to or at 0 loses the game automatically. <br>
1.12.1: When this happens the other player immediately wins the game. <br>
    1.12.x: This can happen even if the game is in a Closed Gamestate <br>

<h2> Open and Closed States </h2>  <br>

2: The gamestate can either be Open or Closed. <br>

2.1: In a Closed gamestate no players may take any actions with the sole exception of: <br>
    2.1.a: Surrendering <br>
    2.1.b: When resolving an activated Effect that, as a part of its effect, allows its user to make a choice <br>

2.2: In an Open gamestate then one of the players may take actions, depending on the type of Open gamestate, the phase and game information. <br>

2.3: There are three types of Open gamestates: Open Play Gamestate, Open Battle Gamestate and the Open Quick Gamestate <br>
    2.3.x: These can be refered to as Open Play, Open Battle and Open Quick. <br>

2.4: During the gamestates the turn player may perform actions based on the gamestate. <br>
    2.4.1: During the Open Play gamestate you can: <br>
        2.4.1.a: Play A Card <br>
            2.4.1.a.x: This can be any type of card. <br>
        2.4.1.b: Activate An Effect    <br>
        2.4.1.c: Pass Phase <br>
        2.4.1.d: Flip Coin <br>
    2.4.2: During the Battle Play gamestate you can: <br>
        2.4.2.a: Play A Card <br>
            X.4.2.a.x: This must be an Instant card. <br>
        2.4.2.b: Activate An Effect <br>
            X.4.2.b.a: This must be a Quick effect or one that specifically can or must do so in the Battle Phase. <br>
        2.4.2.c: Pass Phase <br>
        2.4.2.d: Declare Battle <br>
    2.4.3: During the Quick Play gamestate you can: <br>
        2.4.3.a: Play A Card <br>
            2.4.2.a.x: This must be an Instant card. <br>
        2.4.3.b: Activate An Effect <br>
            2.4.2.b.1: This must be a Quick effect. <br>
        2.4.3.c: Do Nothing <br>

2.5: Different phases have diferente gamestates they default to. <br>
    2.5.1: The only exception is the Draw Phase which does not have any Open gamestates and **always** is Closed. No Open Quick gamestate may happen here. <br>
    2.5.2: When the gamestate "defaults" it means the gamestate is changed from its current gamestate to a new gamestate. Which new gamestate gets made depends on the current phase. <br>
        2.5.2.x: This is called "defaulting", "the gamestate defaulting" or similar variations. <br>
    2.3.3: Once a gamestate defaults the player that can play in that gamestate is the turn player. <br>
        2.3.x: The non turn player can only play effects after the turn player used the "Pass Phase" action. <br>
    2.5.4: The phases\' default gamestates are: <br>
        2.5.3.a: Standby Phase - Open Quick Gamestate <br>
        2.5.3.b: Play Phase - Open Play Gamestate <br>
        2.5.3.c: Battle Phase - Open Battle Gamestate <br>
        2.5.3.d: End Phase - Open Quick Gamestate <br>

<h2>  3: Actions to Perform </h2> <br>

3.1: When a player declares an action then it immediately becomes a closed gamestate. <br>

3.2: The following actions are Control Actions that don\'t influence the board but rather the gamestate and/or the phases of the game. <br>
    3.2.1: Control actions do not close the gamestate unless otherwise stated. <br>
    3.2.a: "Pass Phase" <br>
        3.2.a.1: When this action is performed an Open Quick gamestate is opened. The next time it defaults the gamestate becomes Closed and the phase gets changed to the next phase <br>
        3.2.a.1.x: The sequence of the phases is detailed in 1.9 <br>
        3.2.a.2: After the phase changes a Open Quick gamestate is opened. <br>
    3.2.b: \"Do Nothing\" <br>
        3.2.b.1: When this action is performed then the same type of gamestate that this action was created in gets created but for the opponent instead.<br>
        3.2.b.2: If this action is done by both players consecutively then the gamestate defaults. <br>

3.3: Play A Card <br>
    3.3.1: In order to use this action you must have a valid card in your hand you can activate. <br>
        3.3.1.1: You must have enough plasma to play the card <br>
        3.3.1.2: There must be at least one valid to equip creature in play in order to play an Equipment card <br>
    3.3.2: Reduce your plasma count by the cost of the card, then put it on the field. <br>
    3.3.3: Depending on the type of card you then perform the additional actions: <br>
        3.3.3.a: Creature Card <br>
            3.3.3.a.1: The creature comes into play tapped. <br>
        3.3.3.b: Equipment Card <br>
            3.3.3.b.1: Select a creature on either side of the field. <br>
            3.3.3.b.2: Attach the Equipment card underneath the creature card. <br>
            3.3.3.b.3: The creature gains resolve and power equal to the equipment cards\' resolve and power. <br>
                3.3.3.b.3.1: If the attached equipment is destroyed or removed then the creature loses these bonus. <br>
        3.3.3.c: Instant Card and Event Card <br>
            3.3.3.c.1: The effect of the card is applied and then the card is discarded. <br>
        3.3.3.d: Battlefield Card <br>
            3.3.3.d.1: If you already have a Battlefield card on the field the old one is destroyed before the new gets placed on the field. <br>
    3.3.4: Afterwards a Quick Open gamestate is opened. <br>

3.4: Activate an Effect <br>
    3.4.1: In order to use this action you must have an effect you can activate. <br>
        3.4.1.x: This refers to effects that are not specifically playing a card from hand using the mana cost. Tap effects, On Play: effects, discard pile effects, etc all fall under this category. <br>
    3.4.2: You can only activate an effect that has a specific trigger if that trigger has happened within the last Closed gamestate and now. <br>
        3.4.2.x: Control actions (such as Pass Priority or Pass Phase) have special rules on if they trigger a Closed gamestate or not, affecting when certain cards can trigger or not. <br>
    3.4.3: When using a card\'s effect you follow the instructions written on the card itself. <br>
    3.4.4: Once the effect of the card finishes a Quick Open gamestate is opened. <br>

3.5: Declare Battle <br>
    3.5.1: When you Declare Battle, select one of your creatures to be the attacker. <br>
    3.5.2: Then, choose either a direct attack or an attack against a creature and perform that with the selected creature as the attacker. <br>
        3.5.2.x: The rules for that are in 4.1 and 4.2, respectively. <br>

3.6: Flip Coin <br>
    3.6.1: This action may only be performed if you have the coin and it\'s on the heads position. <br>
    3.6.2: When you perform this action, flip the coin to the tails position. Then, you gain +1 plasma for this turn. <br>
    3.6.2: Afterwards a Quick Open gamestate is opened. <br>

<h2>  4: Card Combat </h2> <br>

4.1: In a direct attack the defending player may choose one of their non-tapped creatures to block with. <br>
    4.1.1: If the defending player chooses not to defend or does not have units to defend with then the direct attack goes through. <br>
        4.1.1.1: If the defending player does choose to block then it becomes a creature attack. <br>
    4.1.2: After the direct attack goes through a Open Quick Gamestate is opened. The next time the gamestate defaults close the gamestate and move to 4.1.3. <br>
        4.1.2.1: If the attacking creature leaves the field or becomes unable to perform a direct attack before the gamestate defauls then when it defaults it defaults normally rather than proceeding to 4.1.3   <br>
    4.1.3: When this happens the attacking creature deals damage to the opponent player equal to its power. <br>
    4.1.4: Afterwards the creature gets tapped and the gamestate defaults. <br>

4.2: In a creature attack two creatures attack eachother. <br>
    4.2.1: If the creature attack is declared by the opponent in response to a direct attack then they choose the defender <br>
        4.2.1.1: If the creature attack is declared by the turn player directly then the turn player chooses the defender <br>
    4.2.2: Afterwards a Open Quick Gamestate is opened. The next time the gamestate defaults close the gamestate and move to 4.2.3. <br>
        4.2.2.1: If the attacking creature leaves the field or becomes unable to perform this attack before the gamestate defauls then when it defaults it defaults normally rather than proceeding to 4.2.3 <br>
    4.2.3: Both creatures deal damage equal to their power to eachother <br>
    4.2.4: After combat any surviving creatures get tapped. The gamestate then defaults. <br>

4.3: Damage is a thing that can be done to creatures or players <br>
    4.3.1: When a creature or player is to be damaged reduce their HS (for players) or Resolve (for creatures) equal to the amount of damage they're taking <br>
    4.3.2: If a creature's resolve were to go to 0 or below then it is destroyed. <br>
