/*
** A Deck of Cards for playing various games of chance
*/
/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	/// Do all the cards drop out of the deck when thrown
	var/can_play_52_card_pickup = TRUE
	/// List of cards for a hand or deck
	var/list/cards = list()

/obj/item/toy/cards/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	return

/**
/obj/item/toy/cards/Initialize(mapload)
	. = ..()
	if(card_attack_verb_continuous)
		card_attack_verb_continuous = string_list(card_attack_verb_continuous)
	if(card_attack_verb_simple)
		card_attack_verb_simple = string_list(card_attack_verb_simple)
**/

/**
/obj/item/toy/cards/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] a crummy hand!"))
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS
**/


/**
 * ## add_card
 *
 * Adds a card to the deck (or hand of cards).
 *
 * Arguments:
 * * mob/user - The user adding the card.
 * * list/cards - The list of cards the user is adding to.
 * * obj/item/toy/cards/card_to_add - The card (or hand of cards) that will be added back into the deck
 * 
/obj/item/toy/cards/proc/add_card(mob/user, list/cards, obj/item/toy/cards/card_to_add)
	///Are we adding a hand of cards to the deck?
	var/from_cardhand = FALSE
	///Are we adding to a hand of cards?
	var/to_cardhand = FALSE
	if (istype(card_to_add, /obj/item/toy/cards/cardhand))
		from_cardhand = TRUE
	if (istype(src, /obj/item/toy/cards/cardhand))
		to_cardhand = TRUE

	if ((card_to_add.parentdeck != src.parentdeck) && (card_to_add.parentdeck != WEAKREF(src)))
		to_chat(user, span_warning("You can't mix cards from other decks!"))
		return
	if (!user.temporarilyRemoveItemFromInventory(card_to_add))
		to_chat(user, span_warning("The [from_cardhand ? "hand of cards" : "card"] is stuck to your hand, you can't add it to [to_cardhand ? "your hand" : "the deck"]!"))
		return

	if (from_cardhand)
		var/obj/item/toy/cards/cardhand/cards_to_add = card_to_add
		for (var/obj/item/toy/cards/singlecard/card in cards_to_add.cards)
			card.loc = src
			cards += card
	else
		var/obj/item/toy/cards/singlecard/card = card_to_add
		card.loc = src
		cards += card

	user.visible_message(span_notice("[user] adds [from_cardhand ? "the hand of cards" : "a card"] to [to_cardhand ? "[user.p_their()] hand" : "the bottom of the deck"]."), span_notice("You add the [from_cardhand ? "hand of cards" : "card"] to [to_cardhand ? "your hand" : "the bottom of the deck"]."))
	update_appearance()
*/

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
	if(!isliving(user) || !user.canUseTopic(parent, BE_CLOSE, NO_DEXTERITY, NO_TK)
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
