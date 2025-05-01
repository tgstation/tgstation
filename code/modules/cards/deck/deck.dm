#define DECK_SHUFFLE_TIME (5 SECONDS)
#define DECK_SYNDIE_SHUFFLE_TIME (3 SECONDS)

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	worn_icon_state = "card"
	hitsound = null
	attack_verb_continuous = list("attacks")
	attack_verb_simple = list("attack")
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH|ALLOW_RESTING
	/// The amount of time it takes to shuffle
	var/shuffle_time = DECK_SHUFFLE_TIME
	/// Deck shuffling cooldown.
	COOLDOWN_DECLARE(shuffle_cooldown)
	/// If the deck is the standard 52 playing card deck (used for poker and blackjack)
	var/is_standard_deck = TRUE
	/// The amount of cards to spawn in the deck (optional)
	var/decksize = INFINITY
	/// The description of the cardgame that is played with this deck (used for memories)
	var/cardgame_desc = "card game"
	/// The holodeck computer used to spawn a holographic deck (see /obj/item/toy/cards/deck/syndicate/holographic)
	var/obj/machinery/computer/holodeck/holodeck
	/// If the cards in the deck have different card faces icons (blank and CAS decks do not)
	var/has_unique_card_icons = TRUE
	/// The art style of deck used (determines both deck and card icons used)
	var/deckstyle = "nanotrasen"

/obj/item/toy/cards/deck/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	AddComponent(/datum/component/two_handed, attacksound='sound/items/cards/cardflip.ogg')
	register_context()

	if(!is_standard_deck)
		return

	// generate a normal playing card deck
	initial_cards += "Joker Clown"
	initial_cards += "Joker Mime"
	for(var/suit in list("Hearts", "Spades", "Clubs", "Diamonds"))
		initial_cards += "Ace of [suit]"
		for(var/i in 2 to 10)
			initial_cards += "[i] of [suit]"
		for(var/person in list("Jack", "Queen", "King"))
			initial_cards += "[person] of [suit]"

/obj/item/toy/cards/deck/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like their luck ran out!"))
	playsound(src, 'sound/items/cards/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/cards/deck/examine(mob/user)
	. = ..()

	if(HAS_TRAIT(user, TRAIT_XRAY_VISION) && count_cards() > 0)
		. += span_notice("You scan the deck with your x-ray vision and the top card reads: [fetch_card_atoms()[1].cardname].")

	// This can only happen if card_atoms have been generated
	if(LAZYLEN(card_atoms) > 0)
		var/obj/item/toy/singlecard/card = fetch_card_atoms()[1]

		var/marked_color = card.getMarkedColor(user)
		if(marked_color)
			. += span_notice("The top card of the deck has a [marked_color] mark on the corner!")

	. += span_notice("Click and drag the deck to yourself to pickup.") // This should be a context screentip

/obj/item/toy/cards/deck/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(src == held_item)
		var/obj/item/toy/cards/deck/dealer_deck = held_item
		context[SCREENTIP_CONTEXT_LMB] = HAS_TRAIT(dealer_deck, TRAIT_WIELDED) ? "Recycle mode" : "Dealer mode"
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Shuffle"
		return CONTEXTUAL_SCREENTIP_SET

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Draw card"
		context[SCREENTIP_CONTEXT_RMB] = "Draw card faceup"
		// add drag & drop screentip here in the future
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/singlecard))
		context[SCREENTIP_CONTEXT_LMB] = "Recycle card"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/toy/cards/cardhand))
		context[SCREENTIP_CONTEXT_LMB] = "Recycle cards"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/**
 * Shuffles the cards in the deck
 *
 * Arguments:
 * * user - The person shuffling the cards.
 */
