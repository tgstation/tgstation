/*
** A Deck of Cards for playing various games of chance
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

/obj/item/toy/cards/throw_impact(mob/living/target, datum/thrownthing/throwingdatum)
	if(..() || !istype(target)) // was it caught or is the target not a living mob
		return

	var/has_no_cards = !LAZYLEN(cards)
	if(has_no_cards)
		return

	for(var/obj/item/toy/singlecard/card in cards)
		cards -= card
		card.forceMove(drop_location())
		if(prob(50))
			card.Flip()
		card.pixel_x = rand(-16, 16)
		card.pixel_y = rand(-16, 16)
		var/matrix/M = matrix()
		var/dir = pick(0, 90, 180, 270) // only North, East, West, or South
		M.Turn(dir)
		card.transform = M
		card.update_appearance()
	update_appearance()
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	
	if(istype(src, /obj/item/toy/cards/cardhand))
		qdel(src)

/**
/obj/item/toy/cards/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] a crummy hand!"))
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS
**/

/obj/item/toy/cards/proc/insert(list/cards_to_add)
	for(var/obj/item/toy/singlecard/card in cards_to_add)
		card.forceMove(src)
		cards += card
	update_appearance()

/**
 * draw
 *
 * Draws a card from the deck or hand of cards.
 *
 * Arguments:
 * * mob/living/user - The user drawing the card.
 * * obj/item/toy/singlecard/card - The card drawn from the hand
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
