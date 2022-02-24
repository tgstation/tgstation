#define DECK_SHUFFLE_TIME 5 SECONDS
#define DECK_SYNDIE_SHUFFLE_TIME 3 SECONDS

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	worn_icon_state = "card"
	///The amount of time it takes to shuffle
	var/shuffle_time = DECK_SHUFFLE_TIME
	///Deck shuffling cooldown.
	COOLDOWN_DECLARE(shuffle_cooldown)
	///Tracks holodeck cards, since they shouldn't be infinite
	var/obj/machinery/computer/holodeck/holo = null
	///Wielding status for holding with two hands
	var/wielded = FALSE

/obj/item/toy/cards/deck/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	AddComponent(/datum/component/two_handed, attacksound='sound/items/cardflip.ogg')

	if(deckstyle == "nanotrasen" || deckstyle == "syndicate") 
		// generate a normal playing card deck
		for(var/suit in list("Hearts", "Spades", "Clubs", "Diamonds"))
			cards += new /obj/item/toy/singlecard(name = "Ace of [suit]", parent_deck = src)
			for(var/i in 2 to 10)
				cards += new /obj/item/toy/singlecard(name = "[i] of [suit]", parent_deck = src)
			for(var/person in list("Jack", "Queen", "King"))
				cards += new /obj/item/toy/singlecard(name = "[person] of [suit]", parent_deck = src)

/obj/item/toy/cards/deck/Destroy()
	QDEL_LIST(cards)
    return ..()

/// triggered on wield of two handed item
/obj/item/toy/cards/deck/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/toy/cards/deck/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielded = FALSE

/obj/item/toy/cards/deck/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_XRAY_VISION))
		if(cards.len == 0)
			. += span_warning("You scan the deck with your x-ray vision but there are no cards left!")
		else
			var/obj/item/toy/singlecard/card = cards[1]
			. += span_notice("You scan the deck with your x-ray vision and the top card reads: [card.cardname].")

	. += span_notice("Left-click to draw a card face down.")
	. += span_notice("Right-click to draw a card face up.")
	. += span_notice("Alt-Click to shuffle the deck.")
	. += span_notice("Click and drag the deck to yourself to pickup.")

/**
 * draw
 *
 * Draws a card from the deck.
 *
 * Arguments:
 * * mob/living/user - The user drawing from the deck.
 * * place_on_table (optional) - Used to ignore putting a card in a users hand (for placing cards on tables)
 */
/obj/item/toy/cards/deck/draw(mob/living/user, place_on_table = FALSE)
	. = ..()
	if(. == CARD_DRAW_CANCEL)
		return 

	var/obj/item/toy/singlecard/card
	card = cards[1] //draw the card on top
	cards -= card

	if(!place_on_table)
		card.pickup(user)
		user.put_in_hands(card)
		user.visible_message(span_notice("[user] draws a card from [src]."), span_notice("You draw a card from [src]."))
	else
		user.visible_message(span_notice("[user] deals a card from [src]."), span_notice("You deal a card from [src]."))

	update_appearance()
	return card

/**
 * ## shuffle_cards
 *
 * Shuffles the cards in the deck
 * 
 * Arguments:
 * * user - The person shuffling the cards.
 */
/obj/item/toy/cards/deck/proc/shuffle_cards(mob/living/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown))
		return
	COOLDOWN_START(src, shuffle_cooldown, shuffle_time)
	cards = shuffle(cards)
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] shuffles the deck."), span_notice("You shuffle the deck."))

/obj/item/toy/cards/deck/attack_hand(mob/living/user, list/modifiers)
	draw(user)

/obj/item/toy/cards/deck/attack_self_secondary(mob/living/user, list/modifiers)
	var/obj/item/toy/singlecard/card = draw(user)
	card.Flip()

/obj/item/toy/cards/deck/AltClick(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		if(wielded)
			shuffle_cards(user)
		else
			to_chat(user, span_notice("You must hold the [src] with both hands to shuffle."))
	return ..()

/obj/item/toy/cards/deck/update_icon_state()
	switch(cards.len)
		if(27 to INFINITY)
			icon_state = "deck_[deckstyle]_full"
		if(11 to 27)
			icon_state = "deck_[deckstyle]_half"
		if(1 to 11)
			icon_state = "deck_[deckstyle]_low"
		else
			icon_state = "deck_[deckstyle]_empty"
	return ..()

/obj/item/toy/cards/deck/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/toy/singlecard) || istype(item, /obj/item/toy/cards/cardhand))
		//insert(user, item)
	else
		return ..()

/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/
/obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	icon_state = "deck_syndicate_full"
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_throw_range = 7
	card_attack_verb_continuous = list("attacks", "slices", "dices", "slashes", "cuts")
	card_attack_verb_simple = list("attack", "slice", "dice", "slash", "cut")
	resistance_flags = NONE
	shuffle_time = DECK_SYNDIE_SHUFFLE_TIME

#undef DECK_SHUFFLE_TIME
#undef DECK_SYNDIE_SHUFFLE_TIME