/obj/item/toy/cards/deck/proc/shuffle_cards(mob/living/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown))
		return
	COOLDOWN_START(src, shuffle_cooldown, shuffle_time)
	shuffle_inplace(fetch_card_atoms())
	playsound(src, 'sound/items/cards/cardshuffle.ogg', 50, TRUE)
	user.balloon_alert_to_viewers("shuffles the deck")
	addtimer(CALLBACK(src, PROC_REF(CardgameEvent), user), 60 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/// This checks if nearby mobs are playing a cardgame and triggers a mood and memory
/obj/item/toy/cards/deck/proc/CardgameEvent(mob/living/dealer)
	var/card_players = list()
	for(var/mob/living/carbon/person in viewers(loc, COMBAT_MESSAGE_RANGE))
		var/obj/item/toy/held_card_item = person.is_holding_item_of_type(/obj/item/toy/singlecard) || person.is_holding_item_of_type(/obj/item/toy/cards/deck) || person.is_holding_item_of_type(/obj/item/toy/cards/cardhand)
		if(held_card_item)
			card_players[person] = held_card_item

	if(length(card_players) >= 2) // need at least 2 people to play a cardgame, duh!
		for(var/mob/living/carbon/player in card_players)
			var/other_players = card_players - player
			var/obj/item/toy/held_card_item = card_players[player]

			player.add_mood_event("playing_cards", /datum/mood_event/playing_cards)
			player.add_mob_memory( \
				/datum/memory/playing_cards, \
				deuteragonist = dealer, \
				game = cardgame_desc, \
				protagonist_held_card = held_card_item, \
				other_players = other_players, \
			)

/obj/item/toy/cards/deck/attack_hand(mob/living/user, list/modifiers, flip_card = FALSE)
	if(!ishuman(user) || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return

	var/obj/item/toy/singlecard/card = draw(user)
	if(!card)
		return
	if(flip_card)
		card.Flip()
	card.pickup(user)
	user.put_in_hands(card)
	user.balloon_alert_to_viewers("draws a card")

/obj/item/toy/cards/deck/attack_hand_secondary(mob/living/user, list/modifiers)
	attack_hand(user, modifiers, flip_card = TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/toy/cards/deck/click_alt(mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, span_notice("You must hold the [src] with both hands to shuffle."))
		return CLICK_ACTION_BLOCKING

	shuffle_cards(user)
	return CLICK_ACTION_SUCCESS

/obj/item/toy/cards/deck/update_icon_state()
	switch(count_cards())
		if(27 to INFINITY)
			icon_state = "deck_[deckstyle]_full"
		if(11 to 27)
			icon_state = "deck_[deckstyle]_half"
		if(1 to 11)
			icon_state = "deck_[deckstyle]_low"
		else
			icon_state = "deck_[deckstyle]_empty"
	return ..()

/obj/item/toy/cards/deck/insert(obj/item/toy/card_item)
	// any card inserted into the deck is always facedown
	if(istype(card_item, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/card = card_item
		card.Flip(CARD_FACEDOWN)
	if(istype(card_item, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/cardhand = card_item
		for(var/obj/item/toy/singlecard/card in cardhand.fetch_card_atoms())
			card.Flip(CARD_FACEDOWN)
	. = ..()

/obj/item/toy/cards/deck/attackby(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/toy/singlecard) || istype(item, /obj/item/toy/cards/cardhand))
		insert(item)
		var/card_grammar = istype(item, /obj/item/toy/singlecard) ? "card" : "cards"
		user.balloon_alert_to_viewers("puts [card_grammar] in deck")
		return
	return ..()

/// This is how we play 52 card pickup
/obj/item/toy/cards/deck/throw_impact(mob/living/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || !istype(target)) // was it caught or is the target not a living mob
		return .

	var/mob/living/thrower = throwingdatum?.get_thrower()
	if(!thrower) // if a mob didn't throw it (need two people to play 52 pickup)
		return

	target.visible_message(span_warning("[target] is forced to play 52 card pickup!"), span_warning("You are forced to play 52 card pickup."))
	target.add_mood_event("lost_52_card_pickup", /datum/mood_event/lost_52_card_pickup)
	thrower.add_mood_event("won_52_card_pickup", /datum/mood_event/won_52_card_pickup)
	add_memory_in_range(target, 7, /datum/memory/playing_card_pickup, protagonist = thrower, deuteragonist = target, antagonist = src)

/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/
/obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	cardgame_desc = "suspicious card game"
	icon_state = "deck_syndicate_full"
	deckstyle = "syndicate"
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	force = 5
	throwforce = 10
	attack_verb_continuous = list("attacks", "slices", "dices", "slashes", "cuts")
	attack_verb_simple = list("attack", "slice", "dice", "slash", "cut")
	resistance_flags = NONE
	shuffle_time = DECK_SYNDIE_SHUFFLE_TIME

#undef DECK_SHUFFLE_TIME
#undef DECK_SYNDIE_SHUFFLE_TIME
