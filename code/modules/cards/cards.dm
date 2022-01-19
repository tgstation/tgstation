/*
|| A Deck of Cards for playing various games of chance ||
*/
/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	///The parent deck of the cards
	var/datum/weakref/parentdeck
	///Artistic style of the deck
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 3
	var/card_throw_range = 7
	var/list/card_attack_verb_continuous = list("attacks")
	var/list/card_attack_verb_simple = list("attack")

/obj/item/toy/cards/Initialize(mapload)
	. = ..()
	if(card_attack_verb_continuous)
		card_attack_verb_continuous = string_list(card_attack_verb_continuous)
	if(card_attack_verb_simple)
		card_attack_verb_simple = string_list(card_attack_verb_simple)

/obj/item/toy/cards/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] a crummy hand!"))
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS

/**
 * ## apply_card_vars
 *
 * Applies variables for supporting multiple types of card deck
 */
/obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj)
	if(!istype(sourceobj))
		return

/**
 * ## add_card
 *
 * Adds a card to the deck (or hand of cards).
 *
 * Arguments:
 * * mob/user - The user adding the card.
 * * list/cards - The list of cards the user is adding to.
 * * obj/item/toy/cards/card_to_add - The card (or hand of cards) that will be added back into the deck
 */
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

/**
 * ## draw_card
 *
 * Draws a card from the deck (or hand of cards).
 *
 * Arguments:
 * * mob/user - The user drawing from the deck.
 * * list/cards - The list of cards the user is drawing from.
 * * obj/item/toy/cards/singlecard/forced_card (optional) - Used to force the card drawn from the deck
 * * place_on_table (optional) - Used to ignore putting a card in a users hand (for placing cards on tables)
 * * flip_card_over (optional) - Used to flip a card face up when it is dealt
 */
/obj/item/toy/cards/proc/draw_card(mob/user, list/cards, obj/item/toy/cards/singlecard/forced_card = null, place_on_table = FALSE, flip_card_over = FALSE)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!(living_user.mobility_flags & MOBILITY_PICKUP))
			return
	if(cards.len == 0)
		to_chat(user, span_warning("There are no more cards to draw!"))
		return

	///Are we drawing from a hand of cards?
	var/from_cardhand = FALSE
	if (istype(src, /obj/item/toy/cards/cardhand))
		from_cardhand = TRUE

	var/obj/item/toy/cards/singlecard/card_to_draw
	if (forced_card)
		card_to_draw = forced_card
	else
		card_to_draw = cards[1]

	cards -= card_to_draw

	if(!place_on_table)
		card_to_draw.pickup(user)
		user.put_in_hands(card_to_draw)

	if(flip_card_over)
		card_to_draw.Flip()

	user.visible_message(span_notice("[user] draws a card from [from_cardhand ? "[user.p_their()] hand" : "the deck"]."), span_notice("You draw a card from [from_cardhand ? "your hand" : "the deck"]."))
	update_appearance()
	return card_to_draw
