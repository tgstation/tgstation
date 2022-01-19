#define DECK_SHUFFLE_COOLDOWN 5 SECONDS

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	///Deck shuffling cooldown.
	COOLDOWN_DECLARE(shuffle_cooldown)
	///Tracks holodeck cards, since they shouldn't be infinite
	var/obj/machinery/computer/holodeck/holo = null
	///Cards in this deck
	var/list/cards = list()

/obj/item/toy/cards/deck/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	populate_deck()

/obj/item/toy/cards/deck/examine(mob/user)
	. = ..()
	. += span_notice("Left-click to draw a card face down.")
	. += span_notice("Right-click to draw a card face up.")
	. += span_notice("Alt-Click to shuffle the deck.")
	. += span_notice("Click and drag the deck to yourself to pickup.")

/**
 * ## generate_card
 *
 * Generates a new playing card, and assigns all of the necessary variables.
 *
 * Arguments:
 * * name - The name of the playing card.
 */
/obj/item/toy/cards/deck/proc/generate_card(name)
	var/obj/item/toy/cards/singlecard/card_to_add = new/obj/item/toy/cards/singlecard()
	if(holo)
		holo.spawned += card_to_add
	card_to_add.cardname = name
	card_to_add.parentdeck = WEAKREF(src)
	card_to_add.apply_card_vars(card_to_add, src)
	return card_to_add

/**
 * ## populate_deck
 *
 * Generates all the cards within the deck.
 */
/obj/item/toy/cards/deck/proc/populate_deck()
	icon_state = "deck_[deckstyle]_full"
	for(var/suit in list("Hearts", "Spades", "Clubs", "Diamonds"))
		cards += generate_card("Ace of [suit]")
		for(var/i in 2 to 10)
			cards += generate_card("[i] of [suit]")
		for(var/person in list("Jack", "Queen", "King"))
			cards += generate_card("[person] of [suit]")

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
	COOLDOWN_START(src, shuffle_cooldown, DECK_SHUFFLE_COOLDOWN)
	cards = shuffle(cards)
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] shuffles the deck."), span_notice("You shuffle the deck."))

/obj/item/toy/cards/deck/attack_hand(mob/living/user, list/modifiers)
	draw_card(user, cards)

/obj/item/toy/cards/deck/attack_self_secondary(mob/living/user, list/modifiers)
	draw_card(user, cards, flip_card_over=TRUE)

/obj/item/toy/cards/deck/AltClick(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK, !iscyborg(user)))
		shuffle_cards(user)
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

/obj/item/toy/cards/deck/attack_self(mob/living/user)
	shuffle_cards(user)

/obj/item/toy/cards/deck/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/toy/cards/singlecard) || istype(item, /obj/item/toy/cards/cardhand))
		add_card(user, cards, item)
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

#undef DECK_SHUFFLE_COOLDOWN
