/*
** The base card class that is used by decks and cardhands
*/
/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	/// Do all the cards drop to the floor when thrown at a person
	var/can_play_52_card_pickup = TRUE
	/// List of cards for a hand or deck
	var/list/cards = list()

/obj/item/toy/cards/Destroy()
	if(LAZYLEN(cards))
		QDEL_LIST(cards)
	return ..()

/// This is how we play 52 card pickup
/obj/item/toy/cards/throw_impact(mob/living/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || !istype(target)) // was it caught or is the target not a living mob
		return .

	if(!throwingdatum?.thrower) // if a mob didn't throw it (need two people to play 52 pickup)
		return

	var/has_no_cards = !LAZYLEN(cards)
	if(has_no_cards)
		return

	for(var/obj/item/toy/singlecard/card in cards)
		cards -= card
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

	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)

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
 *
 * Arguments:
 * * card_item - Either a singlecard or cardhand that gets inserted into the src
 */
/obj/item/toy/cards/proc/insert(obj/item/toy/card_item)
	var/cards_to_add = list()
	var/obj/item/toy/cards/cardhand/recycled_cardhand

	if(istype(card_item, /obj/item/toy/singlecard))
		cards_to_add += card_item

	if(istype(card_item, /obj/item/toy/cards/cardhand))
		recycled_cardhand = card_item

		for(var/obj/item/toy/singlecard/card in recycled_cardhand.cards)
			cards_to_add += card
			recycled_cardhand.cards -= card
			card.moveToNullspace()
		qdel(recycled_cardhand)

	for(var/obj/item/toy/singlecard/card in cards_to_add)
		card.forceMove(src)
		// reset the position and angle
		card.pixel_x = 0
		card.pixel_y = 0
		var/matrix/M = matrix()
		M.Turn(0)
		card.transform = M
		card.update_appearance()
		cards += card
		cards_to_add -= card
	update_appearance()

/**
 * Draws a card from the deck or hand of cards.
 *
 * Draws the top card unless a card arg is supplied then it picks that specific card
 * and returns it (the card arg is used by the radial menu for cardhands to select
 * specific cards out of the cardhand)
 * Arguments:
 * * mob/living/user - The user drawing the card.
 * * obj/item/toy/singlecard/card (optional) - The card drawn from the hand
**/
/obj/item/toy/cards/proc/draw(mob/living/user, obj/item/toy/singlecard/card)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK))
		return

	var/has_no_cards = !LAZYLEN(cards)
	if(has_no_cards)
		to_chat(user, span_warning("There are no more cards to draw!"))
		return

	card = card || cards[1] //draw the card on top
	cards -= card

	update_appearance()
	playsound(src, 'sound/items/cardflip.ogg', 50, TRUE)
	return card
