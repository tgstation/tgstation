/*
** The base card class that is used by decks and cardhands
*/
/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	/// Do all the cards drop to the floor when thrown at a person
	var/can_play_52_card_pickup = TRUE
	/// How many cards can we hold at the same time
	var/card_limit = 21

	/// List of card atoms for a hand or deck
	var/list/obj/item/toy/singlecard/card_atoms

	/// The initial cards in the deck. Each entry is either:
	/// - A string, representing the card name
	/// - A /datum/deck_card, which will turn into the card
	/// - A path that is a subtype of /datum/deck_card, which will be instantiated, then turned into the card
	var/list/initial_cards = list()

/obj/item/toy/cards/Destroy()
	if (!isnull(card_atoms))
		QDEL_LIST(card_atoms)
	return ..()

/// This is how we play 52 card pickup
/obj/item/toy/cards/throw_impact(mob/living/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || !istype(target)) // was it caught or is the target not a living mob
		return .

	var/mob/thrower = throwingdatum?.get_thrower()
	if(!thrower) // if a mob didn't throw it (need two people to play 52 pickup)
		return

	if(count_cards() == 0)
		return

	if (!can_play_52_card_pickup)
		return

	for(var/obj/item/toy/singlecard/card in fetch_card_atoms())
		card_atoms -= card
		card.forceMove(target.drop_location())
		if(prob(50))
			card.Flip()
		card.pixel_x = rand(-16, 16)
		card.pixel_y = rand(-16, 16)
		var/matrix/Matrix = matrix()
		var/angle = pick(0, 90, 180, 270)
		Matrix.Turn(angle)
		card.transform = Matrix
		card.update_appearance()

	playsound(src, 'sound/items/cards/cardshuffle.ogg', 50, TRUE)

	if(istype(src, /obj/item/toy/cards/cardhand))
		qdel(src)
		return

	update_appearance()

/**
 * This is used to insert a list of cards into a deck or cardhand
 *
 * All cards that are inserted have their angle and pixel offsets reset to zero however their
 * flip state does not change unless it's being inserted into a deck which is always facedown
 * (see the deck/insert proc)
 * Returns the list of inserted cards
 *
 * Arguments:
 * * card_item - Either a singlecard or cardhand that gets inserted into the src
 */
/obj/item/toy/cards/proc/insert(obj/item/toy/card_item)
	fetch_card_atoms()
	// Can't add any cards, don't do anything
	if (count_cards() >= card_limit)
		return null

	var/list/cards_to_add = list()

	if(istype(card_item, /obj/item/toy/singlecard))
		cards_to_add += card_item

	if(istype(card_item, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/recycled_cardhand = card_item
		cards_to_add += recycled_cardhand.fetch_card_atoms()

	if(length(cards_to_add) + count_cards() > card_limit)
		// Remove all cards past however many we can fit
		cards_to_add.Cut(card_limit - count_cards() + 1, length(cards_to_add) + 1)

	for(var/obj/item/toy/singlecard/card in cards_to_add)
		card.forceMove(src)
		// reset the position and angle
		card.pixel_x = 0
		card.pixel_y = 0
		var/matrix/M = matrix()
		M.Turn(0)
		card.transform = M
		card.update_appearance()
		card_atoms += card

	if(istype(card_item, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/recycled_cardhand = card_item
		recycled_cardhand.card_atoms -= cards_to_add
		if (!length(recycled_cardhand.fetch_card_atoms()))
			qdel(card_item)

	update_appearance()
	return cards_to_add

/**
 * Draws a card from the deck or hand of cards.
 *
 * Draws the top card, removing it from the associated card atoms list,
 * unless a card arg is supplied; then it picks that specific card, removes it from the
 * associated card atoms list, and returns it (the card arg is used by the radial menu for cardhands to select
 * specific cards out of the cardhand).
 * Arguments:
 * * mob/living/user - The user drawing the card.
 * * obj/item/toy/singlecard/card (optional) - The card drawn from the hand
**/
/obj/item/toy/cards/proc/draw(mob/living/user, obj/item/toy/singlecard/card)
	if(!isliving(user) || !user.can_perform_action(src, NEED_DEXTERITY | FORBID_TELEKINESIS_REACH))
		return

	if(count_cards() == 0)
		to_chat(user, span_warning("There are no more cards to draw!"))
		return

	var/list/cards = fetch_card_atoms()

	card = card || cards[1] //draw the card on top
	cards -= card

	update_appearance()
	playsound(src, 'sound/items/cards/cardflip.ogg', 50, TRUE)
	return card

/// Returns the cards in this deck.
/// Lazily generates the cards if they haven't already been made.
/obj/item/toy/cards/proc/fetch_card_atoms()
	RETURN_TYPE(/list/obj/item/toy/singlecard)

	if (!isnull(card_atoms))
		return card_atoms

	card_atoms = list()

	for (var/initial_card in initial_cards)
		if (istext(initial_card))
			card_atoms += new /obj/item/toy/singlecard(src, initial_card, src)
			continue

		var/datum/deck_card/deck_card = ispath(initial_card) ? new initial_card : initial_card
		if (!istype(deck_card))
			stack_trace("[initial_card] (created in [type]) must either be a /datum/deck_card, or a /datum/deck_card path")
			continue

		card_atoms += deck_card.create_card(src)

	return card_atoms

/// Returns the number of cards in the deck.
/// Avoids creating any cards if it is unnecessary.
/obj/item/toy/cards/proc/count_cards()
	return isnull(card_atoms) ? initial_cards.len : LAZYLEN(card_atoms)

/// A basic interface for creating a card for a deck that isn't just a name.
/datum/deck_card
	/// The name of the card
	var/name

	/// The typepath that will be instantiated
	var/path = /obj/item/toy/singlecard

/datum/deck_card/New(name)
	if (!isnull(name))
		src.name = name

/// Creates a card for the given deck
/datum/deck_card/proc/create_card(obj/item/toy/cards/deck)
	var/card = new path(deck, name, deck)
	update_card(card)
	return card

/datum/deck_card/proc/update_card(obj/item/toy/singlecard/card)
	CRASH("[type] does not implement update_card. If you just want a name, use a string instead.")

/// A /datum/deck_card that just creates a card of the given type
/datum/deck_card/of_type

/datum/deck_card/of_type/New(path)
	src.path = path

/datum/deck_card/of_type/create_card(obj/item/toy/cards/deck)
	return new path(deck)
